"""add nutrition summary to food logs

Revision ID: 202607100004
Revises: 202607100003
Create Date: 2026-07-11 00:00:00
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "202607100004"
down_revision: Union[str, Sequence[str], None] = "202607100003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "food_logs",
        sa.Column("nutrition_summary", sa.String(length=1024), nullable=False, server_default=""),
    )
    op.alter_column("food_logs", "nutrition_summary", server_default=None)


def downgrade() -> None:
    op.drop_column("food_logs", "nutrition_summary")
