#!/usr/bin/env python3
"""
Quick run script for Kazakhstan Address Service
"""

import os
import sys

def main():
    print("🇰🇿 Kazakhstan Address Service")
    print("=" * 40)

    if len(sys.argv) > 1 and sys.argv[1] == "test":
        print("Running tests...")
        os.system("python test_address_service.py")
    else:
        print("Starting Flask web server...")
        print("Open http://localhost:5000 in your browser")
        print("Press Ctrl+C to stop the server")
        print()
        os.system("python flask_app.py")

if __name__ == "__main__":
    main()
