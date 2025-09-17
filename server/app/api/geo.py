from fastapi import APIRouter, Depends, Query
from app.schemas.geo import (
    GeocodeRequestSchema,
    GeocodeResponseSchema,
    ReverseGeocodeRequestSchema,
    ReverseGeocodeResponseSchema,
    AutocompleteResponseSchema,
    GeocodeResultSchema,
    AutocompleteSuggestionSchema
)
from app.services.geocoding_service import geocoding_service

router = APIRouter(prefix="/api/geo", tags=["Geolocation"])


@router.post("/geocode", response_model=GeocodeResponseSchema)
async def geocode(request: GeocodeRequestSchema):
    """Search coordinates by address"""
    results = await geocoding_service.geocode(request.query, request.limit)
    
    geocode_results = []
    for result in results:
        geocode_results.append(GeocodeResultSchema(
            display_name=result.get("display_name", ""),
            lat=result.get("lat", ""),
            lon=result.get("lon", ""),
            importance=float(result.get("importance", 0.0)),
            address=result.get("address", {})
        ))
    
    return GeocodeResponseSchema(
        success=True,
        results=geocode_results
    )


@router.post("/reverse-geocode", response_model=ReverseGeocodeResponseSchema)
async def reverse_geocode(request: ReverseGeocodeRequestSchema):
    """Get address by coordinates"""
    result = await geocoding_service.reverse_geocode(
        request.latitude, 
        request.longitude, 
        request.zoom
    )
    
    if result:
        return ReverseGeocodeResponseSchema(
            success=True,
            display_name=result.get("display_name"),
            address=result.get("address", {}),
            lat=result.get("lat"),
            lon=result.get("lon")
        )
    
    return ReverseGeocodeResponseSchema(success=False)


@router.get("/autocomplete", response_model=AutocompleteResponseSchema)
async def autocomplete(
    q: str = Query(..., description="Search query"),
    limit: int = Query(5, ge=1, le=20, description="Max results")
):
    """Address autocomplete suggestions"""
    results = await geocoding_service.autocomplete(q, limit)
    
    suggestions = []
    for result in results:
        suggestions.append(AutocompleteSuggestionSchema(
            display_name=result.get("display_name", ""),
            lat=result.get("lat", ""),
            lon=result.get("lon", "")
        ))
    
    return AutocompleteResponseSchema(
        success=True,
        suggestions=suggestions
    )


@router.post("/geolocation-address", response_model=ReverseGeocodeResponseSchema)
async def geolocation_address(request: ReverseGeocodeRequestSchema):
    """Get address from device geolocation"""
    # This is the same as reverse geocoding
    return await reverse_geocode(request)
