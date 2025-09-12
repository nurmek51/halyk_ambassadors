import requests
import json
import time
from typing import Dict, Optional
from django.conf import settings

class KazakhstanAddressService:
    """
    Extended Kazakhstan address service for Django integration
    Reuses existing functionality from scripts/address_service.py
    """

    def __init__(self, user_agent: str = "HalykBackend/1.0"):
        self.base_url = 'https://nominatim.openstreetmap.org/'
        self.headers = {
            'User-Agent': user_agent,
            'Accept-Language': 'ru,kk,en'
        }
        self.country_code = 'kz'

    def _make_request(self, endpoint: str, params: dict) -> dict:
        """Выполняет HTTP запрос с соблюдением лимитов"""
        try:
            # Соблюдаем лимит Nominatim - 1 запрос в секунду
            time.sleep(1)

            response = requests.get(
                f"{self.base_url}{endpoint}",
                params=params,
                headers=self.headers,
                timeout=10
            )

            if response.status_code == 200:
                return {'success': True, 'data': response.json()}
            else:
                return {'success': False, 'error': f'HTTP {response.status_code}'}

        except Exception as e:
            return {'success': False, 'error': str(e)}

    def validate_and_geocode_address(self, address_query: str) -> Dict:
        """
        Validates address and returns standardized format for models
        
        Returns:
            dict: Address data matching User/Application model schema
        """
        params = {
            'q': address_query,
            'countrycodes': self.country_code,
            'format': 'jsonv2',
            'limit': 1,
            'addressdetails': 1,
            'extratags': 1,
            'namedetails': 1
        }

        result = self._make_request('search', params)

        if not result['success'] or not result['data']:
            return {
                'found': False,
                'address': address_query,
                'city': '',
                'region': '',
                'district': '',
                'postcode': '',
                'latitude': None,
                'longitude': None,
                'confidence': 0
            }

        item = result['data'][0]
        address = item.get('address', {})
        
        return {
            'found': True,
            'address': item.get('display_name', address_query),
            'city': address.get('city', address.get('town', address.get('village', ''))),
            'region': address.get('state', ''),
            'district': address.get('county', ''),
            'postcode': address.get('postcode', ''),
            'latitude': float(item.get('lat', 0)),
            'longitude': float(item.get('lon', 0)),
            'confidence': item.get('importance', 0)
        }

    def reverse_geocode_to_model_format(self, latitude: float, longitude: float) -> Dict:
        """
        Reverse geocodes coordinates to model-compatible address format
        """
        params = {
            'lat': latitude,
            'lon': longitude,
            'format': 'jsonv2',
            'addressdetails': 1,
            'zoom': 18
        }

        result = self._make_request('reverse', params)

        if not result['success'] or not result['data']:
            return {
                'found': False,
                'address': f"Координаты: {latitude}, {longitude}",
                'city': '',
                'region': '',
                'district': '',
                'postcode': '',
                'latitude': latitude,
                'longitude': longitude,
                'confidence': 0
            }

        item = result['data']
        address = item.get('address', {})

        return {
            'found': True,
            'address': item.get('display_name', ''),
            'city': address.get('city', address.get('town', address.get('village', ''))),
            'region': address.get('state', ''),
            'district': address.get('county', ''),
            'postcode': address.get('postcode', ''),
            'latitude': float(item.get('lat', 0)),
            'longitude': float(item.get('lon', 0)),
            'confidence': item.get('importance', 0)
        }

    def validate_coordinates(self, latitude: float, longitude: float) -> bool:
        """
        Проверяет, находятся ли координаты в пределах Казахстана
        """
        return (40.0 <= latitude <= 56.0 and 46.0 <= longitude <= 88.0)
