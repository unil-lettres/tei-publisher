
# Introduction

Docker-compose file and application settings for the TEI-Publisher server
installation and configuration.

[TEI-Publisher](https://teipublisher.com/index.html) is a free publishing toolbox
build on [eXist-db](https://exist-db.org/exist/apps/homepage/index.html).

The docker compose file uses a [first party docker
image](https://hub.docker.com/r/existdb/teipublisher) from docker hub.

## Run the server for development

Execute `docker compose up -d` to run the server.
It will be served at [http://127.0.0.1:9010](http://127.0.0.1:9010).

## Deployment for production

Make sure to copy & rename the **docker-compose.override.yml.prod** file to
**docker-compose.override.yml**.

`cp docker-compose.override.yml.prod docker-compose.override.yml`

Execute `docker compose up -d` to run the server. It will be served at [http://127.0.0.1:9010](http://127.0.0.1:9010).

## Login

The default admin password is empty (no password), the user is `admin`.
[Read more here](https://exist-db.org/exist/apps/doc/security).

The default tei admin user is `tei` and password is `simple`.
[Read more here](https://faq.teipublisher.com/general/publisherlogin/).


__It's strongly advised to change these default values.__

# Upgrade

You can upgrade TEI-Publisher from the admin panel. Don't forget to update
`docker-compose.yml` to the upgraded version after doing so.

# Documentation

* [Goods production practices](https://exist-db.org/exist/apps/doc/production_good_practice)
* [eXist-db users and groups](https://exist-db.org/exist/apps/doc/security)
* [Create and host your own Docker image for single TEI-Publisher app](https://faq.teipublisher.com/hosting/docker-compose/)
* [Configure a proxy](https://exist-db.org/exist/apps/doc/production_web_proxying) 
* [Issues about proxies](https://faq.teipublisher.com/general/proxy/)
* [Discussion about issues with proxies for multi-app usage](https://github.com/eeditiones/tei-publisher-app/issues/74)
