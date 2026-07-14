"""add food log confidence and updated at

Revision ID: 202607100003
Revises: 202607100002
Create Date: 2026-07-10 00:00:03
"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "202607100003"
down_revision: str | Sequence[str] | None = "202607100002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("food_logs", sa.Column("confidence", sa.Float(), nullable=True))
    op.add_column(
        "food_logs",
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )


def downgrade() -> None:
    op.drop_column("food_logs", "updated_at")
    op.drop_column("food_logs", "confidence")
