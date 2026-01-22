from PIL import Image
import os

def split_arrows():
    try:
        # Load the image
        img_path = 'src/graphics/arrows.png'
        if not os.path.exists(img_path):
            print(f"Error: {img_path} not found.")
            return

        img = Image.open(img_path)
        width, height = img.size
        print(f"Original image size: {width}x{height}")

        # Assuming 4 frames horizontally
        frame_width = width // 4
        frame_height = height
        
        print(f"Splitting into 4 frames of {frame_width}x{frame_height}")

        frames = []
        for i in range(4):
            left = i * frame_width
            upper = 0
            right = left + frame_width
            lower = frame_height
            
            box = (left, upper, right, lower)
            frame = img.crop(box)
            
            # Save individually
            out_path = f'src/graphics/arrows_0{i+1}.png'
            frame.save(out_path)
            print(f"Saved {out_path}")
            
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    split_arrows()
