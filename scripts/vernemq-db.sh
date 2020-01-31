#!/usr/bin/env bash

echo $HOST
echo $PORT
echo $USER
echo $PASSWORD
echo $DATABASE

cp configs/vernemq.template.yml configs/vernemq.yml
sed -i '' 's/postgres_host/'$HOST'/g' configs/vernemq.yml
sed -i '' 's/postgres_port/'$PORT'/g' configs/vernemq.yml
sed -i '' 's/postgres_user/'$USER'/g' configs/vernemq.yml
sed -i '' 's/postgres_password/'$PASSWORD'/g' configs/vernemq.yml
sed -i '' 's/postgres_database/'$DATABASE'/g' configs/vernemq.yml
