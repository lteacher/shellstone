#!/usr/bin/env bash
set -e

drop_sql="drop database if exists test;"
create_sql="create database test;"

# Mysql setup
# docker exec -i mysql mysql -uroot -proot -e "$mysql"
docker exec -i mysql mysql -uroot -proot -e "$drop_sql"
docker exec -i mysql mysql -uroot -proot -e "$create_sql"

# Postgres setup
docker exec -i postgres psql -U postgres -c "$drop_sql"
docker exec -i postgres psql -U postgres -c "$create_sql"
# docker exec -i postgres psql -U postgres test -c "$postgres"

# Run the tests
dart test/tests.dart
