from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from jose import jwt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.config import settings
from app.models import Account
import uuid


class AuthService:
    @staticmethod
    def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(seconds=settings.jwt_access_token_lifetime)
        
        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow(),
            "jti": str(uuid.uuid4()),
            "token_type": "access"
        })
        
        encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
        return encoded_jwt
    
    @staticmethod
    def create_refresh_token(data: Dict[str, Any]) -> str:
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(seconds=settings.jwt_refresh_token_lifetime)
        
        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow(),
            "jti": str(uuid.uuid4()),
            "token_type": "refresh"
        })
        
        encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
        return encoded_jwt
    
    @staticmethod
    def verify_token(token: str) -> Optional[Dict[str, Any]]:
        try:
            payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
            return payload
        except jwt.JWTError:
            return None
    
    @staticmethod
    async def get_current_account(db: AsyncSession, token: str) -> Optional[Account]:
        payload = AuthService.verify_token(token)
        if not payload:
            return None
        
        account_id_str = payload.get("account_id")
        if not account_id_str:
            return None
        
        try:
            account_id = uuid.UUID(account_id_str)
        except ValueError:
            return None
        
        result = await db.execute(select(Account).where(Account.id == account_id))
        return result.scalar_one_or_none()
    
    @staticmethod
    def create_tokens_for_account(account: Account) -> Dict[str, Any]:
        token_data = {
            "account_id": str(account.id),
            "phone_number": account.phone_number,
            "is_verified": account.is_verified
        }
        
        access_token = AuthService.create_access_token(token_data)
        refresh_token = AuthService.create_refresh_token(token_data)
        
        return {
            "access": access_token,
            "refresh": refresh_token,
            "expires_in": settings.jwt_access_token_lifetime
        }
    
    @staticmethod
    def verify_refresh_token(token: str) -> Optional[Dict[str, Any]]:
        """Verify refresh token and return payload if valid"""
        payload = AuthService.verify_token(token)
        if not payload:
            return None
        
        # Check if it's a refresh token
        if payload.get("token_type") != "refresh":
            return None
            
        return payload
    
    @staticmethod
    async def refresh_access_token(db: AsyncSession, refresh_token: str) -> Optional[Dict[str, Any]]:
        """Refresh access token using refresh token"""
        payload = AuthService.verify_refresh_token(refresh_token)
        if not payload:
            return None
        
        account_id = payload.get("account_id")
        if not account_id:
            return None
        
        # Verify account still exists and is verified
        result = await db.execute(select(Account).where(Account.id == account_id))
        account = result.scalar_one_or_none()
        
        if not account or not account.is_verified:
            return None
        
        # Create new token pair
        token_data = {
            "account_id": str(account.id),
            "phone_number": account.phone_number,
            "is_verified": account.is_verified
        }
        
        new_access_token = AuthService.create_access_token(token_data)
        new_refresh_token = AuthService.create_refresh_token(token_data)
        
        return {
            "access_token": new_access_token,
            "refresh_token": new_refresh_token,
            "expires_in": settings.jwt_access_token_lifetime
        }
