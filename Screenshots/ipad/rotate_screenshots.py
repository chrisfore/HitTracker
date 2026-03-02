#!/usr/bin/env python3
"""
Rotate iPad screenshots from landscape (2752×2064) to portrait (2064×2752)
"""

from PIL import Image
import os

def rotate_screenshot(input_path, output_path):
    """Rotate image 90 degrees counterclockwise"""
    img = Image.open(input_path)
    rotated = img.rotate(90, expand=True)
    rotated.save(output_path)
    print(f"Rotated: {os.path.basename(output_path)} - {rotated.size[0]}×{rotated.size[1]}")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Find all PNG files
    png_files = [f for f in os.listdir(script_dir) if f.endswith('.png')]

    if not png_files:
        print("No PNG files found")
        return

    print(f"Found {len(png_files)} screenshots to rotate")

    for filename in png_files:
        input_path = os.path.join(script_dir, filename)
        output_path = os.path.join(script_dir, filename)

        try:
            rotate_screenshot(input_path, output_path)
        except Exception as e:
            print(f"Error rotating {filename}: {e}")

    print(f"\nCompleted! Rotated {len(png_files)} screenshots to 2064×2752")

if __name__ == "__main__":
    main()
