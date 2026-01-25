import os
from PIL import Image

def split_boss_sprite():
    base_path = "src/graphics"
    input_file = os.path.join(base_path, "BossV2.png")
    
    if not os.path.exists(input_file):
        print(f"Error: {input_file} not found.")
        return

    try:
        img = Image.open(input_file)
        width, height = img.size
        
        if width != 32 or height != 32:
            print(f"Warning: Expected 32x32, found {width}x{height}")

        # Quadrants
        # 01: Top-Left (0,0,16,16)
        # 02: Top-Right (16,0,32,16)
        # 03: Bottom-Left (0,16,16,32)
        # 04: Bottom-Right (16,16,32,32)
        
        quadrants = [
            (0, 0, 16, 16, "BossV2_01.png"),
            (16, 0, 32, 16, "BossV2_02.png"),
            (0, 16, 16, 32, "BossV2_03.png"),
            (16, 16, 32, 32, "BossV2_04.png")
        ]
        
        for x1, y1, x2, y2, filename in quadrants:
            crop = img.crop((x1, y1, x2, y2))
            output_path = os.path.join(base_path, filename)
            crop.save(output_path)
            print(f"Saved {output_path}")
            
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    split_boss_sprite()
