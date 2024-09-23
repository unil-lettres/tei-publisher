
# Introduction

This is a basic exist-db server with TEI-Publisher dependencies pre-installed.
It does not contains neither the TEI-Publisher app nor any fork of TEI-Publisher so you
can install your own package easily.

[TEI-Publisher](https://teipublisher.com/index.html) is a free publishing toolbox
built on [eXist-db](https://exist-db.org/exist/apps/homepage/index.html).

# Run the server for development

Copy the `example.env` file to `.env` with `cp example.env .env` and changes the
required values. You must set a unique name for the Docker container so if
you have multiple clones of this repository, it will not overlap each others.

Execute `docker compose up -d` to run the server.
It will be served at [http://127.0.0.1:9010](http://127.0.0.1:9010).
Adapt the port number according to your `.env` file.

# Deployment for production

Make sure to copy & rename the production files.

```bash
cp example.env .env
cp docker-compose.override.yml.prod docker-compose.override.yml
cp conf/conf.xml.prod conf/conf.xml
cp conf/controller-config.xml.prod conf/controller-config.xml
cp conf/web.xml.prod conf/web.xml
```

Change the `.env` required values. You must set a unique name for the Docker container so if you have multiple clones of this repository, it will not overlap each others.

Execute `docker compose up -d` to run the server. It will be served at [http://127.0.0.1:9010](http://127.0.0.1:9010).
Adapt the port number according to your `.env` file.

Run the `init.sh` script to apply the values set in your `.env` file (it will set
the admin password and more). This script should only be executed once.

# Update

> Be carefull that the dependencies of the new tag match the one used by your packages.

Change the docker tag you want to use and run:

```bash
docker compose down
docker compose pull
docker compose up -d
```

## Production manual configuration
The docker compose prod file uses configuration files located in conf folder.
These files are configured for production use. Tweak them to suit your needs.

The `.orig` files are used to easily compare the changes made for the production
configurations.

## Install your own packages
Just put your `.xar` packages in the autodeploy folder. Then restart the
container to deploy them automatically.

```bash
docker compose restart
```

## Using a Proxy
It is strongly recommended to put your application behind a proxy so you can't
access exist-db dashboard and other apps (eXide, etc...).

See the [official documentation](https://www.exist-db.org/exist/apps/doc/production_web_proxying) for more informations.

Depending on the TEI-Publisher context-path, you could need to append a `/` to the proxy pass directive.

```conf
ProxyPass / http://127.0.0.1:4200/exist/apps/<my-app>/ nocanon
ProxyPassReverse / http://127.0.0.1:4200/exist/apps/<my-app>/
````
Where `<my-app>` is the actual name of your app.

On top of that, consider the [following issue](https://faq.teipublisher.com/general/proxy/).

> Use cases are demonstrated at the end of this document.

## Restrict access to api.html

In most cases, `api.html` is not useful in production. We recommend to restrict
its access from your proxy configuration.

In Apache2, simply add the following directive in your VirtualHost:

```apache
<Location "/my-site/api.html">
    Require all denied
</Location>
```

## Accessing the app in a subfolder

The path TEI-Publisher uses is configured by the `teipublisher.context-path` system property.

> There is only one property and you could have multiple TEI-Publisher apps in 
the same exist-db instance. In that case, you should use the last
method and change the `$config:context-path` variable directly in the sources of each apps.

You have differents ways to change it.

### In .env file (recommended)
You can specify the `TEIPUBLISHER_CONTEXT_PATH` env var in your `.env` file. It will automatically be set when running the container.

### When running the jetty server

Run the server with the `-Dteipublisher.context-path=/path/to/my/app`.

### In the sources package of your TEI-Publisher app

Edit the file `db/apps/<my app>/modules/config.xqm` and change the `$config:context-path` variable to be the path of your app:

```xquery
declare variable $config:context-path :=

    let $prop := util:system-property("teipublisher.context-path")

    return
        if (not(empty($prop)) and $prop != "auto")
            then ($prop)
        else if(not(empty(request:get-header("X-Forwarded-Host"))))
            then ("")
        else (
            request:get-context-path() || substring-after($config:app-root, "/db")
        )
;
```

# Login

The default admin password is empty (no password), the user is `admin`.
[Read more here](https://exist-db.org/exist/apps/doc/security).

⚠️ Execute the `init.sh` script to change the default password for the one specified
in your `.env` file.

# Documentation

### Executing an xQuery function

Functions can be execute with:

```bash
docker exec my-tei-publisher-container-name java org.exist.start.Main client -q -u admin -P 'password' -x "your xQuery function"
```

where `your xQuery command` is an xQuery function, `my-tei-publisher-container-name` is the name of your container specified in `.env` and `password` is the admin password.

You can see the list of xQuery functions [here](https://exist-db.org/exist/apps/fundocs/index.html).

> Boolean values are specified with `true()` and `false()`.

### Executing an xQuery script

You can execute a script file with:

```bash
docker exec my-tei-publisher-container-name java org.exist.start.Main client -q -u admin -P 'password' -F '/path/to/your/script.xq'
```

where `password` is the admin password, `my-tei-publisher-container-name` is the name of your container specified in `.env` and `/path/to/your/script.xq` is the absolute path to your script on the container.

Here it is an example of a xQuery script that will remove the monex package:

```xquery
xquery version "3.1";

(: See avaiable function here: https://exist-db.org/exist/apps/fundocs/index.html :)

import module namespace repo="http://exist-db.org/xquery/repo";
import module namespace sm="http://exist-db.org/xquery/securitymanager";

(: Use repo:list() to see all installed repo :)

(: Uninstall monex package and associated user and group :)
repo:undeploy("http://exist-db.org/apps/monex"),
repo:remove("http://exist-db.org/apps/monex"),
sm:remove-account("monex"),
sm:remove-group("monex")
```

You can see the list of xQuery functions [here](https://exist-db.org/exist/apps/fundocs/index.html).
You can see an example of the post install script of the base TEI-Publisher app [here](https://github.com/eeditiones/tei-publisher-app/blob/master/post-install.xql).


# Use cases
## Proxy using a subfolder for accessing an app
Accessing your app from `http://<servername>/<myapp>`.

`.env`
```env
TEIPUBLISHER_CONTEXT_PATH=/myapp
```

> If you have multiple TEI-Publisher apps, you must set the context path
directly in the sources of your app (see [Accessing the app in a subfolder](#accessing-the-app-in-a-subfolder)).

`myapp.cnf`
```apache
# /myapp: the context_path specified by `TEIPUBLISHER_CONTEXT_PATH` env.
# <port>: the port specified by `DOCKER_HOST_PORT` env.
# <servername>: the servername
# <myapp>: the name of your app (colllection)
<Location /myapp>
    ProxyPass http://127.0.0.1:<port>/exist/apps/<myapp> nocanon
    ProxyPassReverse http://127.0.0.1:<port>/exist/apps/myapp
    ProxyPassReverseCookieDomain 127.0.0.1 <servername>
    ProxyPassReverseCookiePath /exist /

    RewriteEngine On
    RewriteRule ^/(.*)$     /$1   [PT]
</Location>
```

## Proxy using a subfolder for accessing the root existdb (dashboard and every installed apps, not recommended)
Accessing your app from `http://<servername>/exist`.

> Leave `TEIPUBLISHER_CONTEXT_PATH` env to the default value.

`myapp.cnf`
```apache
# <port>: the port specified in docker-compose file.
# <servername>: the servername (ServerName property)
<Location /exist>
    ProxyPass http://127.0.0.1:<port>/exist nocanon
    ProxyPassReverse http://127.0.0.1:<port>/exist
    ProxyPassReverseCookieDomain 127.0.0.1 <servername>
    ProxyPassReverseCookiePath /exist /

    RewriteEngine On
    RewriteRule ^/(.*)$     /$1   [PT]
</Location>
```

## Proxy accessing an app (or existdb dashboard) from the root url

Accessing your app from `http://<servername>`.

`.env`
```env
# For existdb dashboard, leave the default value.
TEIPUBLISHER_CONTEXT_PATH=/
```

`myapp.cnf`
```apache
# <port>: the port specified in docker-compose file.
# <servername>: the servername (ServerName property)
# <myapp>: the name of your app (colllection)
<VirtualHost *:443>
    DocumentRoot /path/to/www
    ServerName <servername>

    ProxyRequests Off

    # For existdb dashboard, remove '/apps/<myapp>/'.
    ProxyPass / http://127.0.0.1:<port>/exist/apps/<myapp>/ nocanon
    ProxyPassReverse / http://127.0.0.1:<port>/exist/apps/<myapp>/
    ProxyPassReverseCookieDomain 127.0.0.1 <servername>
    ProxyPassReverseCookiePath /exist /

    RewriteEngine on
    RewriteRule ^/(.*)$     /$1   [PT]
</VirtualHost>
```

# Ressources

* [Goods production practices](https://exist-db.org/exist/apps/doc/production_good_practice)
* [eXist-db users and groups](https://exist-db.org/exist/apps/doc/security)
* [Create and host your own Docker image for single TEI-Publisher app](https://faq.teipublisher.com/hosting/docker-compose/)
* [Configure a proxy](https://exist-db.org/exist/apps/doc/production_web_proxying)
* [Issues about proxies](https://faq.teipublisher.com/general/proxy/)
* [Discussion about issues with proxies for multi-app usage](https://github.com/eeditiones/tei-publisher-app/issues/74)
