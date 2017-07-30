#!/bin/bash
function _drush {
	su -s /bin/sh www-data -c "PATH=$PATH drush @default $1"
}

if _drush "status drush drupal-settings-file" | grep MISSING ; then
	/bin/bash `dirname $0`/wait-for-it.sh -t 60 ${DB_PORT#tcp://}
	yes|_drush "site-install standard --account-name=admin --account-pass=admin --db-url=mysql://$DB_ENV_MYSQL_USER:$DB_ENV_MYSQL_PASSWORD@db/$DB_ENV_MYSQL_DATABASE"
	zcat /tmp/devspace-db-sanitized.sql.gz | _drush "sql-cli" 
fi

exec "$@"

#EOF
