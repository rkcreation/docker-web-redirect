# Docker Web-Redirect #

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/rkcreation/web-redirect?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/rkcreation/web-redirect?style=for-the-badge) ![Docker Stars](https://img.shields.io/docker/stars/rkcreation/web-redirect?style=for-the-badge) ![GitHub stars](https://img.shields.io/github/stars/rkcreation/docker-web-redirect?label=GitHub%20Stars&style=for-the-badge) ![GitHub last commit](https://img.shields.io/github/last-commit/rkcreation/docker-web-redirect?style=for-the-badge)

This Docker container listens on port 80 and redirects all web traffic permanently to the given target domain/URL.

## Features ##
- Lightweight: Uses only ~2 MB RAM on Linux
- Keeps the URL path and GET parameters
- Permanent redirect (HTTP 301) or Temporary redirect (HTTP 302)

## Usage ##
### Docker run ###
The target domain/URL is set by the `REDIRECT_TARGET` environment variable.
The redirect type is set by the `REDIRECT_STATUS` environment variable (defaults to 301, may be set to 301 or 302 only).
Possible redirect targets include domains (`<NEW_DOMAIN.COM>`), paths (`<NEW_DOMAIN.COM>/my_page`) or specific protocols (`https://<NEW_DOMAIN.COM>/my_page`).  

**Example:** `$ docker run --rm -d -e REDIRECT_TARGET=<NEW_DOMAIN.COM> -p 80:80 rkcreation/web-redirect`

### Paths are retained ###
The URL path and GET parameters are retained. That means that a request to `http://<OLD_DOMAIN.COM>/index.php?page=2` will be redirected to `http://<NEW_DOMAIN.COM>/index.php?page=2` when `REDIRECT_TARGET=<NEW_DOMAIN.COM>` is set.

### Permanent redirects ###
Redirects are permanent (HTTP status code 301). That means browsers will cache the redirect and will go directly to the new site on further requests. Also search engines will recognize the new domain and change their URLs. This means this image is not suitable for temporary redirects e.g. for site maintenance.

## Docker Compose ##
### With Jwilder Proxy ###
This image can be combined with the [jwilder nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/). A sample docker-compose file that redirects `<OLD_DOMAIN.COM>` to `<NEW_DOMAIN.COM>` could look like this:

```yaml
version: '3'
services:
  redirect:
    image: rkcreation/web-redirect:latest
    restart: always
    environment:
      - VIRTUAL_HOST=<OLD_DOMAIN.COM>
      - REDIRECT_TARGET=<NEW_DOMAIN.COM>
      - REDIRECT_STATUS=301
```

### With Traefik ###
This image can be combined with [traefik proxy](https://docs.traefik.io/). A sample docker-compose file that redirects `<OLD_DOMAIN.COM>` to `<NEW_DOMAIN.COM>` could look like this:

```yaml
version: '3'
services:
  redirect:
    image: rkcreation/web-redirect:latest
    restart: always
    environment:
      - REDIRECT_TARGET=<NEW_DOMAIN.COM>
      - REDIRECT_STATUS=301
    labels:
      - "traefik.frontend.rule=Host:<OLD_DOMAIN.COM>;"
```
