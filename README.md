# Experiment 7: Spring Security with JWT and Role-Based Access Control (RBAC)

This project demonstrates secure authentication using Spring Security with JWT (JSON Web Tokens).

## Setup Instructions

1. **Database Configuration**
   By default, the application is configured to connect to a local MySQL instance with username `root` and password `root` on port `3306`. It will automatically create the `exp7_db` schema.
   If your MySQL credentials differ, or if you prefer an in-memory db, update `src/main/resources/application.properties`.

2. **Run the Application**
   Run the `Exp7Application` main class from your IDE (IntelliJ IDEA, Eclipse, etc.). The application will start on `localhost:8080`.
   *(Note: Roles `ROLE_USER` and `ROLE_ADMIN` are automatically initialized in the database upon the first startup.)*

## API Endpoints

### 1. Authentication (Public Routes)

**a. Register User**
- **Method:** `POST`
- **URL:** `http://localhost:8080/api/auth/register`
- **Body (JSON):**
  ```json
  {
    "username": "testuser",
    "password": "password123",
    "roles": ["user"]
  }
  ```
  *(To register an admin, include `"admin"` in the roles array)*

**b. Login User**
- **Method:** `POST`
- **URL:** `http://localhost:8080/api/auth/login`
- **Body (JSON):**
  ```json
  {
    "username": "testuser",
    "password": "password123"
  }
  ```
- **Response:** You will receive a JSON response containing a JWT token. Copy this token to use in the subsequent requests.

### 2. Protected Routes (RBAC Testing)

For these requests, you must include an `Authorization` header with the value `Bearer <YOUR_JWT_TOKEN>`.

**a. Public Content**
- **Method:** `GET`
- **URL:** `http://localhost:8080/api/test/all`
- *(No token required)*

**b. User Content (Requires `ROLE_USER` or `ROLE_ADMIN`)**
- **Method:** `GET`
- **URL:** `http://localhost:8080/api/test/user`
- **Header:** `Authorization: Bearer <TOKEN>`

**c. Admin Content (Requires `ROLE_ADMIN`)**
- **Method:** `GET`
- **URL:** `http://localhost:8080/api/test/admin`
- **Header:** `Authorization: Bearer <ADMIN_TOKEN>`
