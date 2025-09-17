from pydantic import BaseModel, validator
from typing import Optional
import re
import uuid


class OTPRequestSchema(BaseModel):
    phone_number: str
    
    @validator('phone_number')
    def validate_phone_number(cls, v):
        pattern = r'^(\+77|87|7)\d{9}$'
        if not re.match(pattern, v):
            raise ValueError('Invalid Kazakhstan phone number format')
        return v


class OTPVerifySchema(BaseModel):
    phone_number: str
    otp_code: str
    
    @validator('phone_number')
    def validate_phone_number(cls, v):
        pattern = r'^(\+77|87|7)\d{9}$'
        if not re.match(pattern, v):
            raise ValueError('Invalid Kazakhstan phone number format')
        return v


class CheckVerificationSchema(BaseModel):
    phone_number: str
    is_verified: bool
    message: str


class TokenSchema(BaseModel):
    access: str
    refresh: str
    expires_in: int


class OTPRequestResponseSchema(BaseModel):
    success: bool
    message: str
    phone_number: str


class OTPVerifyResponseSchema(BaseModel):
    phone_number: str
    is_verified: bool
    message: str
    account_id: Optional[uuid.UUID] = None
    tokens: Optional[TokenSchema] = None


class RefreshTokenSchema(BaseModel):
    refresh_token: str


class RefreshTokenResponseSchema(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
