import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import Account, OTPRequest


@pytest.mark.asyncio
async def test_request_otp_valid_phone(client: AsyncClient):
    """Test OTP request with valid Kazakhstan phone number"""
    response = await client.post(
        "/auth/request-otp",
        json={"phone_number": "87771234567"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["phone_number"] == "87771234567"
    assert "OTP sent successfully" in data["message"]


@pytest.mark.asyncio
async def test_request_otp_invalid_phone(client: AsyncClient):
    """Test OTP request with invalid phone number"""
    response = await client.post(
        "/auth/request-otp",
        json={"phone_number": "invalid_phone"}
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_verify_otp_success(client: AsyncClient, db_session: AsyncSession):
    """Test successful OTP verification"""
    # First request OTP
    await client.post(
        "/auth/request-otp",
        json={"phone_number": "87771234567"}
    )
    
    # Then verify OTP
    response = await client.post(
        "/auth/verify-otp",
        json={
            "phone_number": "87771234567",
            "otp_code": "1111"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_verified"] is True
    assert data["phone_number"] == "87771234567"
    assert data["account_id"] is not None
    assert "tokens" in data
    assert "access" in data["tokens"]
    assert "refresh" in data["tokens"]


@pytest.mark.asyncio
async def test_verify_otp_invalid_code(client: AsyncClient):
    """Test OTP verification with invalid code"""
    # First request OTP
    await client.post(
        "/auth/request-otp",
        json={"phone_number": "87771234567"}
    )
    
    # Then verify OTP with wrong code
    response = await client.post(
        "/auth/verify-otp",
        json={
            "phone_number": "87771234567",
            "otp_code": "1234"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_verified"] is False
    assert data["phone_number"] == "87771234567"
    assert "Invalid OTP code" in data["message"]


@pytest.mark.asyncio
async def test_check_verification_verified(client: AsyncClient):
    """Test checking verification status for verified account"""
    # First request and verify OTP
    await client.post(
        "/auth/request-otp",
        json={"phone_number": "87771234567"}
    )
    await client.post(
        "/auth/verify-otp",
        json={
            "phone_number": "87771234567",
            "otp_code": "1111"
        }
    )
    
    # Check verification status
    response = await client.get(
        "/auth/check-verification?phone_number=87771234567"
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_verified"] is True
    assert data["phone_number"] == "87771234567"
    assert "Phone number is verified" in data["message"]


@pytest.mark.asyncio
async def test_check_verification_not_verified(client: AsyncClient):
    """Test checking verification status for unverified account"""
    response = await client.get(
        "/auth/check-verification?phone_number=87771234568"
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_verified"] is False
    assert data["phone_number"] == "87771234568"
    assert "Phone number is not verified" in data["message"]


@pytest.mark.asyncio
async def test_refresh_token_success(client: AsyncClient):
    """Test successful token refresh"""
    # First verify OTP to get tokens
    await client.post(
        "/auth/request-otp",
        json={"phone_number": "87771234567"}
    )
    response = await client.post(
        "/auth/verify-otp",
        json={
            "phone_number": "87771234567",
            "otp_code": "1111"
        }
    )
    data = response.json()
    refresh_token = data["tokens"]["refresh"]
    
    # Now refresh the token
    response = await client.post(
        "/auth/refresh-token",
        json={"refresh_token": refresh_token}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert "expires_in" in data
    assert data["expires_in"] == 3600  # Assuming default


@pytest.mark.asyncio
async def test_refresh_token_invalid(client: AsyncClient):
    """Test refresh with invalid token"""
    response = await client.post(
        "/auth/refresh-token",
        json={"refresh_token": "invalid_token"}
    )
    assert response.status_code == 401
    data = response.json()
    assert "Invalid or expired refresh token" in data["detail"]
