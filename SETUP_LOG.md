# NexTask Setup Log (All Requested Steps)

Date: May 20, 2026

This log tracks every setup step you requested and what was done.

## 1. Backend dependency setup

Requested:
- Install `fastapi uvicorn sqlalchemy pymysql python-jose passlib bcrypt python-dotenv`

Done:
- Installed using `python3 -m pip install ...` because `pip` was not available on PATH.

Status:
- Completed.

## 2. Project structure request and correction

Requested:
- Backend folder structure under `backend/`
- Flutter architecture folders under `lib/`
- Then clarified: create a real Flutter project first, not only manual folders.

Done:
- Created requested backend folders/files.
- Generated a real Flutter app using:
  - `flutter create . --project-name nextask`
- Verified `lib/` includes:
  - `core`, `models`, `services`, `providers`, `screens`, `widgets`, `routes`, `main.dart`

Status:
- Completed and corrected per your clarification.

## 3. MySQL setup

Requested:
- `CREATE DATABASE employee_tasks;`

Done:
- Installed MySQL via Homebrew.
- Started MySQL service.
- Created `employee_tasks` database.
- Verified database exists.

Status:
- Completed.

## 4. User model

Requested fields:
- `id`, `name`, `email`, `hashed_password`

Done:
- Implemented SQLAlchemy `User` model in `backend/app/models/user.py`

Status:
- Completed.

## 5. Task model

Requested fields:
- `id`, `title`, `description`, `priority`, `due_date`, `status`, `user_id`

Relationship requested:
- One user -> many tasks

Done:
- Implemented SQLAlchemy `Task` model in `backend/app/models/task.py`
- Added relationship:
  - `User.tasks`
  - `Task.user`

Status:
- Completed.

## 6. JWT authentication

Requested:
- Password hashing
- Token generation
- Protected routes
- Use `bcrypt` and `python-jose`

Done:
- Added hashing and verification in `backend/app/utils/security.py`
- Added JWT create/decode in `backend/app/utils/security.py`
- Added auth service in `backend/app/services/auth_service.py`
- Added auth routes in `backend/app/routes/auth.py`
  - `POST /auth/register`
  - `POST /auth/login`
  - `GET /auth/me` (protected)
- Wired auth router in `backend/app/main.py`

Status:
- Completed.

## Problems fixed

1. Missing centralized documentation
- Added this root `SETUP_LOG.md`.
- Added backend-specific log in `backend/README.md`.

2. `passlib` missing from `backend/requirements.txt`
- Added `passlib`.

3. `.env` file loading depended on launch directory
- Updated `backend/app/database.py` to load `backend/.env` via absolute path from file location.

4. Runtime error: `employee_tasks.users` table missing
- Initialized tables from SQLAlchemy models in MySQL.
- Verified auth flow works.

## Verification performed

Backend auth smoke test (against local MySQL):
- `register` -> `201`
- `login` -> `200`
- protected `me` -> `200`

Date update: May 21, 2026

## 7. Flutter authentication flow

Requested:
- Store JWT securely
- Use `flutter_secure_storage`
- Flow:
- Login
- Save token
- Auto-login if token exists

Done:
- Added `flutter_secure_storage` dependency in `pubspec.yaml`
- Implemented API login and secure token persistence in `lib/services/auth_service.dart`
- Added auth state handling in `lib/providers/auth_provider.dart`
- App startup now checks secure storage and auto-routes to Dashboard if a token exists

Files added or updated:
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`
- `lib/main.dart`

Status:
- Completed.

## 8. Flutter screens and UI

Requested:
- Login screen
- Register screen
- Dashboard
- Add/Edit Task
- Task Details
- Material 3 polish with priority colors, status chips, rounded cards, and better visual quality

Done:
- Built login screen with validation, loading state, and error snackbar
- Built register screen with password matching validation
- Built dashboard with:
- task fetching
- search bar
- filter dropdown
- pull-to-refresh
- floating action button
- Built reusable task form with date picker and dropdowns
- Built task details screen with edit button, delete button, and card-based layout
- Added Material 3 theme with consistent spacing, rounded corners, subtle shadows, and recruiter-friendly styling
- Added task priority color cues:
- High -> red
- Medium -> orange
- Low -> green
- Added status chips across task cards and detail views

Files added or updated:
- `lib/core/app_theme.dart`
- `lib/models/task.dart`
- `lib/services/task_service.dart`
- `lib/providers/task_provider.dart`
- `lib/screens/splash_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/register_screen.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/task_form_screen.dart`
- `lib/screens/task_details_screen.dart`
- `lib/widgets/task_card.dart`
- `lib/widgets/task_form_widget.dart`
- `test/widget_test.dart`

Notes:
- Dashboard currently falls back to local demo tasks if backend `/tasks` endpoints are not available yet, so the UI remains usable while backend task APIs are still pending.

Status:
- Completed.
