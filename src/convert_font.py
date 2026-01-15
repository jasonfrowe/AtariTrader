from PIL import Image

def convert_font():
    # Load Horizontal Strip
    img = Image.open("src/scoredigits_8_wide.png")
    w, h = img.size
    print(f"Original Size: {w}x{h}")
    
    char_w = 8
    char_h = h # Keep full height
    num_chars = w // char_w
    
    print(f"Detected {num_chars} characters of size {char_w}x{char_h}")
    
    # Create Vertical Strip
    new_w = char_w
    new_h = char_h * num_chars
    new_img = Image.new("RGBA", (new_w, new_h))
    
    for i in range(num_chars):
        # Crop char
        char_img = img.crop((i*char_w, 0, (i+1)*char_w, h))
        # Paste vertical
        new_img.paste(char_img, (0, i*char_h))
        
    new_img.save("src/scoredigits_vertical.png")
    print(f"Saved vertical font to src/scoredigits_vertical.png ({new_w}x{new_h})")

if __name__ == "__main__":
    convert_font()
