# NexTask

Employee Task Management System built for the Flutter Full Stack Developer Assessment.

## Stack

- Flutter mobile app
- FastAPI backend
- MySQL database
- JWT authentication
- Riverpod state management
- Dio API client
- go_router navigation

## Features Completed

### Authentication

- User registration
- User login
- JWT token generation
- Secure token storage with `flutter_secure_storage`
- Auto-login using saved token

### Task Management

- View all tasks for the logged-in user
- Search tasks
- Filter tasks by status
- Pull-to-refresh
- Add task
- Edit task
- Delete task
- Task details screen
- Logout

### Bonus Admin Dashboard

- React-based admin dashboard
- View all users
- View all tasks
- Update task statuses
- Delete users
- Delete tasks
- Admin-only protected API endpoints
- Premium SaaS-style responsive UI
- Framer Motion micro-interactions
- Skeleton loading states and toast notifications

### UI/UX

- Material 3 theme
- Reusable widgets
- Loading states
- Error handling
- Snackbar feedback
- Empty states
- Modern bottom-sheet selectors for filters and task fields
- Elevated custom search UI on the dashboard
- Rounded cards, spacing, icons, and transitions

## Project Structure

### Flutter

- `lib/core` : app config, theme, global messenger
- `lib/models` : user and task models
- `lib/providers` : Riverpod auth and task state
- `lib/routes` : app routes and guarded `go_router`
- `lib/screens` : app screens
- `lib/services` : Dio API service
- `lib/widgets` : reusable UI components

### Backend

- `backend/app/models` : SQLAlchemy models
- `backend/app/schemas` : request/response schemas
- `backend/app/services` : business logic
- `backend/app/routes` : API endpoints
- `backend/app/utils` : JWT/password security
- `admin` : React admin dashboard source

## Local Backend Setup

From the project root:

```bash
cd backend
python3 -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

The repository already includes a built admin bundle for deployment.

If you change the admin source later and want to rebuild it locally:

```bash
cd admin
npm install
npm run build
```

Swagger docs:

```text
http://127.0.0.1:8000/docs
```

### Environment

Use:

- `backend/.env` for local development
- `backend/.env.example` as the template

Required values:

- `DATABASE_URL`
- `SECRET_KEY`
- `ALGORITHM`
- `ACCESS_TOKEN_EXPIRE_MINUTES`
- `ADMIN_NAME`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

## Local Flutter Setup

Install packages:

```bash
flutter pub get
```

Run on simulator/emulator:

```bash
flutter run
```

### API URL configuration

For local iOS simulator:

- default is `http://127.0.0.1:8000`

For Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For deployed backend:

```bash
flutter run --dart-define=API_BASE_URL=https://your-render-service.onrender.com
```

## Admin Dashboard

After starting FastAPI, open:

```text
http://127.0.0.1:8000/admin/
```

If `8000` is already occupied, run FastAPI on another port and open `/admin/` on that same port.

## Build APK

Example release build with deployed backend URL:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-render-service.onrender.com
```

The generated APK will be at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Render Deployment

A Render blueprint file is included:

- `render.yaml`
- full deployment checklist: `RENDER_DEPLOYMENT.md`

### Render environment variables

Set these in Render:

- `DATABASE_URL`
- `SECRET_KEY`
- `ALGORITHM`
- `ACCESS_TOKEN_EXPIRE_MINUTES`
- `ADMIN_NAME`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

### Start command

Render will use:

```bash
python3 -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### Health check

Render uses:

```text
/health
```

This route performs a real database connectivity check.

## Test Credentials

Local verified users currently in MySQL:

- `user_9bf596dd@example.com` / `secret123`
- `api_4dfb0e8b@example.com` / `secret123`

## Verification Completed

### Backend

- Register works
- Login works
- JWT works
- Protected routes work
- CRUD tasks work
- Search works
- Filter works
- MySQL connected
- Swagger docs working

### Flutter

- `flutter analyze` passed
- `flutter test` passed

## Submission Status

### Completed locally

- Full backend
- Full Flutter app
- README
- Render deployment scaffold
- APK build command prepared

### Still requires external account/action

- Push to GitHub repository
- Deploy backend to a live Render URL
- Build final APK with the live backend URL baked in

## Notes

- For iPhone simulator, `127.0.0.1` is correct for local backend access.
- For a physical phone, use your Mac's LAN IP instead of `127.0.0.1`.
- `SETUP_LOG.md` contains the full step-by-step implementation history.
