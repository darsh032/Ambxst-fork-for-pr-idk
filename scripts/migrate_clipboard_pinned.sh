#!/bin/bash
# Migration script to add 'pinned' column to clipboard database

DB_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/quickshell/clipboard.db"

if [ ! -f "$DB_PATH" ]; then
    echo "Database not found at: $DB_PATH"
    echo "No migration needed - new database will be created with schema."
    exit 0
fi

echo "Migrating clipboard database at: $DB_PATH"

# Check if pinned column already exists
COLUMN_EXISTS=$(sqlite3 "$DB_PATH" "PRAGMA table_info(clipboard_items);" | grep -c "pinned")

if [ "$COLUMN_EXISTS" -eq 0 ]; then
    echo "Adding 'pinned' column to clipboard_items table..."
    sqlite3 "$DB_PATH" "ALTER TABLE clipboard_items ADD COLUMN pinned INTEGER NOT NULL DEFAULT 0;"
    
    echo "Creating index on 'pinned' column..."
    sqlite3 "$DB_PATH" "CREATE INDEX IF NOT EXISTS idx_pinned ON clipboard_items(pinned DESC);"
    
    echo "Migration completed successfully!"
else
    echo "'pinned' column already exists. No migration needed."
fi
