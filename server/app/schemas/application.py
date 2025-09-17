from pydantic import BaseModel, validator
from typing import Optional, List
from datetime import datetime
import uuid
from .address import AddressSchema


class ApplicationCreateSchema(BaseModel):
    description: str
    image_urls: List[str] = []
    address_query: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    
    @validator('image_urls')
    def validate_image_urls(cls, v):
        if len(v) > 10:
            raise ValueError('Maximum 10 image URLs allowed')
        for url in v:
            if len(url) > 500:
                raise ValueError('Image URL too long (max 500 characters)')
        return v
    
    @validator('latitude')
    def validate_latitude(cls, v):
        if v is not None and not (40 <= v <= 56):
            raise ValueError('Latitude must be between 40 and 56 for Kazakhstan')
        return v
    
    @validator('longitude')
    def validate_longitude(cls, v):
        if v is not None and not (46 <= v <= 88):
            raise ValueError('Longitude must be between 46 and 88 for Kazakhstan')
        return v


class ApplicationUpdateSchema(BaseModel):
    description: Optional[str] = None
    image_urls: Optional[List[str]] = None
    address_query: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    
    @validator('image_urls')
    def validate_image_urls(cls, v):
        if v is not None:
            if len(v) > 10:
                raise ValueError('Maximum 10 image URLs allowed')
            for url in v:
                if len(url) > 500:
                    raise ValueError('Image URL too long (max 500 characters)')
        return v


class ApplicationStatusUpdateSchema(BaseModel):
    status: str
    
    @validator('status')
    def validate_status(cls, v):
        if v not in ['pending', 'approved', 'rejected']:
            raise ValueError('Status must be pending, approved, or rejected')
        return v


class ApplicationResponseSchema(BaseModel):
    id: uuid.UUID
    user_profile_id: uuid.UUID
    address: dict
    description: str
    image_urls: List[str]
    status: str
    address_display: str
    image_count: int
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class ApplicationStatsSchema(BaseModel):
    total: int
    pending: int
    approved: int
    rejected: int
    approval_rate: float
