"""Add cascade delete for scheduled_notifications.booking_id

Revision ID: 6d5a21b68ba3
Revises: 8a409673ce3b
Create Date: 2025-09-04 22:20:07.633303

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '6d5a21b68ba3'
down_revision: Union[str, Sequence[str], None] = '8a409673ce3b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    # Drop existing constraint (if any)
    op.drop_constraint(
        'scheduled_notifications_booking_id_fkey',
        'scheduled_notifications',
        type_='foreignkey'
    )
    # Create new FK with cascade delete
    op.create_foreign_key(
        'scheduled_notifications_booking_id_fkey',
        'scheduled_notifications', 'bookings',
        ['booking_id'], ['id'],
        ondelete='CASCADE'
    )

def downgrade():
    # Drop the cascade version
    op.drop_constraint(
        'scheduled_notifications_booking_id_fkey',
        'scheduled_notifications',
        type_='foreignkey'
    )
    # Recreate without cascade (plain FK)
    op.create_foreign_key(
        'scheduled_notifications_booking_id_fkey',
        'scheduled_notifications', 'bookings',
        ['booking_id'], ['id']
    )
