#!/usr/bin/env bash
set -e

# Setup the sql statement required
sql="drop database if exists test;
create database test;
use test;
drop table if exists user;
create table user(
	id int not null auto_increment,
	firstName varchar(255),
	lastName varchar(255),
	username varchar(40),
	password varchar(40),
	primary key (id)
	);"

sleep 5

# Boom, docker town
docker exec -i mysql mysql -uroot -proot -e "$sql"

# Run the tests
dart test/tests.dart
