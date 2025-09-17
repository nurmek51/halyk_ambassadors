from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    # Database
    database_url: str
    
    # JWT Settings
    secret_key: str
    jwt_access_token_lifetime: int
    jwt_refresh_token_lifetime: int
    algorithm: str
    
    # Twilio Settings
    twilio_account_sid: str
    twilio_auth_token: str
    twilio_from_number: str
    twilio_mock_mode: bool
    
    # API Settings
    cors_allowed_origins: List[str]
    debug: bool
    allowed_hosts: List[str]
    
    # Nominatim API
    nominatim_base_url: str
    nominatim_user_agent: str
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()