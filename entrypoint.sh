#!/bin/bash
if drush @default status drush drupal-settings-file | grep MISSING ; then
	/bin/bash `dirname $0`/wait-for-it.sh -t 60 ${DB_PORT#tcp://}
	yes|drush @default site-install standard --account-name=admin --account-pass=admin --db-url=mysql://$DB_ENV_MYSQL_USER:$DB_ENV_MYSQL_PASSWORD@db/$DB_ENV_MYSQL_DATABASE
	zcat /tmp/devspace-db-sanitized.sql.gz | drush @default sql-cli 
fi

exec "$@"

#EOF
