#!/usr/bin/env python3
"""
Test script for Kazakhstan Address Service
This script demonstrates the functionality of the address service
"""

import sys
import os

# Add the current directory to the path so we can import address_service
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from address_service import KazakhstanAddressService

def test_geocode():
    """Test geocoding functionality"""
    print("🧪 Testing Geocoding...")
    service = KazakhstanAddressService()

    # Test with a Kazakh city
    result = service.geocode_address("Алматы", limit=3)
    if result['success']:
        print(f"✅ Found {result['count']} locations for 'Алматы'")
        for i, loc in enumerate(result['locations'][:2]):
            print(f"  {i+1}. {loc['display_name']} - {loc['latitude']}, {loc['longitude']}")
    else:
        print(f"❌ Geocoding failed: {result['error']}")

def test_reverse_geocode():
    """Test reverse geocoding functionality"""
    print("\n🧪 Testing Reverse Geocoding...")
    service = KazakhstanAddressService()

    # Coordinates for Almaty (approximate)
    lat, lon = 43.2220, 76.8512
    result = service.reverse_geocode(lat, lon)
    if result['success']:
        addr = result['address']
        print(f"✅ Address for {lat}, {lon}:")
        print(f"  📍 {addr['display_name']}")
        print(f"  🏙️ {addr['city']}, {addr['region']}")
    else:
        print(f"❌ Reverse geocoding failed: {result['error']}")

def test_autocomplete():
    """Test autocomplete functionality"""
    print("\n🧪 Testing Autocomplete...")
    service = KazakhstanAddressService()

    result = service.autocomplete_suggestions("Аст", limit=3)
    if result['success']:
        print(f"✅ Found {len(result['suggestions'])} suggestions for 'Аст'")
        for suggestion in result['suggestions'][:2]:
            print(f"  💡 {suggestion['short_text']} - {suggestion['city']}")
    else:
        print(f"❌ Autocomplete failed: {result['error']}")

def test_validation():
    """Test coordinate validation"""
    print("\n🧪 Testing Coordinate Validation...")
    service = KazakhstanAddressService()

    # Valid coordinates (Almaty)
    valid = service.validate_coordinates(43.2220, 76.8512)
    print(f"✅ Almaty coordinates valid: {valid}")

    # Invalid coordinates (outside Kazakhstan)
    invalid = service.validate_coordinates(55.7558, 37.6173)  # Moscow
    print(f"❌ Moscow coordinates valid: {invalid}")

def test_geolocation():
    """Test geolocation functionality"""
    print("\n🧪 Testing Geolocation...")
    service = KazakhstanAddressService()

    # Test with Almaty coordinates
    result = service.get_address_from_geolocation(43.2220, 76.8512)
    if result['success']:
        addr = result['address']
        print(f"✅ Geolocation address:")
        print(f"  📍 {addr['display_name']}")
    else:
        print(f"❌ Geolocation failed: {result['error']}")

def main():
    """Run all tests"""
    print("🇰🇿 Kazakhstan Address Service - Test Suite")
    print("=" * 50)

    try:
        test_geocode()
        test_reverse_geocode()
        test_autocomplete()
        test_validation()
        test_geolocation()

        print("\n" + "=" * 50)
        print("🎉 All tests completed!")
        print("\nTo run the Flask web server:")
        print("  python flask_app.py")
        print("Then open http://localhost:5000 in your browser")

    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        print("Make sure all dependencies are installed:")
        print("  pip install -r requirements.txt")

if __name__ == "__main__":
    main()
