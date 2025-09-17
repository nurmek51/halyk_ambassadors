from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from typing import List, Optional
import uuid
from app.db.base import get_session
from app.core.dependencies import get_current_account
from app.schemas.application import (
    ApplicationCreateSchema,
    ApplicationResponseSchema,
    ApplicationUpdateSchema,
    ApplicationStatusUpdateSchema,
    ApplicationStatsSchema
)
from app.schemas.address import AddressSchema
from app.models import Account, Application, UserProfile
from app.services.geocoding_service import geocoding_service

router = APIRouter(prefix="/api/applications", tags=["Applications"])


@router.get("/", response_model=List[ApplicationResponseSchema])
async def list_applications(
    status_filter: Optional[str] = Query(None, alias="status"),
    ordering: Optional[str] = Query("created_at"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """List all applications for current user with filtering and pagination"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    query = select(Application).where(Application.user_profile_id == profile.id)
    
    # Apply status filter
    if status_filter:
        if status_filter not in ['pending', 'approved', 'rejected']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid status filter"
            )
        query = query.where(Application.status == status_filter)
    
    # Apply ordering
    if ordering == "created_at":
        query = query.order_by(Application.created_at)
    elif ordering == "-created_at":
        query = query.order_by(Application.created_at.desc())
    elif ordering == "status":
        query = query.order_by(Application.status)
    elif ordering == "-status":
        query = query.order_by(Application.status.desc())
    
    # Apply pagination
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    result = await db.execute(query)
    applications = result.scalars().all()
    
    return [
        ApplicationResponseSchema(
            id=app.id,
            user_profile_id=app.user_profile_id,
            address=app.address,
            description=app.description,
            image_urls=app.image_urls,
            status=app.status,
            address_display=app.address_display,
            image_count=app.image_count,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


@router.post("/", response_model=ApplicationResponseSchema, status_code=status.HTTP_201_CREATED)
async def create_application(
    application_data: ApplicationCreateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Create new application for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found. Please create a profile first."
        )
    
    # Validate that either address_query or coordinates are provided
    has_address_query = bool(application_data.address_query)
    has_coordinates = bool(application_data.latitude and application_data.longitude)
    
    if not (has_address_query or has_coordinates):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Must provide either address_query or both latitude and longitude"
        )
    
    # Geocode address
    address_data = None
    if has_address_query:
        address_data = await geocoding_service.geocode_address_query(application_data.address_query)
    elif has_coordinates:
        address_data = await geocoding_service.reverse_geocode_to_address(
            application_data.latitude, application_data.longitude
        )
    
    if not address_data or not address_data.found:
        # Create basic address data with coordinates if available
        address_data = {
            "found": False,
            "address": application_data.address_query or "Координаты не найдены",
            "latitude": application_data.latitude,
            "longitude": application_data.longitude,
            "confidence": 0.0
        }
    else:
        address_data = address_data.model_dump()
    
    # Compare cities and update user profile if different
    if address_data.get("found") and address_data.get("city"):
        new_city = address_data["city"]
        
        # Get current user city from profile
        current_address = profile.address
        if isinstance(current_address, dict) and current_address.get("city"):
            current_city = current_address["city"]
            
            # Update only if cities are different
            if current_city != new_city:
                # Create new address with only city field, others become empty
                updated_address = {
                    "found": True,
                    "address": new_city,
                    "city": new_city,
                    "amenity": None,
                    "road": None,
                    "suburb": None,
                    "city_district": None,
                    "region": None,
                    "district": None,
                    "iso3166_2_lvl4": None,
                    "postcode": None,
                    "country": None,
                    "country_code": None,
                    "latitude": None,
                    "longitude": None,
                    "confidence": 0.0
                }
                profile.address = updated_address
    
    # Create application
    application = Application(
        user_profile_id=profile.id,
        address=address_data,
        description=application_data.description,
        # ensure we pass a plain Python list to the DB (avoid passing JSON/text)
        image_urls=list(application_data.image_urls) if application_data.image_urls is not None else [],
        status="pending"
    )
    
    db.add(application)
    await db.commit()
    await db.refresh(application)
    
    return ApplicationResponseSchema(
        id=application.id,
        user_profile_id=application.user_profile_id,
        address=application.address,
        description=application.description,
        image_urls=application.image_urls,
        status=application.status,
        address_display=application.address_display,
        image_count=application.image_count,
        created_at=application.created_at,
        updated_at=application.updated_at
    )


@router.get("/status/{status_value}/", response_model=List[ApplicationResponseSchema])
async def get_applications_by_status(
    status_value: str,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Get applications by status for current user"""
    if status_value not in ['pending', 'approved', 'rejected']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid status"
        )

    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )

    result = await db.execute(
        select(Application).where(
            and_(
                Application.status == status_value,
                Application.user_profile_id == profile.id
            )
        )
    )
    applications = result.scalars().all()

    return [
        ApplicationResponseSchema(
            id=app.id,
            user_profile_id=app.user_profile_id,
            address=app.address,
            description=app.description,
            image_urls=app.image_urls,
            status=app.status,
            address_display=app.address_display,
            image_count=app.image_count,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


@router.get("/stats/", response_model=ApplicationStatsSchema)
async def get_application_stats(
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Get application statistics for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    # Get counts by status for user's applications
    result = await db.execute(
        select(
            func.count(Application.id).label('total'),
            func.sum(func.case((Application.status == 'pending', 1), else_=0)).label('pending'),
            func.sum(func.case((Application.status == 'approved', 1), else_=0)).label('approved'),
            func.sum(func.case((Application.status == 'rejected', 1), else_=0)).label('rejected')
        ).where(Application.user_profile_id == profile.id)
    )
    
    stats = result.first()
    
    total = stats.total or 0
    pending = stats.pending or 0
    approved = stats.approved or 0
    rejected = stats.rejected or 0
    
    # Calculate approval rate
    processed = approved + rejected
    approval_rate = (approved / processed * 100) if processed > 0 else 0.0
    
    return ApplicationStatsSchema(
        total=total,
        pending=pending,
        approved=approved,
        rejected=rejected,
        approval_rate=round(approval_rate, 2)
    )


@router.get("/me/", response_model=List[ApplicationResponseSchema])
async def get_my_applications(
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Get all applications for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    query = select(Application).where(Application.user_profile_id == profile.id)
    query = query.order_by(Application.created_at.desc())
    
    result = await db.execute(query)
    applications = result.scalars().all()
    
    return [
        ApplicationResponseSchema(
            id=app.id,
            user_profile_id=app.user_profile_id,
            address=app.address,
            description=app.description,
            image_urls=app.image_urls,
            status=app.status,
            address_display=app.address_display,
            image_count=app.image_count,
            created_at=app.created_at,
            updated_at=app.updated_at
        )
        for app in applications
    ]


@router.get("/{application_id}/", response_model=ApplicationResponseSchema)
async def get_application(
    application_id: uuid.UUID,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Get specific application by ID for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    result = await db.execute(
        select(Application).where(
            and_(
                Application.id == application_id,
                Application.user_profile_id == profile.id
            )
        )
    )
    application = result.scalar_one_or_none()
    
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
    
    return ApplicationResponseSchema(
        id=application.id,
        user_profile_id=application.user_profile_id,
        address=application.address,
        description=application.description,
        image_urls=application.image_urls,
        status=application.status,
        address_display=application.address_display,
        image_count=application.image_count,
        created_at=application.created_at,
        updated_at=application.updated_at
    )


@router.put("/{application_id}/", response_model=ApplicationResponseSchema)
async def update_application(
    application_id: uuid.UUID,
    application_data: ApplicationUpdateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Update application for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    result = await db.execute(
        select(Application).where(
            and_(
                Application.id == application_id,
                Application.user_profile_id == profile.id
            )
        )
    )
    application = result.scalar_one_or_none()
    
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
    
    # Update fields
    update_data = application_data.model_dump(exclude_unset=True)
    
    # Handle address geocoding
    if "address_query" in update_data:
        address_query = update_data.pop("address_query")
        if address_query:
            address_data = await geocoding_service.geocode_address_query(address_query)
            application.address = address_data.model_dump() if address_data.found else application.address
    elif "latitude" in update_data and "longitude" in update_data:
        latitude = update_data.pop("latitude")
        longitude = update_data.pop("longitude")
        if latitude and longitude:
            address_data = await geocoding_service.reverse_geocode_to_address(latitude, longitude)
            application.address = address_data.model_dump() if address_data.found else application.address
    
    # Update other fields
    for field, value in update_data.items():
        # Normalize lists before assignment to match DB column types (ARRAY on Postgres)
        if field == "image_urls" and value is not None:
            setattr(application, field, list(value))
        else:
            setattr(application, field, value)
    
    await db.commit()
    await db.refresh(application)
    
    return ApplicationResponseSchema(
        id=application.id,
        user_profile_id=application.user_profile_id,
        address=application.address,
        description=application.description,
        image_urls=application.image_urls,
        status=application.status,
        address_display=application.address_display,
        image_count=application.image_count,
        created_at=application.created_at,
        updated_at=application.updated_at
    )


@router.patch("/{application_id}/", response_model=ApplicationResponseSchema)
async def patch_application(
    application_id: uuid.UUID,
    application_data: ApplicationUpdateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Partially update application"""
    return await update_application(application_id, application_data, current_account, db)


@router.delete("/{application_id}/", status_code=status.HTTP_204_NO_CONTENT)
async def delete_application(
    application_id: uuid.UUID,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Delete application for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    result = await db.execute(
        select(Application).where(
            and_(
                Application.id == application_id,
                Application.user_profile_id == profile.id
            )
        )
    )
    application = result.scalar_one_or_none()
    
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
    
    await db.delete(application)
    await db.commit()


@router.put("/{application_id}/status/", response_model=ApplicationResponseSchema)
async def update_application_status(
    application_id: uuid.UUID,
    status_data: ApplicationStatusUpdateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Update only application status for current user"""
    # Get user's profile
    profile_result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = profile_result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    result = await db.execute(
        select(Application).where(
            and_(
                Application.id == application_id,
                Application.user_profile_id == profile.id
            )
        )
    )
    application = result.scalar_one_or_none()
    
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
    
    application.status = status_data.status
    await db.commit()
    await db.refresh(application)
    
    return ApplicationResponseSchema(
        id=application.id,
        user_profile_id=application.user_profile_id,
        address=application.address,
        description=application.description,
        image_urls=application.image_urls,
        status=application.status,
        address_display=application.address_display,
        image_count=application.image_count,
        created_at=application.created_at,
        updated_at=application.updated_at
    )
