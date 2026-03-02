#!/usr/bin/env python3
"""
Resize screenshots to 1242x2688px for App Store submission
"""

from PIL import Image
import os

def resize_screenshot(input_path, output_path, target_size=(1242, 2688)):
    """Resize image to target size with proper aspect ratio"""

    # Open image
    img = Image.open(input_path)

    # Get current size
    original_width, original_height = img.size
    target_width, target_height = target_size

    print(f"Processing: {os.path.basename(input_path)}")
    print(f"  Original: {original_width}x{original_height}")

    # Calculate scaling to fill the target size
    width_ratio = target_width / original_width
    height_ratio = target_height / original_height

    # Use the larger ratio to ensure the image fills the canvas
    scale = max(width_ratio, height_ratio)

    # Calculate new size
    new_width = int(original_width * scale)
    new_height = int(original_height * scale)

    # Resize with high quality
    img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Create a new image with target size and paste the resized image centered
    final_img = Image.new('RGB', target_size, (255, 255, 255))

    # Calculate position to center the image
    paste_x = (target_width - new_width) // 2
    paste_y = (target_height - new_height) // 2

    final_img.paste(img_resized, (paste_x, paste_y))

    # Save
    final_img.save(output_path, 'PNG', quality=100)
    print(f"  Saved: {os.path.basename(output_path)} ({target_width}x{target_height})")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Find all PNG files
    screenshots = [f for f in os.listdir(script_dir) if f.endswith('.png') and not f.startswith('.')]
    screenshots.sort()

    if not screenshots:
        print("No screenshots found!")
        return

    print(f"Found {len(screenshots)} screenshots\n")

    # Resize each screenshot
    for i, screenshot in enumerate(screenshots, 1):
        input_path = os.path.join(script_dir, screenshot)

        # Create output filename
        output_filename = f"screenshot_{i:02d}.png"
        output_path = os.path.join(script_dir, output_filename)

        try:
            resize_screenshot(input_path, output_path, target_size=(1242, 2688))
        except Exception as e:
            print(f"  Error: {e}")

        print()

    print("✅ All screenshots resized to 1242x2688px")
    print("\nNew files:")
    for i in range(1, len(screenshots) + 1):
        print(f"  screenshot_{i:02d}.png")

if __name__ == "__main__":
    main()
