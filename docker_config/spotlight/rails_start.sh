#!/usr/bin/env bash

export APP_DIR=/spotlight

cd $APP_DIR

# Run the database migrations (if any)
bundle exec rails db:migrate

# Use "exec" to start Rails so that the application will receive the SIGTERM
# sent to the root process (PID 1), giving the application a chance to
# gracefully shutdown.
exec bundle exec rails server -b 0.0.0.0
