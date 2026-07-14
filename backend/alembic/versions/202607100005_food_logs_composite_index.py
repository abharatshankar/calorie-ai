"""replace single-column food_log indexes with a composite (user_id, created_at) index

Revision ID: 202607100005
Revises: 202607100004
Create Date: 2026-07-14 00:00:00
"""

from collections.abc import Sequence

from alembic import op

revision: str = "202607100005"
down_revision: str | Sequence[str] | None = "202607100004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # Composite index serves "WHERE user_id = ? ORDER BY created_at DESC" (the
    # hot list/history/dashboard path) with a single index range scan, and its
    # leading column covers plain user_id lookups / FK cascade deletes.
    op.create_index(
        "ix_food_logs_user_id_created_at",
        "food_logs",
        ["user_id", "created_at"],
        unique=False,
    )
    # Now redundant: fully covered by the composite index above.
    op.drop_index(op.f("ix_food_logs_user_id"), table_name="food_logs")
    op.drop_index(op.f("ix_food_logs_created_at"), table_name="food_logs")


def downgrade() -> None:
    op.create_index(op.f("ix_food_logs_created_at"), "food_logs", ["created_at"], unique=False)
    op.create_index(op.f("ix_food_logs_user_id"), "food_logs", ["user_id"], unique=False)
    op.drop_index("ix_food_logs_user_id_created_at", table_name="food_logs")
