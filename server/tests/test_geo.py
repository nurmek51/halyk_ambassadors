import pytest
from httpx import AsyncClient
from unittest.mock import patch, AsyncMock


@pytest.mark.asyncio
async def test_geocode_endpoint(client: AsyncClient):
    """Test geocoding endpoint"""
    with patch('app.services.geocoding_service.geocoding_service.geocode') as mock_geocode:
        mock_geocode.return_value = [
            {
                "display_name": "Алматы, Казахстан",
                "lat": "43.2220",
                "lon": "76.8512",
                "importance": 0.95,
                "address": {
                    "city": "Алматы",
                    "country": "Казахстан"
                }
            }
        ]
        
        response = await client.post(
            "/api/geo/geocode",
            json={
                "query": "Алматы",
                "limit": 5
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert len(data["results"]) == 1
        assert data["results"][0]["display_name"] == "Алматы, Казахстан"


@pytest.mark.asyncio
async def test_reverse_geocode_endpoint(client: AsyncClient):
    """Test reverse geocoding endpoint"""
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode') as mock_reverse:
        mock_reverse.return_value = {
            "display_name": "223, проспект Назарбаева, Алматы, Казахстан",
            "lat": "43.2220",
            "lon": "76.8512",
            "address": {
                "house_number": "223",
                "road": "проспект Назарбаева",
                "city": "Алматы",
                "country": "Казахстан"
            }
        }
        
        response = await client.post(
            "/api/geo/reverse-geocode",
            json={
                "latitude": 43.2220,
                "longitude": 76.8512,
                "zoom": 18
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert data["display_name"] == "223, проспект Назарбаева, Алматы, Казахстан"


@pytest.mark.asyncio
async def test_reverse_geocode_invalid_coordinates(client: AsyncClient):
    """Test reverse geocoding with invalid coordinates"""
    response = await client.post(
        "/api/geo/reverse-geocode",
        json={
            "latitude": 100.0,  # Invalid latitude
            "longitude": 76.8512,
            "zoom": 18
        }
    )
    
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_autocomplete_endpoint(client: AsyncClient):
    """Test autocomplete endpoint"""
    with patch('app.services.geocoding_service.geocoding_service.autocomplete') as mock_autocomplete:
        mock_autocomplete.return_value = [
            {
                "display_name": "проспект Назарбаева, Алматы, Казахстан",
                "lat": "43.2220",
                "lon": "76.8512"
            }
        ]
        
        response = await client.get(
            "/api/geo/autocomplete?q=Назарбаева&limit=5"
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert len(data["suggestions"]) == 1
        assert "Назарбаева" in data["suggestions"][0]["display_name"]


@pytest.mark.asyncio
async def test_geolocation_address_endpoint(client: AsyncClient):
    """Test geolocation address endpoint"""
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode') as mock_reverse:
        mock_reverse.return_value = {
            "display_name": "Алматы, Казахстан",
            "lat": "43.2220",
            "lon": "76.8512",
            "address": {
                "city": "Алматы",
                "country": "Казахстан"
            }
        }
        
        response = await client.post(
            "/api/geo/geolocation-address",
            json={
                "latitude": 43.2220,
                "longitude": 76.8512,
                "zoom": 18
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert data["display_name"] == "Алматы, Казахстан"


@pytest.mark.asyncio
async def test_geocode_invalid_limit(client: AsyncClient):
    """Test geocoding with invalid limit"""
    response = await client.post(
        "/api/geo/geocode",
        json={
            "query": "Алматы",
            "limit": 25  # Too high
        }
    )
    
    assert response.status_code == 422
