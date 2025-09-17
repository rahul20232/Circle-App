"""add_fcm_token_to_users

Revision ID: 84ee585e5049
Revises: ec73addda79a
Create Date: 2025-09-12 14:03:05.520829

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '84ee585e5049'
down_revision: Union[str, Sequence[str], None] = 'ec73addda79a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
