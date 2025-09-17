from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
import uuid
from .address import AddressSchema


class UserProfileCreateSchema(BaseModel):
    name: str
    surname: str
    position: str
    address_query: Optional[str] = None


class UserProfileUpdateSchema(BaseModel):
    name: Optional[str] = None
    surname: Optional[str] = None
    position: Optional[str] = None
    address_query: Optional[str] = None


class UserProfileResponseSchema(BaseModel):
    id: uuid.UUID
    phone_number: str
    name: str
    surname: str
    position: str
    address: Optional[AddressSchema] = None
    full_name: str
    address_display: str
    applications_count: int = 0
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
