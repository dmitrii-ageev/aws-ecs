#!/bin/sh
docker rm -f smtp-proxy
docker run --network=host --name smtp-proxy -p 25:25 dmitriiageev/nginx-smtp-proxy
