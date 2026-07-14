"""create food logs table

Revision ID: 202607100002
Revises: 202607100001
Create Date: 2026-07-10 00:00:02
"""

from collections.abc import Sequence

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "202607100002"
down_revision: str | Sequence[str] | None = "202607100001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "food_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("image_url", sa.String(length=2048), nullable=True),
        sa.Column("detected_food_name", sa.String(length=255), nullable=False),
        sa.Column("calories", sa.Integer(), nullable=False),
        sa.Column("protein", sa.Float(), nullable=False),
        sa.Column("carbs", sa.Float(), nullable=False),
        sa.Column("fat", sa.Float(), nullable=False),
        sa.Column("serving_size", sa.String(length=100), nullable=True),
        sa.Column("ai_response", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column(
            "created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_food_logs_created_at"), "food_logs", ["created_at"], unique=False)
    op.create_index(op.f("ix_food_logs_user_id"), "food_logs", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_food_logs_user_id"), table_name="food_logs")
    op.drop_index(op.f("ix_food_logs_created_at"), table_name="food_logs")
    op.drop_table("food_logs")
