"""merge_migration_branches

Revision ID: 466911c755e5
Revises: bc1d8bdd890a, c849f6557aaa
Create Date: 2025-09-03 22:35:11.399549

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '466911c755e5'
down_revision: Union[str, Sequence[str], None] = ('bc1d8bdd890a', 'c849f6557aaa')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
