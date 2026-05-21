import os
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.database import Base, SessionLocal, engine, ensure_schema
from app.routes.admin import router as admin_router
from app.routes.auth import router as auth_router
from app.routes.task import router as task_router
from app.services.auth_service import ensure_admin_user

# Import models so SQLAlchemy registers tables before create_all.
from app.models import task, user  # noqa: F401

app = FastAPI(title="NexTask API")
ADMIN_DIST_DIR = Path(__file__).resolve().parents[2] / "admin" / "dist"

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    ensure_schema()
    seed_admin_user()


def seed_admin_user():
    admin_email = os.getenv("ADMIN_EMAIL")
    admin_password = os.getenv("ADMIN_PASSWORD")
    admin_name = os.getenv("ADMIN_NAME", "NexTask Admin")

    if not admin_email or not admin_password:
        return

    db = SessionLocal()
    try:
        ensure_admin_user(
            db,
            name=admin_name,
            email=admin_email,
            password=admin_password,
        )
    finally:
        db.close()


@app.get("/")
def health_check():
    return {"message": "NexTask API is running"}


app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(task_router, prefix="/tasks", tags=["Tasks"])
app.include_router(admin_router, prefix="/admin-api", tags=["Admin"])

if ADMIN_DIST_DIR.exists():
    app.mount("/admin", StaticFiles(directory=ADMIN_DIST_DIR, html=True), name="admin")
