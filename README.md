# NexTask

<p align="center">
  <strong>Production-ready Employee Task Management System built with Flutter, FastAPI, MySQL, and a premium React admin dashboard.</strong>
</p>

<p align="center">
  <a href="https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter&logoColor=white"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.41+-02569B?logo=flutter&logoColor=white"></a>
  <a href="https://img.shields.io/badge/FastAPI-Production-009688?logo=fastapi&logoColor=white"><img alt="FastAPI" src="https://img.shields.io/badge/FastAPI-Production-009688?logo=fastapi&logoColor=white"></a>
  <a href="https://img.shields.io/badge/MySQL-Railway-4479A1?logo=mysql&logoColor=white"><img alt="MySQL" src="https://img.shields.io/badge/MySQL-Railway-4479A1?logo=mysql&logoColor=white"></a>
  <a href="https://img.shields.io/badge/Render-Live-46E3B7?logo=render&logoColor=111"><img alt="Render" src="https://img.shields.io/badge/Render-Live-46E3B7?logo=render&logoColor=111"></a>
  <a href="https://img.shields.io/badge/License-MIT-black"><img alt="MIT License" src="https://img.shields.io/badge/License-MIT-black"></a>
</p>

## Overview

NexTask is a full-stack employee task management platform designed to feel closer to a polished startup product than a typical internship assignment. It includes:

- a Flutter task management app for employees
- a FastAPI backend with JWT authentication and protected task APIs
- a MySQL production database
- a premium React admin dashboard for operational oversight
- live deployment on Render with a production database hosted on Railway MySQL

The project is structured for real-world handoff quality: clean API boundaries, consistent state management, documented deployment flow, and recruiter-friendly presentation.

## Live Links

- Backend API: https://nextask-api-0fol.onrender.com
- Swagger Docs: https://nextask-api-0fol.onrender.com/docs
- Admin Dashboard: https://nextask-api-0fol.onrender.com/admin/
- Health Check: https://nextask-api-0fol.onrender.com/health

## Features

### Employee App

- JWT-based authentication
- Register and login flows
- Secure token storage with `flutter_secure_storage`
- Auto-login from stored token
- Task listing for the logged-in employee
- Search tasks
- Filter by task status
- Pull-to-refresh
- Add task
- Edit task
- Delete task
- Task details view
- Material 3 UI with reusable widgets and polished interactions

### Admin Dashboard

- Admin-only login
- View all users
- View all tasks
- Update task status across the system
- Delete users
- Delete tasks
- Premium SaaS-style responsive UI
- KPI cards, toasts, skeletons, micro-interactions, and polished filtering UX

### Backend API

- FastAPI application with clear route/service separation
- SQLAlchemy models and session handling
- JWT token generation and verification
- Protected employee task routes
- Protected admin routes
- Search and status filtering
- Production `/health` endpoint with database connectivity validation

## Architecture

```mermaid
flowchart LR
    A[Flutter Employee App] -->|JWT / REST| B[FastAPI API]
    C[React Admin Dashboard] -->|JWT / REST| B
    B --> D[(Railway MySQL)]
    E[Render Web Service] --> B
```

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend App | Flutter, Riverpod, Dio, go_router |
| Admin Dashboard | React, Vite, Framer Motion |
| Backend | FastAPI, SQLAlchemy, PyMySQL, python-jose, bcrypt |
| Database | MySQL |
| Production Hosting | Render |
| Production Database | Railway MySQL |

## Folder Structure

```text
NexTask/
├── admin/                  # React admin dashboard
├── backend/                # FastAPI backend
│   ├── app/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── schemas/
│   │   ├── services/
│   │   └── utils/
│   ├── .env.example
│   ├── .env.render.example
│   └── requirements.txt
├── docs/
│   └── screenshots/
├── lib/                    # Flutter app source
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── routes/
│   ├── screens/
│   ├── services/
│   └── widgets/
├── render.yaml
├── RENDER_DEPLOYMENT.md
└── README.md
```

## Authentication Flow

1. User registers with name, email, and password.
2. Backend hashes the password using `bcrypt`.
3. User logs in and receives a JWT access token.
4. Flutter stores the token securely with `flutter_secure_storage`.
5. Flutter restores the session on app startup by calling `/auth/me`.
6. Protected employee routes use `Authorization: Bearer <token>`.
7. Admin dashboard uses the same JWT flow and backend role checks through `is_admin`.

## Admin Dashboard Features

- Admin-only route protection via backend authorization
- System-wide task visibility
- System-wide user visibility
- Task status updates without leaving the dashboard
- Delete actions for tasks and users
- Responsive premium UI optimized for live demos and recruiter reviews

## API Documentation

Interactive docs are available at:

- https://nextask-api-0fol.onrender.com/docs

### Core Routes

