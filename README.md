# Dockerfile

Dockerfile For PHP 8 FPM + Nginx Applications

# Instructions

Push this image to the git repository, that should trigger a build on DockerHub https://hub.docker.com/repository/docker/trellyzltd/laravel8-infrastructure

Your docker-compose should replace the `nginx.conf` in case you need something other than the configs in this directory: `./laravel-dev/nginx.conf`

> That config `./laravel-prod/nginx.conf` is optimized for the AWS ELB auto deployment and won't work for localhost deployments.

# Using the Image

Once the build is complete you can use this image:

`toxaco/docker-laravel-php8:__TAG_VERSION__`

> **TAG_VERSION** from github repository, for example: `toxaco/docker-laravel-php8:latest`

# Example docker-compose

    version: '2'

    # For localhost it create an isolated network for the containers.
    networks:
        default:
            external:
                name: dev

    services:

        app:
            image: toxaco/docker-laravel-php8:latest
            container_name: my_app
            privileged: true
            ports:
                - "80:80"
            environment:
                VIRTUAL_HOST: "dev.myapp.com"
                VIRTUAL_PORT: 80
                APP_NAME: "My App"
                APP_ENV: "local"
                APP_DEBUG: "true"
                APP_LOG_LEVEL: "debug"
            volumes:
                # This is the application origin relative to this docker-compose, then the path in the container.
            - ./:/var/www/html
            # This allow to replace the supervisor, in case it's necessary.
            - ./supervisord.conf:/etc/supervisor/conf.d/supervisord.conf
                # This is the nginx config origin relative to this docker-compose, then the path in the container.
            - ./laravel-dev/nginx.conf:/etc/nginx/nginx.conf
            command:
            - "/usr/bin/supervisord"
