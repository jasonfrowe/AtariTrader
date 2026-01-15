from PIL import Image
import os

def split_font():
    # Load Horizontal Strip
    img = Image.open("src/scoredigits_8_wide.png")
    w, h = img.size
    print(f"Original Size: {w}x{h}")
    
    char_w = 8
    char_h = 16 # Force 16px height (Zone Height) to match hardware better
    # Note: Original was 17. We will wrap/crop to 16.
    
    num_chars = w // char_w
    print(f"Detected {num_chars} characters.")
    
    base_name = "src/scoredigits_s"
    
    output_files = []
    
    for i in range(num_chars):
        # Crop char
        # Use 16 height (ignoring 17th row)
        char_img = img.crop((i*char_w, 0, (i+1)*char_w, char_h))
        
        # Save as individual file
        # Name format: scoredigits_s00.png, scoredigits_s01.png ...
        # This ensures they sort correctly and basic imports them sequentially.
        fname = f"{base_name}{i:02d}.png"
        char_img.save(fname)
        output_files.append(fname)
        print(f"Saved {fname}")

if __name__ == "__main__":
    split_font()
