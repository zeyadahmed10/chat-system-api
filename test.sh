#!/bin/bash

LOGFILE="setup.log"

# Function to retry a command up to a specified number of times
retry() {
  local n=1
  local max=5
  local delay=5
  while true; do
    "$@" 2>&1 | tee -a $LOGFILE && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:" | tee -a $LOGFILE
        sleep $delay;
      else
        echo "The command has failed after $n attempts." | tee -a $LOGFILE
        return 1
      fi
    }
  done
}

# Step 1: Wait for Elasticsearch to start
echo "Waiting for Elasticsearch to start..." | tee -a $LOGFILE
HOST="$1"
until $(curl --output /dev/null --silent --head --fail $HOST); do
    printf "Waiting for $1 to be up\n"
    sleep 1
done
echo "Elasticsearch is up!" | tee -a $LOGFILE

# Step 2: Create the database with retry logic
echo "Creating database..." | tee -a $LOGFILE
retry bundle exec rake db:create
if [ $? -ne 0 ]; then
  echo "Failed to create database after multiple attempts - exiting" | tee -a $LOGFILE
  exit 1
fi

# Step 3: Run migrations with retry logic
echo "Running migrations..." | tee -a $LOGFILE
retry bundle exec rake db:migrate
if [ $? -ne 0 ]; then
  echo "Failed to run migrations after multiple attempts - exiting" | tee -a $LOGFILE
  exit 1
fi

# Step 4: Create Elasticsearch index
echo "Creating Elasticsearch index..." | tee -a $LOGFILE
retry bundle exec rake es:create_index
if [ $? -ne 0 ]; then
  echo "Failed to create Elasticsearch index after multiple attempts - exiting" | tee -a $LOGFILE
  exit 1
fi

# Step 5: Start the Rails server and Sidekiq
echo "Starting Rails server and Sidekiq..." | tee -a $LOGFILE
(bundle exec rails s -p 3000 -b '0.0.0.0' & bundle exec sidekiq) 2>&1 | tee -a $LOGFILE
