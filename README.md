[![Build Status](https://travis-ci.com/Data-Liberation-Front/csvlint.io.svg?branch=master)](https://travis-ci.com/Data-Liberation-Front/csvlint.io)
[![Coverage Status](https://img.shields.io/coveralls/Data-Liberation-Front/csvlint.io/badge.png)](https://coveralls.io/r/Data-Liberation-Front/csvlint.io)
[![Code Climate](https://codeclimate.com/github/Data-Liberation-Front/csvlint.io.png)](https://codeclimate.com/github/Data-Liberation-Front/csvlint.io)
[![Dependency Status](https://img.shields.io/librariesio/github/Data-Liberation-Front/csvlint.io)](https://libraries.io/github/Data-Liberation-Front/csvlint.io)
[![License](https://img.shields.io/:license-mit-green.svg)](https://theodi.mit-license.org/)
[![Documentation](https://inch-ci.org/github/Data-Liberation-Front/csvlint.io.svg?branch=master&style=shields)](https://inch-ci.org/github/Data-Liberation-Front/csvlint.io)

# CSVLint

CSVlint is an online validation tool for CSV files. It validates conformity of CSV releases to standards, checks for missing or malformed data, and can validate against both CSVW and Datapackage schema standards.

## Summary of features

CSVlint is a rails app designed to act as a continuous validation service, so that when data is changed online, the validation is updated. Data can be online or uploaded for private validation.

The validation code is actually all done in a [Ruby gem](https://github.com/Data-Liberation-Front/csvlint.rb) that can also be freely reused in other projects

Follow the [public feature roadmap for CSVLint](https://trello.com/b/2xc7Q0kd/labs-public-toolbox-roadmap?menu=filter&filter=label:CSVlint)

## Development

### Requirements

Ruby version 2.3.1

The application uses mongod and redis databases as background jobs for data persistence

`.env` file (see below)

### Environment variables

For running tests:
```
PUSHER_APP_ID
PUSHER_KEY
PUSHER_SECRET
PUSHER_CLUSTER
```

For development add:
```
AWS_ACCESS_KEY
AWS_BUCKET_NAME
AWS_SECRET_ACCESS_KEY
```

In production add:

* REDIS_PROVIDER
* CSVLINT_SESSION_SECRET

#### Setting up the required environment variables

##### Pusher setup

1. Log in to https://pusher.com
2. Create a new application and call it something sensible
3. Select the ```App Keys``` tab and get the values and paste them in to your ```.env``` file

```
PUSHER_APP_ID=
PUSHER_KEY=
PUSHER_SECRET=
```

NOTE: You may be set up for a non-default Pusher cluster (The default is ```us-east-1```), which causes some confusion. Look at your App overiew on pusher.com and get the Cluster value from the 'Keys' section. Add this to your ```.env``` file as ```PUSHER_CLUSTER=```

Create an AWS S3 bucket and grant its permissions accordingly

1. Log in to your AWS account and create an S3 bucket with a sensible name
2. Now head to the AWS IAM (Identity and Access Management page)
3. Click ```Users```
4. Add user (call it something sensible like octopub-development) and select ```Programmatic Access for Access Type```.
5. For permissions, select ```Attach existing policies directly``` - this will open a new tab in your browser.
6. CLick ```create your own policy``` and give it a name, like ```octopub-dev-permissions```, then for the policy document, use the following template, but add your own bucket name instead of ```<BUCKETNAME>```.
 ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAdminAccessToBucketOnly",
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::<BUCKETNAME>",
                "arn:aws:s3:::<BUCKETNAME>/*"
            ]
        }
    ]
}
```
7. Click ```validate policy``` just to be sure you've not made a typo. Then confirm.
8. Now back on the ```Set permissions page```, select the policy you've just created in the table by selecting the checkbox. Then click ```Review``` then ```Create user```.
9. Now download the ```csv file``` containing the credentials and add the following to your ```.env``` file

```
AWS_ACCESS_KEY_ID=<YOURNEWUSERACCESSKEY>
AWS_SECRET_ACCESS_KEY=<YOURNEWUSERSECRET>
S3_BUCKET=<YOURNEWS3BUCKETNAME>
```

## System dependencies and Configuration

Install mongo:
    `brew install mongo redis` (if using brew)

make a data directory for mongo databases
  `sudo mkdir -p /data/db`

change directory ownership so that mongodb can operate
  `sudo chown -R $USERNAME /data/`

### Development: Running the full application locally

Pre-requisites: AWS account, Pusher Account - these instructions assume you have these in place already.

Checkout the repository and run ```bundle``` in the checked out directory.

#### Database initialization

run mongo  : `mongod`

run redis  : `redis-server`

#### Services (job queues, cache servers, search engines, etc.)

to initialise the app run this in root directory of app

`foreman start`

### Known issues & Troubleshooting

If you have trouble running bundle try these (if you see errors relating to `openssl`, `eventmachine` or `therubyracer`)

`brew install openssl # if not installed`
`gem install eventmachine -v '1.0.7' -- --with-cppflags=-I/usr/local/opt/openssl/include`
`gem install libv8 -v '3.16.14.13' -- --with-system-v8`
`gem install therubyracer -- --with-v8-dir=/usr/local/opt/v8-315 `
https://github.com/shakacode/react-webpack-rails-tutorial/issues/266 ~ rubyracer with CSVlint

### Tests

ensure phantomjs is installed, `brew install phantomjs` (or however you prefer)

To run the entire suite of rspec unit tests and cucumber features execute
`bundle exec rake`

alternatively execute each suite separately with

for unit tests execute `bundle exec rspec`

for Cucumber features execute `bundle exec cucumber`

### Rake Tasks

`rake csvs:clean_up`
`rake summary:generate`
`rake clean_up:dupes`

## Deployment

### Deployment on Heroku
