#!/bin/bash
until mysqladmin ping -h mysql -u root -prootpass --silent; do
  echo 'Waiting for MySQL...'
  sleep 2
done
echo 'MySQL is ready!'