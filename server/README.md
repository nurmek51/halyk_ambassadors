# Halyk Bank API

A comprehensive backend system for managing user accounts, applications, and geolocation services built with FastAPI, following best practices and implementing the complete technical specification.

## 🚀 Features

- **Phone-based Authentication**: OTP verification system with JWT tokens
- **User Profile Management**: Complete CRUD operations for user profiles
- **Application Management**: Submit and manage applications with geolocation
- **Geolocation Services**: Address geocoding and reverse geocoding using Nominatim API
- **UUID-based Entities**: Secure UUID primary keys for all entities
- **Rate Limiting**: Built-in rate limiting middleware
- **CORS Support**: Configurable CORS for frontend integration
- **Comprehensive Testing**: Full test suite with pytest
- **Database Migrations**: Alembic for database schema management

## 📋 Requirements

- Python 3.9+
- PostgreSQL (for production) or SQLite (for testing)
- Internet connection (for geocoding services)

## 🛠 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd server
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables**:
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

4. **Initialize database**:
   ```bash
   alembic upgrade head
   ```

## 🏃‍♂️ Running the Application

### Development Server
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Production Server
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## 📖 API Documentation

Once the server is running, you can access:
- **Interactive API Docs**: http://localhost:8000/docs
- **ReDoc Documentation**: http://localhost:8000/redoc

## 🧪 Testing

### Run Simple Tests
```bash
python test_simple.py
```

### Run Full Test Suite
```bash
pytest tests/ -v
```

### Run Specific Test Files
```bash
pytest tests/test_auth.py -v
pytest tests/test_profile.py -v
pytest tests/test_applications.py -v
pytest tests/test_geo.py -v
```

## 📡 API Endpoints

### Authentication (Public)
- `POST /auth/request-otp` - Request OTP code
- `POST /auth/verify-otp` - Verify OTP and get JWT tokens
- `GET /auth/check-verification` - Check phone verification status

### User Profile (JWT Protected)
- `POST /api/accounts/profile/` - Create user profile
- `GET /api/accounts/profile/me/` - Get current user's profile
- `PUT /api/accounts/profile/me/` - Update user profile
- `PATCH /api/accounts/profile/me/` - Partially update user profile
- `DELETE /api/accounts/profile/me/` - Delete user profile

### Applications (JWT Protected)
- `GET /api/applications/` - List applications (with pagination)
- `POST /api/applications/` - Create new application
- `GET /api/applications/{id}/` - Get specific application
- `PUT /api/applications/{id}/` - Update application
- `PATCH /api/applications/{id}/` - Partially update application
- `DELETE /api/applications/{id}/` - Delete application
- `PUT /api/applications/{id}/status/` - Update application status
- `GET /api/applications/status/{status}/` - Get applications by status
- `GET /api/applications/stats/` - Get application statistics

### Geolocation (Public)
- `POST /api/geo/geocode` - Search coordinates by address
- `POST /api/geo/reverse-geocode` - Get address by coordinates
- `GET /api/geo/autocomplete` - Address autocomplete suggestions
- `POST /api/geo/geolocation-address` - Get address from device location

## 🏗 Architecture

### Project Structure
```
app/
├── api/                 # API route handlers
│   ├── auth.py         # Authentication endpoints
│   ├── profile.py      # User profile endpoints
│   ├── applications.py # Application endpoints
│   └── geo.py          # Geolocation endpoints
├── core/               # Core configuration and dependencies
│   ├── config.py       # Settings and configuration
│   ├── dependencies.py # FastAPI dependencies
│   └── middleware.py   # Custom middleware
├── db/                 # Database configuration
│   └── base.py         # Database setup and session management
├── models/             # SQLAlchemy models
│   ├── base.py         # Base model classes
│   ├── account.py      # Account model
│   ├── user_profile.py # UserProfile model
│   ├── application.py  # Application model
│   └── otp_request.py  # OTPRequest model
├── schemas/            # Pydantic schemas
│   ├── address.py      # Address schema
│   ├── auth.py         # Authentication schemas
│   ├── user_profile.py # User profile schemas
│   ├── application.py  # Application schemas
│   └── geo.py          # Geolocation schemas
├── services/           # Business logic services
│   ├── auth_service.py # JWT and authentication logic
│   ├── otp_service.py  # OTP verification logic
│   └── geocoding_service.py # Geocoding and address services
└── main.py             # FastAPI application setup
```

