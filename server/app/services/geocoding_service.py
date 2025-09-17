import asyncio
from typing import Optional, List, Dict, Any
import httpx
from app.core.config import settings
from app.schemas.address import AddressSchema


class GeocodingService:
    def __init__(self):
        self.base_url = settings.nominatim_base_url
        self.user_agent = settings.nominatim_user_agent
        self._last_request_time = 0
        
    async def _rate_limit(self):
        """Ensure 1 request per second rate limit for Nominatim"""
        import time
        current_time = time.time()
        time_since_last = current_time - self._last_request_time
        if time_since_last < 1.0:
            await asyncio.sleep(1.0 - time_since_last)
        self._last_request_time = time.time()
    
    async def geocode(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search coordinates by address"""
        await self._rate_limit()
        
        params = {
            "q": query,
            "format": "json",
            "addressdetails": 1,
            "limit": limit,
            "countrycodes": "kz",
            "accept-language": "ru,kk,en"
        }
        
        headers = {"User-Agent": self.user_agent}
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    f"{self.base_url}/search",
                    params=params,
                    headers=headers,
                    timeout=10.0
                )
                response.raise_for_status()
                return response.json()
            except Exception:
                return []
    
    async def reverse_geocode(self, latitude: float, longitude: float, zoom: int = 18) -> Optional[Dict[str, Any]]:
        """Get address by coordinates"""
        await self._rate_limit()
        
        params = {
            "lat": latitude,
            "lon": longitude,
            "format": "json",
            "addressdetails": 1,
            "zoom": zoom,
            "accept-language": "ru,kk,en"
        }
        
        headers = {"User-Agent": self.user_agent}
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    f"{self.base_url}/reverse",
                    params=params,
                    headers=headers,
                    timeout=10.0
                )
                response.raise_for_status()
                return response.json()
            except Exception:
                return None
    
    async def autocomplete(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Get address autocomplete suggestions"""
        return await self.geocode(query, limit)
    
    def _parse_nominatim_address(self, data: Dict[str, Any]) -> AddressSchema:
        """Parse Nominatim response to AddressSchema"""
        if not data:
            return AddressSchema(found=False)
        
        address_data = data.get("address", {})
        
        # Build full address string
        address_parts = []
        if address_data.get("house_number"):
            address_parts.append(address_data["house_number"])
        if address_data.get("road"):
            address_parts.append(address_data["road"])
        if address_data.get("suburb"):
            address_parts.append(address_data["suburb"])
        if address_data.get("city_district"):
            address_parts.append(address_data["city_district"])
        if address_data.get("city") or address_data.get("town") or address_data.get("village"):
            city = address_data.get("city") or address_data.get("town") or address_data.get("village")
            address_parts.append(city)
        if address_data.get("region") or address_data.get("state"):
            region = address_data.get("region") or address_data.get("state")
            address_parts.append(region)
        if address_data.get("country"):
            address_parts.append(address_data["country"])
        
        full_address = ", ".join(address_parts) if address_parts else data.get("display_name", "")
        
        return AddressSchema(
            found=True,
            address=full_address,
            amenity=address_data.get("amenity"),
            road=address_data.get("road"),
            suburb=address_data.get("suburb"),
            city_district=address_data.get("city_district"),
            city=address_data.get("city") or address_data.get("town") or address_data.get("village"),
            region=address_data.get("state") or address_data.get("region"),
            district=address_data.get("county") or address_data.get("district"),
            iso3166_2_lvl4=address_data.get("ISO3166-2-lvl4"),
            postcode=address_data.get("postcode"),
            country=address_data.get("country"),
            country_code=address_data.get("country_code"),
            latitude=float(data["lat"]) if data.get("lat") else None,
            longitude=float(data["lon"]) if data.get("lon") else None,
            confidence=float(data.get("importance", 0.0))
        )
    
    async def geocode_address_query(self, query: str) -> AddressSchema:
        """Geocode address query and return AddressSchema"""
        results = await self.geocode(query, limit=1)
        if results:
            return self._parse_nominatim_address(results[0])
        return AddressSchema(found=False)
    
    async def reverse_geocode_to_address(self, latitude: float, longitude: float) -> AddressSchema:
        """Reverse geocode coordinates and return AddressSchema"""
        result = await self.reverse_geocode(latitude, longitude)
        if result:
            return self._parse_nominatim_address(result)
        return AddressSchema(found=False)


# Global instance
geocoding_service = GeocodingService()
