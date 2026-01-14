from PIL import Image
import os
import sys

def convert_to_atari_7800(filename):
    try:
        img = Image.open(filename).convert("RGBA")
        
        # Create a new image with a transparent background
        # We want to force a 4-color palette.
        # Best way in Pillow to get reduced PLTE size is quantize.
        
        # Method 1: Create a P image with a specific small palette?
        # Pillow often expands back to 256. 
        # Method 2: Use quantize(colors=4).
        
        # We need specific colors though for 7800Basic to map to indices 0-3?
        # Actually 7800basic usually just maps index 0->Background, 1->Color1 etc.
        # It's better if we map pixels to 0,1,2,3 and save.
        
        # Let's try forcing the pixels to correct indices, then using putpalette with ONLY 4 colors?
        # Pillow might complain if data is 8-bit.
        
        width, height = img.size
        
        # Aspect Ratio Correction for 160A mode (Pixels are ~2x wide)
        # Stretch vertically by 2x to make them look square on TV.
        new_height = height * 2
        img = img.resize((width, new_height), Image.NEAREST)
        height = new_height
        
        # 7800Basic zone height compatibility:
        # If image is smaller than 16x16, pad it to 16x16 to prevent reading into next sprite data.
        # This fixes "bleeding" issues with small sprites like bullet (2x2).
        target_w = max(width, 16)
        target_h = max(height, 16)
        
        # Create a "P" image with strict palette
        # Init with 0 (transparent)
        new_img = Image.new("P", (target_w, target_h), 0)
        
        # Calculate offset to center? Or top-left?
        # Top-left (0,0) is safest for sprite alignment usually, or center for rotation.
        # Bullets are 2x2, let's put them at (7,7) for center? 
        # Or just (0,0) and let user adjust offset?
        # Let's center it.
        off_x = (target_w - width) // 2
        off_y = (target_h - height) // 2
        
        # Manual pixel mapping (same as before) logic
        pixels = img.load()
        new_pixels = new_img.load()
        
        unique_colors = set()
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                # Treat Black (0,0,0) as transparent as well
                if a == 0 or (r == 0 and g == 0 and b == 0):
                    continue
                unique_colors.add((r, g, b))
        
        # Sort by brightness, then by R, G, B for deterministic order
        # This ensures Green (0,255,0) always comes before Red (255,0,0) if sums are equal
        sorted_colors = sorted(list(unique_colors), key=lambda c: (c[0]+c[1]+c[2], c[0], c[1], c[2]))
        
        if len(sorted_colors) > 3:
            sorted_colors = sorted_colors[-3:] # Keep 3 brightest
            
        color_map = {}
        for i, color in enumerate(sorted_colors):
            color_map[color] = i + 1
            
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a == 0 or (r == 0 and g == 0 and b == 0):
                   continue
                else:
                    target_x = x + off_x
                    target_y = y + off_y
                    if (r, g, b) in color_map:
                        new_pixels[target_x, target_y] = color_map[(r, g, b)]
                    else:
                        new_pixels[target_x, target_y] = 1

        # Tricky Part: Making Pillow save a SMALL palette.
        # We define a palette of ONLY 4 colors (12 bytes).
        # We assume Pillow writes PLTE chunk based on length of palette data.
        
        palette_data = [
            0, 0, 0,      # 0
            255, 255, 0,  # 1
            255, 128, 0,  # 2
            255, 255, 255 # 3
        ]
        
        # If we just put this, Pillow might treat it as incomplete 256.
        # But if we use ImagePalette module or quantize...
        # Let's try appending just enough zeros? No, that makes it big.
        # Let's try saving with "bits=2" or "colors=4" if available?
        # Actually simplest hack: Use `quantize`.
        
        # Let's feed our constructed image into quantize?
        # No, quantize re-computes.
        
        # Correct approach for 7800Basic compatibility:
        # Just use the 256-color palette but ensure indices are < 4.
        # PROBABLY 7800basic is checking `palette size` in header.
        
        # Let's try saving with .quantize(colors=4)
        # We need to give it an RGB image so it finds the colors?
        # But we want SPECIFIC indices.
        
        # Solution:
        # Create a P image (256 colors).
        # Then trim use Image.save params? 'bits' parameter is sometimes supported.
        # new_img.save(filename_out, update=True) ?
        
        # Let's assume standard convert works if we reduce colors.
        
        # DO NOT use quantize here! It destroys the manual index mapping we just did (0=Trans, 1-3=Colors)
        # final_img = new_img.quantize(colors=4, method=0) 
        
        # Instead, just use the manually constructed P-mode image.
        final_img = new_img
        
        # Better: create a palette image and use `im.im.convert("P", 0, palette_im.im)` low level? No.
        
        # Let's stick to the manual pixel assignment, but try to force the palette size.
        new_img.putpalette(palette_data + [0]*(768-12)) 
        
        # Explicitly tell Pillow that Index 0 is transparent
        new_img.info['transparency'] = 0
        
        # Save as NEW filename
        base, ext = os.path.splitext(filename)
        out_name = f"{base}_conv{ext}"
        
        # Try optimizing to prompt palette reduction
        # Using transparency=0 arg in save might help
        # CRITICAL: Do NOT use optimize=True, it reorders palette! 
        # We need strict Index 0 = Background.
        new_img.save(out_name, optimize=False, bits=2, transparency=0) 
        # bits=2 hints to write 2-bit png? Worth a try.
        
        print(f"Converted {filename} -> {out_name}")
        
    except Exception as e:
        print(f"Error converting {filename}: {e}")

if __name__ == "__main__":
    files = ["bullet.png", "fighter.png", "asteroid_L.png", "asteroid_M.png", "asteroid_S.png"]
    for f in files:
        if os.path.exists(f):
            convert_to_atari_7800(f)
