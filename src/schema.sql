pragma foreign_keys = on;

create table cards (
    card_hash text primary key,
    added_at text not null,
    last_reviewed_at text,
    stability real,
    difficulty real,
    interval_raw real,
    interval_days integer,
    due_date text,
    review_count integer not null
) strict;

CREATE INDEX IF NOT EXISTS idx_cards_due_date ON cards(due_date);

