# GPII DeveloperSpace Docker

This repository contains an initial docker file for use in creating a local development or demonstration version of the GPII DeveloperSpace site. 

Current status is that this is still very much a work in progress. 

## Init

Get the submodules using
	git submodule update --init 
	git submodule update --init --recursive

## Build

The build process looks something like the following:

    docker-compose build 

## Run

The running it looks something like the following:

    docker-compose up 

## Configure/Test

Call something like this to get a login:
    docker-compose exec -u www-data drupal drush @default uli admin

Replace "default" in the URL with your local docker ip-address
