from pydantic import BaseModel, validator
from typing import List, Dict, Any, Optional


class GeocodeRequestSchema(BaseModel):
    query: str
    limit: int = 5
    
    @validator('limit')
    def validate_limit(cls, v):
        if v < 1 or v > 20:
            raise ValueError('Limit must be between 1 and 20')
        return v


class ReverseGeocodeRequestSchema(BaseModel):
    latitude: float
    longitude: float
    zoom: int = 18
    
    @validator('latitude')
    def validate_latitude(cls, v):
        if not (40 <= v <= 56):
            raise ValueError('Latitude must be between 40 and 56 for Kazakhstan')
        return v
    
    @validator('longitude')
    def validate_longitude(cls, v):
        if not (46 <= v <= 88):
            raise ValueError('Longitude must be between 46 and 88 for Kazakhstan')
        return v


class GeocodeResultSchema(BaseModel):
    display_name: str
    lat: str
    lon: str
    importance: float
    address: Dict[str, Any]


class GeocodeResponseSchema(BaseModel):
    success: bool
    results: List[GeocodeResultSchema] = []


class ReverseGeocodeResponseSchema(BaseModel):
    success: bool
    display_name: Optional[str] = None
    address: Optional[Dict[str, Any]] = None
    lat: Optional[str] = None
    lon: Optional[str] = None


class AutocompleteSuggestionSchema(BaseModel):
    display_name: str
    lat: str
    lon: str


class AutocompleteResponseSchema(BaseModel):
    success: bool
    suggestions: List[AutocompleteSuggestionSchema] = []
