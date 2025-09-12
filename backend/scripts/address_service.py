import requests
import json
import time
from typing import List, Dict, Optional, Tuple

class KazakhstanAddressService:
    """
    Полнофункциональный валидатор и геокодер адресов Казахстана

    Возможности:
    1. Поиск адреса по тексту (geocoding)
    2. Получение адреса по координатам (reverse geocoding)
    3. Автокомплит для подсказок пользователю
    4. Работа с геолокацией устройства
    """

    def __init__(self, user_agent: str = "KazakhstanAddressService/1.0"):
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

    def geocode_address(self, query: str, limit: int = 5) -> dict:
        """
        Поиск адреса по тексту (координаты по адресу)

        Args:
            query: Текст адреса для поиска
            limit: Максимальное количество результатов

        Returns:
            dict: Результаты поиска с координатами
        """
        params = {
            'q': query,
            'countrycodes': self.country_code,
            'format': 'jsonv2',
            'limit': limit,
            'addressdetails': 1,
            'extratags': 1,
            'namedetails': 1
        }

        result = self._make_request('search', params)

        if not result['success']:
            return result

        locations = []
        for item in result['data']:
            address = item.get('address', {})
            locations.append({
                'display_name': item.get('display_name', ''),
                'name': item.get('name', ''),
                'latitude': float(item.get('lat', 0)),
                'longitude': float(item.get('lon', 0)),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'region': address.get('state', ''),
                'district': address.get('county', ''),
                'postcode': address.get('postcode', ''),
                'country': address.get('country', ''),
                'place_type': item.get('type', ''),
                'importance': item.get('importance', 0),
                'osm_id': item.get('osm_id', ''),
                'place_id': item.get('place_id', '')
            })

        return {
            'success': True,
            'count': len(locations),
            'locations': locations
        }

    def reverse_geocode(self, latitude: float, longitude: float, zoom: int = 18) -> dict:
        """
        Обратное геокодирование (адрес по координатам)

        Args:
            latitude: Широта
            longitude: Долгота
            zoom: Уровень детализации (3-18, где 18 - самый детальный)

        Returns:
            dict: Адрес для указанных координат
        """
        params = {
            'lat': latitude,
            'lon': longitude,
            'format': 'jsonv2',
            'addressdetails': 1,
            'extratags': 1,
            'namedetails': 1,
            'zoom': zoom
        }

        result = self._make_request('reverse', params)

        if not result['success']:
            return result

        if not result['data']:
            return {'success': False, 'error': 'Адрес не найден для указанных координат'}

        item = result['data']
        address = item.get('address', {})

        return {
            'success': True,
            'address': {
                'display_name': item.get('display_name', ''),
                'name': item.get('name', ''),
                'house_number': address.get('house_number', ''),
                'road': address.get('road', ''),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'district': address.get('county', ''),
                'region': address.get('state', ''),
                'postcode': address.get('postcode', ''),
                'country': address.get('country', ''),
                'country_code': address.get('country_code', ''),
                'place_type': item.get('type', ''),
                'confidence': item.get('importance', 0),
                'coordinates': {
                    'latitude': float(item.get('lat', 0)),
                    'longitude': float(item.get('lon', 0))
                }
            }
        }

    def autocomplete_suggestions(self, partial_query: str, limit: int = 5) -> dict:
        """
        Автокомплит адресов для подсказок пользователю

        Args:
            partial_query: Частичный ввод пользователя
            limit: Количество предложений

        Returns:
            dict: Список предложений для автокомплита
        """
        if len(partial_query) < 2:
            return {'success': True, 'suggestions': []}

        # Для автокомплита используем более широкий поиск
        params = {
            'q': partial_query,
            'countrycodes': self.country_code,
            'format': 'jsonv2',
            'limit': limit,
            'addressdetails': 1,
            'featureType': 'settlement'  # Фокус на населенных пунктах
        }

        result = self._make_request('search', params)

        if not result['success']:
            return result

        suggestions = []
        for item in result['data']:
            address = item.get('address', {})
            suggestion = {
                'text': item.get('display_name', ''),
                'short_text': item.get('name', ''),
                'city': address.get('city', address.get('town', address.get('village', ''))),
                'region': address.get('state', ''),
                'type': item.get('type', ''),
                'coordinates': {
                    'lat': float(item.get('lat', 0)),
                    'lon': float(item.get('lon', 0))
                }
            }
            suggestions.append(suggestion)

        return {
            'success': True,
            'query': partial_query,
            'suggestions': suggestions
        }

    def validate_coordinates(self, latitude: float, longitude: float) -> bool:
        """
        Проверяет, находятся ли координаты в пределах Казахстана

        Казахстан: примерно 40.5°N-55.5°N, 46.5°E-87.5°E
        """
        return (40.0 <= latitude <= 56.0 and 46.0 <= longitude <= 88.0)

    def get_address_from_geolocation(self, latitude: float, longitude: float) -> dict:
        """
        Получает точный адрес из геолокации устройства

        Args:
            latitude: Широта из GPS
            longitude: Долгота из GPS

        Returns:
            dict: Полная информация об адресе
        """
        # Проверяем, что координаты в пределах Казахстана
        if not self.validate_coordinates(latitude, longitude):
            return {
                'success': False,
                'error': 'Координаты находятся за пределами Казахстана'
            }

        # Получаем детальный адрес с максимальной точностью
        return self.reverse_geocode(latitude, longitude, zoom=18)
