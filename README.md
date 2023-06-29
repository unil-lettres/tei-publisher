
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

## Fix TEI generated app `Ooops` error

When you generate an app from the TEI-Publisher app (`Admin` in toolbar
then `App Generator`)
while running TEI-Publisher behind a proxy, you will see this error:

```
Ooops

The request to the server failed.: undefined
```

It comes from the `$config:context-path` variable seted as `""` if the
requested header has the `X-Forwarded-Host` param.

To fix it, go to `eXide - XQuery IDE` app from eXist-db launcher. Click on
the `directory` tab on the left pane and navigate
to `db -> apps -> <my app> -> modules -> config.xqm`. Search for the `$config:context-path` 
declaration and change the empty string of `then ("")` with the app url (see below).

```xquery
declare variable $config:context-path :=
    
    let $prop := util:system-property("teipublisher.context-path")

    return
        if (not(empty($prop)) and $prop != "auto") 
            then ($prop)
        else if(not(empty(request:get-header("X-Forwarded-Host"))))
            (: CHANGE HERE BY then ("/exist/apps/<my app>") :)
            then ("")  
        else ( 
            request:get-context-path() || substring-after($config:app-root, "/db") 
        )  
;
```

> You should note that this change is made for a proxy that redirect the traffic
without altering the default path of eXist - db. You must adjust the path regarding of your proxy configuration.

## Ressources

* [Goods production practices](https://exist-db.org/exist/apps/doc/production_good_practice)
* [eXist-db users and groups](https://exist-db.org/exist/apps/doc/security)
* [Create and host your own Docker image for single TEI-Publisher app](https://faq.teipublisher.com/hosting/docker-compose/)
* [Configure a proxy](https://exist-db.org/exist/apps/doc/production_web_proxying) 
* [Issues about proxies](https://faq.teipublisher.com/general/proxy/)
* [Discussion about issues with proxies for multi-app usage](https://github.com/eeditiones/tei-publisher-app/issues/74)