#### Authentication

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`

#### Employee Tasks

- `GET /tasks`
- `POST /tasks`
- `PUT /tasks/{task_id}`
- `DELETE /tasks/{task_id}`

#### Admin

- `GET /admin-api/summary`
- `GET /admin-api/users`
- `DELETE /admin-api/users/{user_id}`
- `GET /admin-api/tasks`
- `PATCH /admin-api/tasks/{task_id}/status`
- `DELETE /admin-api/tasks/{task_id}`

## Deployment Details

### Production API

- Hosted on Render
- URL: https://nextask-api-0fol.onrender.com

### Production Database

- Hosted on Railway MySQL
- Connected to the FastAPI service through `DATABASE_URL`
- Verified through the live `/health` endpoint

## Demo Credentials

### Admin Credentials

- Email: `admin@nextask.com`
- Password: `Admin@12345`

### Employee Demo Credentials

- Email: `employee@nextask.com`
- Password: `Employee@12345`

Notes:
- The employee demo account was created and verified against the live deployment.
- The employee account currently has seeded demo tasks for dashboard validation.

## Environment Variables

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | Full SQLAlchemy connection string for MySQL. In production this points to Railway MySQL. |
| `SECRET_KEY` | Secret used to sign and verify JWT tokens. Must be long and random in production. |
| `ALGORITHM` | JWT signing algorithm, currently `HS256`. |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | JWT validity period in minutes. Production guidance uses a longer value because the mobile app currently uses access tokens without refresh tokens. |
| `ADMIN_NAME` | Display name for the seeded admin account created during backend startup. |
| `ADMIN_EMAIL` | Email for the production admin user that the backend seeds or updates automatically. |
| `ADMIN_PASSWORD` | Password for the production admin user that the backend seeds or updates automatically. |
| `CORS_ORIGINS` | Comma-separated list of allowed frontend origins for browser requests. |

### Local Backend Template

See:

- `backend/.env.example`

### Render Production Template

See:

- `backend/.env.render.example`

## Local Setup

### 1. Clone the repository

```bash
git clone https://github.com/Samanyu-dev/NexTask.git
cd NexTask
```

### 2. Backend setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python3 -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Backend URLs:

- API: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`
- Admin Dashboard: `http://127.0.0.1:8000/admin/`

### 3. Flutter setup

```bash
flutter pub get
flutter run
```

### 4. Flutter API URL override

For Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For iOS simulator:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

For the live deployed API:

```bash
flutter run --dart-define=API_BASE_URL=https://nextask-api-0fol.onrender.com
```

## Production Deployment Instructions

### Render Deployment Steps

1. Push the repository to GitHub.
2. Create the Render web service from this repository.
3. Use the included `render.yaml`.
4. Configure the required environment variables.
5. Confirm the `/health` endpoint returns `200`.
6. Verify `/docs` and `/admin/` after deployment.

Reference guide:

- `RENDER_DEPLOYMENT.md`

### Railway MySQL Setup Steps

1. Create a new MySQL service in Railway.
2. Copy the generated MySQL variables from Railway.
3. Build `DATABASE_URL` using either the provided connection URL or these Railway values:
   - `MYSQLHOST`
   - `MYSQLPORT`
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`
4. Set the final Render `DATABASE_URL` as:

```text
mysql+pymysql://MYSQLUSER:MYSQLPASSWORD@MYSQLHOST:MYSQLPORT/MYSQLDATABASE
```

5. Add that value to the Render environment settings.
6. Redeploy the Render service and verify `/health`.

If Railway provides a direct MySQL connection string such as `MYSQL_URL`, you can use it directly after converting it into SQLAlchemy-compatible format if needed.

## APK Build Instructions

Use the live Render backend URL when building the final release APK:

```bash
flutter clean
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://nextask-api-0fol.onrender.com
```

Final APK output path:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Verified in this final pass:

- Release APK built successfully against `https://nextask-api-0fol.onrender.com`

## Screenshots

Screenshots were intentionally omitted in this final repository pass by request.

Planned location when added later:

```text
docs/screenshots/
```

## Final Project Verification

### Verified Against Live Production Backend

- Login works
- Registration works
- JWT authentication works
- Employee task CRUD works
- Search works
- Status filtering works
- Admin dashboard loads
- Admin task status updates work
- Admin delete actions work
- Swagger docs are available
- Render backend is live
- Railway-backed database connectivity is healthy through `/health`

### Live Verification Summary

- Backend root: `200`
- Health endpoint: `200`
- Swagger docs: `200`
- Admin summary endpoint: `200`
- Admin users endpoint: `200`
- Admin tasks endpoint: `200`
- Employee task create: `201`
- Employee task update: `200`
- Employee task delete: `200`

## Final Submission Checklist

- [x] Deployed backend is live on Render
- [x] Deployed admin dashboard is live
- [x] Production database is connected
- [x] Final APK generated locally with live backend URL
- [x] Documentation is production-ready
- [ ] Screenshots added
- [x] Swagger API docs are working
- [x] Authentication is working
- [x] Admin dashboard operations are working

Notes:
- The APK was built successfully in this final pass at `build/app/outputs/flutter-apk/app-release.apk`.
- The screenshots checklist item is intentionally left incomplete because screenshots were explicitly skipped in this pass.

## Repository Hygiene

Completed in this finalization pass:

- local `.env` is ignored for public presentation
- tracked local `backend/.env` was removed from git index so secrets are not published
- unneeded local screenshot generation files were removed
- documentation structure was cleaned up
- production env templates are separated from local secrets
- public-facing README was rewritten for recruiter readability

## Future Improvements

- Refresh-token based session management
- Pagination for admin task and user lists
- Role-based permissions beyond a single admin flag
- Task attachments and comments
- Push notifications and reminder scheduling
- CI/CD pipeline for automated lint, test, and deploy checks
- Manual or scripted screenshot automation for portfolio presentation

## License

This project is licensed under the MIT License.

See [LICENSE](LICENSE).
