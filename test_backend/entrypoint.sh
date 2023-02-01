#!/bin/bash

echo "Start"

# Wait until postgres container has started
while ! pg_isready -q -h "$PGHOST" -p 5432 -U "$PGUSER"; do
    echo "Waiting for DB to start"
    sleep 1
done

mix deps.get
mix compile

# Initialize DB if it doesn't exist
if [[ -z $(psql -Atqc "\list test_backend_db") ]]; then
    echo "Database test_backend_db does not exist. Creating..."
    mix ecto.create
    mix ecto.migrate
    # mix run priv/repo/seeds.exs
    echo "Database test_backend_db created."
fi
exec mix run --no-halt
