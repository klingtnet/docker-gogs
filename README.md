# [gogs](http://gogs.io) as a docker service

## build the docker image

```sh
docker build -t gogs .
```

Please be patient, this could some minutes.

## run script

**WARNING**: When you run gogs for the first time, it will serve the installation form, where you can setup an admin account, on the web interface. Make sure that this is not accessible from the outside! After you made the initial setup everything is save to serve on the web. Note that you **can not** use **admin** for the administrator account name, [see](http://gogs.io/docs/intro/troubleshooting.html#form-validation).

- use an ssh tunnel to access the container for the initial setup: `ssh -L LOCAL_PORT:domain:REMOTE_PORT domain`

Because docker can't mount relative paths you have to call the run script with an absolute path, or more conviently: `$PWD/run.sh`.

## configuration

- follows ...

### https nginx example config

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
