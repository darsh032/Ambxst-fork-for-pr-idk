#!/bin/bash
# Migration script to add 'alias' column to clipboard database

DB_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/quickshell/clipboard.db"

if [ ! -f "$DB_PATH" ]; then
    echo "Database not found at: $DB_PATH"
    echo "No migration needed - new database will be created with schema."
    exit 0
fi

echo "Migrating clipboard database at: $DB_PATH"

# Check if alias column already exists
COLUMN_EXISTS=$(sqlite3 "$DB_PATH" "PRAGMA table_info(clipboard_items);" | grep -c "alias")

if [ "$COLUMN_EXISTS" -eq 0 ]; then
    echo "Adding 'alias' column to clipboard_items table..."
    sqlite3 "$DB_PATH" "ALTER TABLE clipboard_items ADD COLUMN alias TEXT;"
    
    echo "Migration completed successfully!"
else
    echo "'alias' column already exists. No migration needed."
fi