### Database Models

#### UUIDTimestampedModel (Base)
- `id`: UUID primary key
- `created_at`: Timestamp
- `updated_at`: Timestamp

#### Account
- Phone-verified authentication entity
- Unique Kazakhstan phone number validation
- Verification status tracking

#### UserProfile
- Personal information linked to Account
- Address with geocoding support
- Computed properties (full_name, address_display)

#### Application
- User submissions with geolocation
- Image URL storage (max 10 images)
- Status tracking (pending/approved/rejected)

#### OTPRequest
- Temporary OTP verification records
- 5-minute expiration
- Mock code "1111" for development

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Phone Verification**: OTP-based phone number verification
- **Rate Limiting**: Configurable request rate limiting
- **Input Validation**: Comprehensive Pydantic validation
- **CORS Protection**: Configurable CORS policies
- **UUID Primary Keys**: Secure, non-sequential identifiers

## 🌍 Geolocation Features

- **Address Geocoding**: Convert addresses to coordinates
- **Reverse Geocoding**: Convert coordinates to addresses
- **Autocomplete**: Address suggestion system
- **Kazakhstan Focus**: Optimized for Kazakhstan addresses
- **Rate Limited**: Respects Nominatim API limits (1 req/sec)
- **Fallback Handling**: Graceful handling of geocoding failures

## ⚙️ Configuration

### Environment Variables

```env
# Database
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/halyk_db

# JWT Settings
SECRET_KEY=your-secret-key-here
JWT_ACCESS_TOKEN_LIFETIME=3600
JWT_REFRESH_TOKEN_LIFETIME=604800

# Twilio (for real SMS)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_FROM_NUMBER=+1234567890
TWILIO_MOCK_MODE=true

# API Settings
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
DEBUG=true
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
```

## 📊 Database Migrations

### Create Migration
```bash
alembic revision --autogenerate -m "Description"
```

### Apply Migrations
```bash
alembic upgrade head
```

### Rollback Migration
```bash
alembic downgrade -1
```

## 🚀 Deployment

### Docker Deployment
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Production Considerations
- Use PostgreSQL for production database
- Set up proper SSL certificates
- Configure reverse proxy (nginx)
- Set up monitoring and logging
- Use environment-specific configuration
- Enable Twilio for real SMS sending

## 🧪 Testing Strategy

### Test Categories
1. **Unit Tests**: Individual component testing
2. **Integration Tests**: API endpoint testing
3. **Authentication Tests**: JWT and OTP flow testing
4. **Geocoding Tests**: Address service testing
5. **Database Tests**: Model and relationship testing

### Test Database
Tests use SQLite with automatic setup/teardown for isolation.

## 📈 Performance Features

- **Async/Await**: Full async support for better performance
- **Connection Pooling**: Efficient database connection management
- **Rate Limiting**: Prevents API abuse
- **Pagination**: Efficient data loading for large datasets
- **Indexes**: Optimized database queries with proper indexing

## 🔧 Development Tools

- **FastAPI**: Modern, fast web framework
- **SQLAlchemy**: Powerful ORM with async support
- **Alembic**: Database migration management
- **Pydantic**: Data validation and serialization
- **pytest**: Comprehensive testing framework
- **httpx**: Modern HTTP client for testing

## 📝 Code Quality

- **Type Hints**: Full type annotation support
- **Pydantic Validation**: Automatic request/response validation
- **Error Handling**: Comprehensive error handling and logging
- **Code Organization**: Clean, modular architecture
- **Documentation**: Extensive inline and API documentation

## 🤝 Contributing

1. Follow PEP 8 style guidelines
2. Add type hints to all functions
3. Write tests for new features
4. Update documentation as needed
5. Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
1. Check the API documentation at `/docs`
2. Review the test files for usage examples
3. Check the technical specification in `Technical_task.md`

---

**Built with ❤️ using FastAPI and following best practices for production-ready APIs.**
