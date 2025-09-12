# Kazakhstan Address Service

This is a complete address service for Kazakhstan with geocoding, reverse geocoding, autocomplete, and geolocation features.

## Features

✅ **Geocoding** - Search coordinates by address  
✅ **Reverse Geocoding** - Get address from GPS coordinates  
✅ **Autocomplete** - Address suggestions as you type  
✅ **Geolocation** - Get precise address from device location  
✅ **Validation** - Check if coordinates are within Kazakhstan  

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Files Structure

- `address_service.py` - Main KazakhstanAddressService class
- `flask_app.py` - Flask web server with API endpoints
- `templates/index.html` - Web interface
- `test_address_service.py` - Test script to verify functionality
- `requirements.txt` - Python dependencies

## Running Tests

Run the test script to verify everything works:

```bash
python test_address_service.py
```

## Running the Web Server

Start the Flask development server:

```bash
python flask_app.py
```

Then open your browser to: http://localhost:5000

## API Endpoints

### POST /api/geocode
Search for coordinates by address text.

**Request:**
```json
{
  "query": "Алматы",
  "limit": 5
}
```

### POST /api/reverse-geocode
Get address from coordinates.

**Request:**
```json
{
  "latitude": 43.2220,
  "longitude": 76.8512,
  "zoom": 18
}
```

### GET /api/autocomplete
Get address suggestions for autocomplete.

**Request:**
```
GET /api/autocomplete?q=Аст&limit=5
```

### POST /api/geolocation-address
Get address from device geolocation.

**Request:**
```json
{
  "latitude": 43.2220,
  "longitude": 76.8512
}
```

## Usage Examples

### Basic Usage

```python
from address_service import KazakhstanAddressService

service = KazakhstanAddressService()

# Geocode an address
result = service.geocode_address("Алматы")
print(result)

# Reverse geocode coordinates
result = service.reverse_geocode(43.2220, 76.8512)
print(result)

# Get autocomplete suggestions
result = service.autocomplete_suggestions("Аст")
print(result)
```

## Notes

- The service uses Nominatim API with a 1-second delay between requests
- All coordinates are validated to be within Kazakhstan boundaries
- The web interface includes geolocation features for mobile devices
- For production use, consider using a dedicated geocoding service

## Future Integration

This service is designed to be easily integrated into Django projects. The main `KazakhstanAddressService` class can be used as a standalone service or integrated into Django views and models.
