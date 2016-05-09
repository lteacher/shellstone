#!/usr/bin/env bash
set -e

# Create table for mysql
mysql="drop database if exists test;
create database test;
use test;
drop table if exists user;
CREATE TABLE user(
	id int not null auto_increment,
	firstName varchar(255),
	lastName varchar(255),
	username varchar(40),
	password varchar(40),
	primary key (id)
	);"

# Create table for postgres
postgres="
drop table if exists useracc;
CREATE TABLE useracc(
	id serial,
	firstName varchar(255),
	lastName varchar(255),
	username varchar(40),
	password varchar(40),
	primary key (id)
	);"

# Mysql setup
docker exec -i mysql mysql -uroot -proot -e "$mysql"

# Postgres setup
docker exec -i postgres psql -U postgres -c "drop database if exists test;"
docker exec -i postgres psql -U postgres -c "create database test;"
docker exec -i postgres psql -U postgres test -c "$postgres"

# Run the tests
dart test/tests.dart
