FROM alpine:3.5
RUN apk add --no-cache git

RUN mkdir -p /var/www && chown -R 33:33 /var/www

# share local gpii.net copy (make it bare)
COPY .git/modules/gpii.net/ /tmp/gpii.net.git
RUN sed -i '/^\s*worktree/d' /tmp/gpii.net.git/config 
RUN git -C /tmp/gpii.net.git config --bool core.bare true 

# do everything as www-data to get correct permissions 
USER 33:33
RUN cd /var/www && git init && git fetch /tmp/gpii.net.git  && git checkout FETCH_HEAD 

#init submodules
RUN git -C /var/www submodule update --init --recursive

#replace default dir with symlink
RUN ln -s web /var/www/html
RUN ln -s developerspace.gpii.net /var/www/html/sites/default

#Copy Data
COPY devspace-makefile/devspace-db-sanitized.sql.gz /var/www

RUN mkdir /var/www/solr && cp -R /var/www/web/sites/all/modules/search_api_solr/solr-conf/5.x /var/www/solr/conf
