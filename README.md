# [gogs](http://gogs.io) as a Docker Service

## Create the Data Container

```sh
docker create --name gogs-data --volume /home/gogs --volume /etc/ssh --volume /opt/gogs/custom --volume /opt/gogs/log klingtdotnet/gogs
```

## First Run

```sh
docker run --rm --volumes-from gogs-data -p 8080:3000 -it klingtdotnet/gogs
```

- set the *run user* to `gogs`
- set the location of your SQlite database to something below `/home/gogs` becaust this is mounted from the data container

**WARNING**: When you run gogs for the first time, it will serve the installation form, where you can setup an admin account, on the web interface. Make sure that this is not accessible from the outside! After you made the initial setup everything is save to serve on the web. Note that you **can not** use **admin** for the administrator account name, [see](http://gogs.io/docs/intro/troubleshooting.html#form-validation).

- use an ssh tunnel to access the container for the initial setup: `ssh -L LOCAL_PORT:domain:REMOTE_PORT domain`

- I would recommend to check the configuration of `sshd` (disable X11 forwarding, root login and password authentification) and [gogs](http://gogs.io/docs/advanced/configuration_cheat_sheet.html) afterwards:

```sh
docker run --rm --volumes-from gogs-data -it klingtdotnet/vim /bin/bash
```

## Run as SystemD Service

ToDo ...

### HTTP(s) nginx Example Config

- it is not possible (at least I don't know how) for an ssh server to listen on a suburl, like `some.domain/git`, so I decided to use sub domain instead

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name git.some.domain.name;
    return 301 https://git.some.domain.name$request_uri;
}

server {
    listen       443 ssl spdy;
    listen       [::]:443 ssl spdy;
    server_name  git.some.domain.name;

    ssl_certificate         /etc/nginx/ssl/git_some_domain_name.crt;
    ssl_certificate_key     /etc/nginx/ssl/git_some_domain_name.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    location / {
        proxy_pass  http://localhost:18000/;
    }
}
```
