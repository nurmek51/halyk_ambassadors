from pydantic import BaseModel
from typing import Optional


class AddressSchema(BaseModel):
    found: bool
    address: Optional[str] = None
    amenity: Optional[str] = None
    road: Optional[str] = None
    suburb: Optional[str] = None
    city_district: Optional[str] = None
    city: Optional[str] = None
    region: Optional[str] = None
    district: Optional[str] = None
    iso3166_2_lvl4: Optional[str] = None
    postcode: Optional[str] = None
    country: Optional[str] = None
    country_code: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    confidence: float = 0.0
