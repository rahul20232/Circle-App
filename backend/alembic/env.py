from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import os
import sys

# Add your project root to Python path
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

# Import your database and models
from app.database import Base
from app.models.user import User
from app.models.dinner import Dinner
from app.models.booking import Booking

# this is the Alembic Config object
config = context.config

# Set your PostgreSQL database URL here
# Replace with your actual database credentials
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql://timeleft_user:timeleft_password123@localhost/timeleft_clone_db"
)

# Ensure DATABASE_URL is a string
if DATABASE_URL is None:
    raise ValueError("DATABASE_URL environment variable is not set")

config.set_main_option("sqlalchemy.url", str(DATABASE_URL))

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set the target metadata for autogenerate support
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()