import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from unittest.mock import patch

from app.schemas.address import AddressSchema


async def get_auth_headers(client: AsyncClient) -> dict:
    """Helper function to get authentication headers"""
    # Request OTP
    await client.post(
        "/auth/request-otp",
        json={"phone_number": "+77771234567"}
    )
    
    # Verify OTP and get tokens
    response = await client.post(
        "/auth/verify-otp",
        json={
            "phone_number": "+77771234567",
            "otp_code": "1111"
        }
    )
    
    tokens = response.json()["tokens"]
    return {"Authorization": f"Bearer {tokens['access']}"}


@pytest.mark.asyncio
async def test_create_profile_success(client: AsyncClient, db_session: AsyncSession):
    """Test successful profile creation"""
    headers = await get_auth_headers(client)
    
    with patch('app.services.geocoding_service.geocoding_service.geocode_address_query') as mock_geocode:
        mock_geocode.return_value = AddressSchema(
            found=True,
            address="Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road=None,
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        response = await client.post(
            "/api/accounts/profile/",
            json={
                "name": "Айдар",
                "surname": "Назарбаев",
                "position": "Менеджер",
                "address_query": "Алматы"
            },
            headers=headers
        )
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Айдар"
    assert data["surname"] == "Назарбаев"
    assert data["position"] == "Менеджер"
    assert data["full_name"] == "Айдар Назарбаев"
    assert data["phone_number"] == "+77771234567"
    assert data["applications_count"] == 0


@pytest.mark.asyncio
async def test_create_profile_without_auth(client: AsyncClient):
    """Test profile creation without authentication"""
    response = await client.post(
        "/api/accounts/profile/",
        json={
            "name": "Айдар",
            "surname": "Назарбаев",
            "position": "Менеджер"
        }
    )
    
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_get_my_profile_success(client: AsyncClient, db_session: AsyncSession):
    """Test getting current user's profile"""
    headers = await get_auth_headers(client)
    
    # Create profile first
    await client.post(
        "/api/accounts/profile/",
        json={
            "name": "Айдар",
            "surname": "Назарбаев",
            "position": "Менеджер"
        },
        headers=headers
    )
    
    # Get profile
    response = await client.get(
        "/api/accounts/profile/me/",
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Айдар"
    assert data["surname"] == "Назарбаев"
    assert data["applications_count"] == 0


@pytest.mark.asyncio
async def test_get_my_profile_not_found(client: AsyncClient):
    """Test getting profile when it doesn't exist"""
    headers = await get_auth_headers(client)
    
    response = await client.get(
        "/api/accounts/profile/me/",
        headers=headers
    )
    
    assert response.status_code == 404
    assert "Profile not found" in response.json()["detail"]


@pytest.mark.asyncio
async def test_update_profile_success(client: AsyncClient, db_session: AsyncSession):
    """Test successful profile update"""
    headers = await get_auth_headers(client)
    
    # Create profile first
    await client.post(
        "/api/accounts/profile/",
        json={
            "name": "Айдар",
            "surname": "Назарбаев",
            "position": "Менеджер"
        },
        headers=headers
    )
    
    # Update profile
    response = await client.put(
        "/api/accounts/profile/me/",
        json={
            "name": "Нурлан",
            "surname": "Назарбаев",
            "position": "Старший менеджер"
        },
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Нурлан"
    assert data["position"] == "Старший менеджер"
    assert data["full_name"] == "Нурлан Назарбаев"
    assert data["applications_count"] == 0


@pytest.mark.asyncio
async def test_delete_profile_success(client: AsyncClient, db_session: AsyncSession):
    """Test successful profile deletion"""
    headers = await get_auth_headers(client)
    
    # Create profile first
    await client.post(
        "/api/accounts/profile/",
        json={
            "name": "Айдар",
            "surname": "Назарбаев",
            "position": "Менеджер"
        },
        headers=headers
    )
    
    # Delete profile
    response = await client.delete(
        "/api/accounts/profile/me/",
        headers=headers
    )
    
    assert response.status_code == 204
    
    # Verify profile is deleted
    response = await client.get(
        "/api/accounts/profile/me/",
        headers=headers
    )
    assert response.status_code == 404
