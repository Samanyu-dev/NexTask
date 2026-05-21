from fastapi import FastAPI

from app.database import Base, engine
from app.routes.auth import router as auth_router

# Import models so SQLAlchemy registers tables before create_all.
from app.models import task, user  # noqa: F401

app = FastAPI(title="NexTask API")


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)


@app.get("/")
def health_check():
    return {"message": "NexTask API is running"}


app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
