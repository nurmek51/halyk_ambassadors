import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from unittest.mock import patch, AsyncMock
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


async def create_test_profile(client: AsyncClient) -> dict:
    """Helper function to create a test profile"""
    headers = await get_auth_headers(client)
    
    response = await client.post(
        "/api/accounts/profile/",
        json={
            "name": "Test",
            "surname": "User",
            "position": "Tester",
            "address_query": "Алматы"
        },
        headers=headers
    )
    
    return headers


@pytest.mark.asyncio
async def test_create_application_with_coordinates(client: AsyncClient, db_session: AsyncSession):
    """Test creating application with coordinates"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        response = await client.post(
            "/api/applications/",
            json={
                "description": "Проблема с освещением на улице",
                "image_urls": ["https://example.com/image1.jpg"],
                "latitude": 43.2220,
                "longitude": 76.8512
            },
            headers=headers
        )
    
    assert response.status_code == 201
    data = response.json()
    assert data["description"] == "Проблема с освещением на улице"
    assert data["status"] == "pending"
    assert data["image_count"] == 1
    assert "address" in data


@pytest.mark.asyncio
async def test_create_application_with_address_query(client: AsyncClient, db_session: AsyncSession):
    """Test creating application with address query"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.geocode_address_query') as mock_geocode:
        mock_geocode.return_value = AddressSchema(
            found=True,
            address="ул. Абая 150, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        response = await client.post(
            "/api/applications/",
            json={
                "description": "Яма на дороге",
                "image_urls": ["https://example.com/pothole.jpg"],
                "address_query": "Алматы, улица Абая 150"
            },
            headers=headers
        )
    
    assert response.status_code == 201
    data = response.json()
    assert data["description"] == "Яма на дороге"
    assert data["status"] == "pending"
    assert data["image_count"] == 1
    assert "address" in data


@pytest.mark.asyncio
async def test_create_application_without_location(client: AsyncClient):
    """Test creating application without location data"""
    headers = await create_test_profile(client)
    
    response = await client.post(
        "/api/applications/",
        json={
            "description": "Проблема без адреса",
            "image_urls": []
        },
        headers=headers
    )
    
    assert response.status_code == 400
    assert "Must provide either address_query or both latitude and longitude" in response.json()["detail"]


@pytest.mark.asyncio
async def test_create_application_too_many_images(client: AsyncClient):
    """Test creating application with too many images"""
    headers = await create_test_profile(client)
    
    image_urls = [f"https://example.com/image{i}.jpg" for i in range(11)]
    
    response = await client.post(
        "/api/applications/",
        json={
            "description": "Слишком много изображений",
            "image_urls": image_urls,
            "latitude": 43.2220,
            "longitude": 76.8512
        },
        headers=headers
    )
    
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_applications(client: AsyncClient, db_session: AsyncSession):
    """Test listing applications"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create a few applications
        for i in range(3):
            await client.post(
                "/api/applications/",
                json={
                    "description": f"Проблема {i}",
                    "image_urls": [],
                    "latitude": 43.2220 + i * 0.001,
                    "longitude": 76.8512 + i * 0.001
                },
                headers=headers
            )
    
    # List applications
    response = await client.get(
        "/api/applications/",
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3


@pytest.mark.asyncio
async def test_get_application_by_id(client: AsyncClient, db_session: AsyncSession):
    """Test getting specific application by ID"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create application
        create_response = await client.post(
            "/api/applications/",
            json={
                "description": "Тестовая проблема",
                "image_urls": [],
                "latitude": 43.2220,
                "longitude": 76.8512
            },
            headers=headers
        )
    
    app_id = create_response.json()["id"]
    
    # Get application
    response = await client.get(
        f"/api/applications/{app_id}/",
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["description"] == "Тестовая проблема"


@pytest.mark.asyncio
async def test_update_application_status(client: AsyncClient, db_session: AsyncSession):
    """Test updating application status"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create application
        create_response = await client.post(
            "/api/applications/",
            json={
                "description": "Проблема для обновления статуса",
                "image_urls": [],
                "latitude": 43.2220,
                "longitude": 76.8512
            },
            headers=headers
        )
    
    app_id = create_response.json()["id"]
    
    # Update status
    response = await client.put(
        f"/api/applications/{app_id}/status/",
        json={"status": "approved"},
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "approved"


@pytest.mark.asyncio
async def test_get_applications_by_status(client: AsyncClient, db_session: AsyncSession):
    """Test getting applications by status"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create applications with different статусы
        create_response = await client.post(
            "/api/applications/",
            json={
                "description": "Pending application",
                "image_urls": [],
                "latitude": 43.2220,
                "longitude": 76.8512
            },
            headers=headers
        )
    
    app_id = create_response.json()["id"]
    
    # Update one to approved
    await client.put(
        f"/api/applications/{app_id}/status/",
        json={"status": "approved"},
        headers=headers
    )
    
    # Get approved applications
    response = await client.get(
        "/api/applications/status/approved/",
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["status"] == "approved"


@pytest.mark.asyncio
async def test_get_application_stats(client: AsyncClient, db_session: AsyncSession):
    """Test getting application statistics"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create applications with different статусы
        app_ids = []
        for i in range(3):
            create_response = await client.post(
                "/api/applications/",
                json={
                    "description": f"Application {i}",
                    "image_urls": [],
                    "latitude": 43.2220 + i * 0.001,
                    "longitude": 76.8512 + i * 0.001
                },
                headers=headers
            )
            app_ids.append(create_response.json()["id"])
    
    # Update статусы
    await client.put(
        f"/api/applications/{app_ids[0]}/status/",
        json={"status": "approved"},
        headers=headers
    )
    await client.put(
        f"/api/applications/{app_ids[1]}/status/",
        json={"status": "rejected"},
        headers=headers
    )
    
    # Get stats
    response = await client.get(
        "/api/applications/stats/",
        headers=headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 3
    assert data["pending"] == 1
    assert data["approved"] == 1
    assert data["rejected"] == 1
    assert data["approval_rate"] == 50.0


@pytest.mark.asyncio
async def test_delete_application(client: AsyncClient, db_session: AsyncSession):
    """Test deleting application"""
    headers = await create_test_profile(client)
    
    with patch('app.services.geocoding_service.geocoding_service.reverse_geocode_to_address') as mock_reverse:
        mock_reverse.return_value = AddressSchema(
            found=True,
            address="ул. Абая, Алматы, Казахстан",
            city="Алматы",
            region="Алматы",
            country="Казахстан",
            latitude=43.2220,
            longitude=76.8512,
            confidence=0.9,
            amenity=None,
            road="ул. Абая",
            suburb=None,
            city_district="Медеуский район",
            iso3166_2_lvl4="KZ-75",
            postcode="050000",
            country_code="kz"
        )
        
        # Create application
        create_response = await client.post(
            "/api/applications/",
            json={
                "description": "Application to delete",
                "image_urls": [],
                "latitude": 43.2220,
                "longitude": 76.8512
            },
            headers=headers
        )
    
    app_id = create_response.json()["id"]
    
    # Delete application
    response = await client.delete(
        f"/api/applications/{app_id}/",
        headers=headers
    )
    
    assert response.status_code == 204
    
    # Verify deletion
    response = await client.get(
        f"/api/applications/{app_id}/",
        headers=headers
    )
    assert response.status_code == 404
