# NexTask Backend Setup Log

This file documents each backend setup step requested so far and the fixes applied.

## Step 1 - FastAPI dependencies

Requested:
- Install `fastapi uvicorn sqlalchemy pymysql python-jose passlib bcrypt python-dotenv`

Executed:
- `python3 -m pip install fastapi uvicorn sqlalchemy pymysql python-jose passlib bcrypt python-dotenv`

Result:
- Dependencies installed successfully in user site-packages.

Notes:
- `pip` command was unavailable, so `python3 -m pip` was used.
- Initial sandbox network restriction was resolved by running install with elevated permissions.

## Step 2 - MySQL setup

Requested:
- `CREATE DATABASE employee_tasks;`

Executed:
- Installed MySQL via Homebrew.
- Started service: `brew services start mysql`
- Created DB: `mysql -u root -e "CREATE DATABASE employee_tasks;"`
- Verified: `mysql -u root -e "SHOW DATABASES LIKE 'employee_tasks';"`

Result:
- Database `employee_tasks` exists.

## Step 3 - User model

Requested fields:
- `id`
- `name`
- `email`
- `hashed_password`

Implemented in:
- `app/models/user.py`

## Step 4 - Task model

Requested fields:
- `id`
- `title`
- `description`
- `priority`
- `due_date`
- `status`
- `user_id`

Relationship requested:
- One user -> many tasks

Implemented in:
- `app/models/task.py`
- Relationship wiring:
  - `User.tasks`
  - `Task.user`

## Step 5 - JWT authentication

Requested:
- Password hashing
- Token generation
- Protected routes
- Use `bcrypt` and `python-jose`

Implemented:
- Password hashing and verification in `app/utils/security.py`
- JWT generation and decode in `app/utils/security.py`
- Register, login, and protected current-user endpoint in `app/routes/auth.py`
- Auth service logic in `app/services/auth_service.py`
- Router registration and startup table creation in `app/main.py`

API routes:
- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me` (protected, requires bearer token)

## Problems fixed

1. Missing written documentation
- Added this setup log.

2. `passlib` missing in requirements file
- Added `passlib` to `backend/requirements.txt`.

3. `.env` loading could fail from different launch directories
- Updated `app/database.py` to load `backend/.env` using an absolute path from the file location.

4. Runtime error: missing `users` table
- Initialized tables in `employee_tasks` from SQLAlchemy models.
- Verified auth endpoints after initialization.

## Current backend files added for auth

- `app/schemas/auth.py`
- `app/services/auth_service.py`
- `app/routes/auth.py`
- `app/utils/security.py`
- Package `__init__.py` files in `app/routes`, `app/schemas`, `app/services`, `app/utils`

## Run backend locally

From `backend/`:

```bash
uvicorn app.main:app --reload

# Optional: initialize tables manually once
python3 -c "from app.database import Base, engine; from app.models import User, Task; Base.metadata.create_all(bind=engine)"
```
