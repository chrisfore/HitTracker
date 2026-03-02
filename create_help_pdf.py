#!/usr/bin/env python3
"""
Convert Hit Track Pro help documentation from HTML to PDF
"""

import subprocess
import sys
from pathlib import Path

def create_pdf():
    """Convert HTML help documentation to PDF using wkhtmltopdf or weasyprint"""

    html_file = Path("HitTrackPro_Help_Documentation.html")
    pdf_file = Path("HitTrackPro_Help_Documentation.pdf")

    if not html_file.exists():
        print(f"❌ Error: {html_file} not found")
        sys.exit(1)

    # Try wkhtmltopdf first
    try:
        result = subprocess.run(
            ["wkhtmltopdf", "--quiet", str(html_file), str(pdf_file)],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"✅ PDF created successfully: {pdf_file}")
            return
    except FileNotFoundError:
        pass

    # Try weasyprint
    try:
        from weasyprint import HTML
        HTML(str(html_file)).write_pdf(str(pdf_file))
        print(f"✅ PDF created successfully: {pdf_file}")
        return
    except ImportError:
        pass

    # Try macOS textutil and cupsfilter
    try:
        # Convert HTML to RTF then to PDF
        rtf_file = Path("temp_help.rtf")
        subprocess.run(["textutil", "-convert", "rtf", str(html_file), "-output", str(rtf_file)], check=True)
        subprocess.run(["cupsfilter", str(rtf_file)], stdout=open(pdf_file, 'wb'), check=True)
        rtf_file.unlink()
        print(f"✅ PDF created successfully: {pdf_file}")
        return
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    print("❌ Error: No PDF converter found")
    print("Install one of:")
    print("  - wkhtmltopdf: brew install wkhtmltopdf")
    print("  - weasyprint: pip install weasyprint")
    sys.exit(1)

if __name__ == "__main__":
    create_pdf()
