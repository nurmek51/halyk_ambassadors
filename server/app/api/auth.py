from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_session
from app.schemas.auth import (
    OTPRequestSchema, 
    OTPVerifySchema, 
    CheckVerificationSchema,
    OTPRequestResponseSchema,
    OTPVerifyResponseSchema,
    RefreshTokenSchema,
    RefreshTokenResponseSchema
)
from app.services.otp_service import OTPService
from app.services.auth_service import AuthService
from app.models import Account

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/request-otp", response_model=OTPRequestResponseSchema)
async def request_otp(
    request: OTPRequestSchema,
    db: AsyncSession = Depends(get_session)
):
    """Request OTP code for phone verification"""
    try:
        await OTPService.create_otp_request(db, request.phone_number)
        
        return OTPRequestResponseSchema(
            success=True,
            message='OTP sent successfully. Use code "1111" for verification.',
            phone_number=request.phone_number
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send OTP"
        )


@router.post("/verify-otp", response_model=OTPVerifyResponseSchema)
async def verify_otp(
    request: OTPVerifySchema,
    db: AsyncSession = Depends(get_session)
):
    """Verify OTP code and receive JWT tokens"""
    account = await OTPService.verify_otp(db, request.phone_number, request.otp_code)
    
    if not account:
        return OTPVerifyResponseSchema(
            phone_number=request.phone_number,
            is_verified=False,
            message="Invalid OTP code or phone number."
        )
    
    tokens = AuthService.create_tokens_for_account(account)
    
    return OTPVerifyResponseSchema(
        phone_number=request.phone_number,
        is_verified=True,
        message="Phone number verified successfully. You can now create your profile.",
        account_id=account.id,
        tokens=tokens
    )


@router.get("/check-verification", response_model=CheckVerificationSchema)
async def check_verification(
    phone_number: str = Query(...),
    db: AsyncSession = Depends(get_session)
):
    """Check if phone number is verified"""
    result = await db.execute(
        select(Account).where(Account.phone_number == phone_number)
    )
    account = result.scalar_one_or_none()
    
    if account and account.is_verified:
        return CheckVerificationSchema(
            phone_number=phone_number,
            is_verified=True,
            message="Phone number is verified"
        )
    
    return CheckVerificationSchema(
        phone_number=phone_number,
        is_verified=False,
        message="Phone number is not verified"
    )


@router.post("/refresh-token", response_model=RefreshTokenResponseSchema)
async def refresh_token(
    request: RefreshTokenSchema,
    db: AsyncSession = Depends(get_session)
):
    """Refresh access token using provided refresh token"""
    try:
        tokens = await AuthService.refresh_access_token(db, request.refresh_token)
        if not tokens:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )

        return RefreshTokenResponseSchema(
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            expires_in=tokens["expires_in"]
        )
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to refresh token"
        )
