from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from app.models import OTPRequest, Account
from app.core.config import settings


class OTPService:
    @staticmethod
    async def create_otp_request(db: AsyncSession, phone_number: str) -> OTPRequest:
        # Invalidate existing unused OTPs for this phone number
        await db.execute(
            update(OTPRequest)
            .where(OTPRequest.phone_number == phone_number, OTPRequest.is_used == False)
            .values(is_used=True)
        )
        await db.commit()  # Commit the invalidation immediately
        
        # Create new OTP request
        otp_request = OTPRequest(
            phone_number=phone_number,
            code="1111",  # Mock code for development
            expires_at=datetime.utcnow() + timedelta(minutes=5)
        )
        
        db.add(otp_request)
        await db.commit()
        await db.refresh(otp_request)
        
        # TODO: Integrate with Twilio for real SMS sending
        if not settings.twilio_mock_mode:
            await OTPService._send_real_sms(phone_number, otp_request.code)
        
        return otp_request
    
    @staticmethod
    async def verify_otp(db: AsyncSession, phone_number: str, otp_code: str) -> Optional[Account]:
        # Find valid OTP request
        result = await db.execute(
            select(OTPRequest)
            .where(
                OTPRequest.phone_number == phone_number,
                OTPRequest.code == otp_code,
                OTPRequest.is_used == False,
                OTPRequest.expires_at > datetime.utcnow()
            )
            .order_by(OTPRequest.created_at.desc())
        )
        
        otp_request = result.scalar_one_or_none()
        if not otp_request:
            return None
        
        # Mark OTP as used
        otp_request.is_used = True
        
        # Create or get account
        account_result = await db.execute(
            select(Account).where(Account.phone_number == phone_number)
        )
        account = account_result.scalar_one_or_none()
        
        if not account:
            account = Account(phone_number=phone_number, is_verified=True)
            db.add(account)
        else:
            account.is_verified = True
        
        await db.commit()
        await db.refresh(account)
        
        return account
    
    @staticmethod
    async def _send_real_sms(phone_number: str, code: str) -> bool:
        """
        Placeholder for Twilio SMS integration
        TODO: Implement actual Twilio SMS sending
        """
        # from twilio.rest import Client
        # client = Client(settings.twilio_account_sid, settings.twilio_auth_token)
        # message = client.messages.create(
        #     body=f"Your verification code is: {code}",
        #     from_=settings.twilio_from_number,
        #     to=phone_number
        # )
        # return message.sid is not None
        return True
