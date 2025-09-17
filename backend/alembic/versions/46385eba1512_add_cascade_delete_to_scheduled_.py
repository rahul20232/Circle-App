"""Add cascade delete to scheduled_notifications.booking_id

Revision ID: 46385eba1512
Revises: 6d5a21b68ba3
Create Date: 2025-09-04 22:21:43.237337

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '46385eba1512'
down_revision: Union[str, Sequence[str], None] = '6d5a21b68ba3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
