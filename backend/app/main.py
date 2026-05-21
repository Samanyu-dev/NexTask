from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routes.auth import router as auth_router
from app.routes.task import router as task_router

# Import models so SQLAlchemy registers tables before create_all.
from app.models import task, user  # noqa: F401

app = FastAPI(title="NexTask API")

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


@app.get("/")
def health_check():
    return {"message": "NexTask API is running"}


app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(task_router, prefix="/tasks", tags=["Tasks"])
