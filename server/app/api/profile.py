from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.db.base import get_session
from app.core.dependencies import get_current_account
from app.schemas.user_profile import (
    UserProfileCreateSchema,
    UserProfileResponseSchema,
    UserProfileUpdateSchema
)
from app.models import Account, UserProfile, Application
from app.services.geocoding_service import geocoding_service

router = APIRouter(prefix="/api/accounts/profile", tags=["User Profile"])


@router.post("/", response_model=UserProfileResponseSchema, status_code=status.HTTP_201_CREATED)
async def create_profile(
    profile_data: UserProfileCreateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Create user profile for authenticated account"""
    # Check if profile already exists
    result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    existing_profile = result.scalar_one_or_none()
    
    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profile already exists for this account"
        )
    
    # Geocode address if provided
    address_data = None
    if profile_data.address_query:
        address_data = await geocoding_service.geocode_address_query(profile_data.address_query)
        address_data = address_data.model_dump() if address_data.found else None
    
    # Create profile
    profile = UserProfile(
        account_id=current_account.id,
        name=profile_data.name,
        surname=profile_data.surname,
        position=profile_data.position,
        address=address_data
    )
    
    db.add(profile)
    await db.commit()
    await db.refresh(profile)
    
    # Don't load relationships to avoid serialization issues
    # Just construct the response manually
    return UserProfileResponseSchema(
        id=profile.id,
        phone_number=current_account.phone_number,
        name=profile.name,
        surname=profile.surname,
        position=profile.position,
        address=profile.address,
        full_name=profile.full_name,
        address_display=profile.address_display,
        applications_count=0,  # New profile has no applications
        created_at=profile.created_at,
        updated_at=profile.updated_at
    )


@router.get("/me/", response_model=UserProfileResponseSchema)
async def get_my_profile(
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Get current user's profile"""
    result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this account"
        )
    
    # Count applications for this user
    applications_count_result = await db.execute(
        select(func.count(Application.id)).where(Application.user_profile_id == profile.id)
    )
    applications_count = applications_count_result.scalar()
    
    return UserProfileResponseSchema(
        id=profile.id,
        phone_number=current_account.phone_number,
        name=profile.name,
        surname=profile.surname,
        position=profile.position,
        address=profile.address,
        full_name=profile.full_name,
        address_display=profile.address_display,
        applications_count=applications_count,
        created_at=profile.created_at,
        updated_at=profile.updated_at
    )


@router.put("/me/", response_model=UserProfileResponseSchema)
async def update_my_profile(
    profile_data: UserProfileUpdateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Update current user's profile"""
    result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this account"
        )
    
    # Update fields
    update_data = profile_data.model_dump(exclude_unset=True)
    
    # Handle address geocoding
    if "address_query" in update_data:
        address_query = update_data.pop("address_query")
        if address_query:
            address_data = await geocoding_service.geocode_address_query(address_query)
            profile.address = address_data.model_dump() if address_data.found else None
    
    # Update other fields
    for field, value in update_data.items():
        setattr(profile, field, value)
    
    await db.commit()
    await db.refresh(profile)
    
    # Count applications for this user
    applications_count_result = await db.execute(
        select(func.count(Application.id)).where(Application.user_profile_id == profile.id)
    )
    applications_count = applications_count_result.scalar()
    
    # Don't load relationships to avoid serialization issues
    return UserProfileResponseSchema(
        id=profile.id,
        phone_number=current_account.phone_number,
        name=profile.name,
        surname=profile.surname,
        position=profile.position,
        address=profile.address,
        full_name=profile.full_name,
        address_display=profile.address_display,
        applications_count=applications_count,
        created_at=profile.created_at,
        updated_at=profile.updated_at
    )


@router.patch("/me/", response_model=UserProfileResponseSchema)
async def patch_my_profile(
    profile_data: UserProfileUpdateSchema,
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Partially update current user's profile"""
    return await update_my_profile(profile_data, current_account, db)


@router.delete("/me/", status_code=status.HTTP_204_NO_CONTENT)
async def delete_my_profile(
    current_account: Account = Depends(get_current_account),
    db: AsyncSession = Depends(get_session)
):
    """Delete current user's profile"""
    result = await db.execute(
        select(UserProfile).where(UserProfile.account_id == current_account.id)
    )
    profile = result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this account"
        )
    
    await db.delete(profile)
    await db.commit()
