# GPII DeveloperSpace Docker

This repository contains an initial docker file for use in creating a local development or demonstration version of the GPII DeveloperSpace site. 

Current status is that this is still very much a work in progress. 

## Build

The build process looks something like the following:

    docker build -< Dockerfile

Because docker has a habit of caching builds, it may be helpful to create new docker image from scratch using no cache:

    docker build --no-cache - < Dockerfile

## Run

Running the docker instance should look something like the following. Add virtual directories as needed based on what aspect of the site you're working on (ex. modules or theme directories). 

    docker run -d -p 8080:80 -p 8022:22 -v <<path to host directory to share>:/var/www/sites/developerspace.gpii.net --name gpii_devspace_local <<image_id>>

## Site Sync

To sync up files and database info:

1. Set up an SSH relationship with the staging server
  * ssh-keygen
  * ssh-copy-id -i ~/.ssh/id_rsa.pub username@remote-host
  * verify that you can log in without a password
1. drush sync-files @devspacestaging @self
1. rsync -r -u username@remote-host:web/sites/all/libraries/* .
1. drush sql-sync @devspacestaging @self 
1. drush sql-sanitize @self 

## Drush make

To manually update the site based on changes to the [devspace-makefile repository](https://github.com/Pushing7/devspace-makefile), run the following command from the docker shell. 

    drush make --no-core /var/dspace/dspace.make.yml

## Solr

Because much of the site requires a running Solr instance, developers will likely need to point to a running instance of Solr. 

    docker run --name gpii_solr -d -v <<path to solr configuration files>> -p 8983:8983 -t guywithnose/solr:4.6.0  

@@ need to add additional documentation about this process. Solr configuration files are not yet available in a repository, but the defaults from the search_api_solr module will work as a starting point. 

## Issues

* my.cnf and php.ini may require adjustment in order to avoid errors (@@ add details)
* build script needs to create a symlink for developerspace.gpii.net to default folder in /sites
 
