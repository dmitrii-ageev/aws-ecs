#!/bin/sh
set -eu

if [ -z "$1" ]; then
    echo "ERROR: A repository URL must be defined!"
    exit 255
fi

location=$(dirname $0)
repository=$1

eval $(aws ecr get-login --no-include-email --region us-east-1)

image=nginx-smtp-auth

docker build -t $image $location/../docker-images/$image
docker tag $image $repository
docker push $repository
