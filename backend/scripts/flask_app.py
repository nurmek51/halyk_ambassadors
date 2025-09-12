from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from address_service import KazakhstanAddressService

app = Flask(__name__)
CORS(app)  # Разрешаем CORS для фронтенда

# Инициализируем сервис
address_service = KazakhstanAddressService()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/geocode', methods=['POST'])
def geocode():
    """Поиск координат по адресу"""
    data = request.json
    query = data.get('query', '')
    limit = data.get('limit', 5)

    result = address_service.geocode_address(query, limit)
    return jsonify(result)

@app.route('/api/reverse-geocode', methods=['POST'])
def reverse_geocode():
    """Получение адреса по координатам"""
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    zoom = data.get('zoom', 18)

    if not latitude or not longitude:
        return jsonify({'success': False, 'error': 'Координаты обязательны'})

    result = address_service.reverse_geocode(latitude, longitude, zoom)
    return jsonify(result)

@app.route('/api/autocomplete', methods=['GET'])
def autocomplete():
    """Автокомплит адресов"""
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', 5))

    result = address_service.autocomplete_suggestions(query, limit)
    return jsonify(result)

@app.route('/api/geolocation-address', methods=['POST'])
def geolocation_address():
    """Получение адреса из геолокации устройства"""
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')

    if not latitude or not longitude:
        return jsonify({'success': False, 'error': 'Координаты обязательны'})

    result = address_service.get_address_from_geolocation(latitude, longitude)
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
