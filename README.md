[![Build Status](http://b.adge.me/travis/theodi/csvlint.png)](https://travis-ci.org/theodi/csvlint)
[![Coverage Status](http://b.adge.me/coveralls/theodi/csvlint/badge.png)](https://coveralls.io/r/theodi/csvlint)
[![Code Climate](https://codeclimate.com/github/theodi/csvlint.png)](https://codeclimate.com/github/theodi/csvlint)
[![Dependency Status](https://gemnasium.com/theodi/csvlint.png)](https://gemnasium.com/theodi/csvlint)
[![License](http://b.adge.me/:license-mit-green.svg)](http://theodi.mit-license.org/)
 
# CSVLint

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

## Ruby version

2.3.1

## System dependencies

mongod and redis databases working away in background

## Configuration

*Install mongo*
brew install mongo redis

*make a data directory for mongo databases*
sudo mkdir -p /data/db

*change directory ownership so that mongo can do its thing*
sudo chown -R $USERNAME /data/

*run mongo*
mongod

*run redis*
redis-server

*to initialise the app run this in root dir of app*

foreman start

## Database creation

Its a MONGODB so it creates things on the fly as needed, however configuration above must be complete

## Database initialization

## How to run the test suite

ensure phantomjs is installed, brew install phantomjs (or however you prefer)

## Services (job queues, cache servers, search engines, etc.)

make sure cucumber dependencies up to date

## Deployment instructions

## Environment variables

For running tests:

* PUSHER_APP_ID
* PUSHER_KEY
* PUSHER_SECRET
* PUSHER_CLUSTER

For development add:

* AWS_ACCESS_KEY
* AWS_BUCKET_NAME
* AWS_SECRET_ACCESS_KEY

In production add:

* REDIS_PROVIDER
* CSVLINT_SESSION_SECRET
