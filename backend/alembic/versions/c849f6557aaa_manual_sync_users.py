"""manual sync users

Revision ID: c849f6557aaa
Revises: ecf16553b4ae
Create Date: 2025-09-01 17:53:37.576955

"""
from typing import Sequence, Union
from sqlalchemy import inspect
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c849f6557aaa'
down_revision: Union[str, Sequence[str], None] = 'd03881528237'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:

    conn = op.get_bind()
    inspector = inspect(conn)

    columns = [c['name'] for c in inspector.get_columns('users')]


    op.add_column('users', sa.Column('dinner_languages', sa.Text(), nullable=True))
    op.add_column('users', sa.Column('dinner_budget', sa.String(), nullable=True))
    op.add_column('users', sa.Column('has_dietary_restrictions', sa.Boolean(), server_default='false', nullable=False))
    op.add_column('users', sa.Column('dietary_options', sa.Text(), nullable=True))
    op.add_column('users', sa.Column('event_push_notifications', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('event_sms', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('event_email', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('lastminute_push_notifications', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('lastminute_sms', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('lastminute_email', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('marketing_email', sa.Boolean(), server_default='true', nullable=False))
    op.add_column('users', sa.Column('is_subscribed', sa.Boolean(), server_default='false', nullable=False))
    op.add_column('users', sa.Column('subscription_start', sa.DateTime(timezone=True), nullable=True))
    op.add_column('users', sa.Column('subscription_end', sa.DateTime(timezone=True), nullable=True))
    op.add_column('users', sa.Column('subscription_type', sa.String(), nullable=True))
    op.add_column('users', sa.Column('subscription_plan_id', sa.String(), nullable=True))
    
    


def downgrade() -> None:
    op.drop_column('users', 'subscription_plan_id')
    op.drop_column('users', 'subscription_type')
    op.drop_column('users', 'subscription_end')
    op.drop_column('users', 'subscription_start')
    op.drop_column('users', 'is_subscribed')

    op.drop_column('users', 'marketing_email')
    op.drop_column('users', 'lastminute_email')
    op.drop_column('users', 'lastminute_sms')
    op.drop_column('users', 'lastminute_push_notifications')
    op.drop_column('users', 'event_email')
    op.drop_column('users', 'event_sms')
    op.drop_column('users', 'event_push_notifications')

    op.drop_column('users', 'dietary_options')
    op.drop_column('users', 'has_dietary_restrictions')
    op.drop_column('users', 'dinner_budget')
    op.drop_column('users', 'dinner_languages')
