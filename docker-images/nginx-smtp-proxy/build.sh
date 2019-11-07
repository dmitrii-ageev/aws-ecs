#!/bin/sh
docker build -t dmitriiageev/nginx-smtp-proxy .
docker push dmitriiageev/nginx-smtp-proxy:latest
