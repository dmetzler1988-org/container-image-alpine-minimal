# dmetzler1988 Universal alpine base image

The dmetzler1988 Universal alpine base image is an image based on 
[Alpine Linux](https://hub.docker.com/_/alpine) version 3.19.1 from 
[DockerHub](https://hub.docker.com/).

## Features

- based on [minimal DockerHub Alpine Linux](https://hub.docker.com/_/alpine) version 3.19.1
- uses APK as package manager

## Usage

This image can be used as a downstream image in your repository. Replace the `:latest` tag with a specific version.

```Dockerfile
FROM ghcr.io/dmetzler1988/alpine-minimal:latest

RUN apk --no-cache add python3

USER 1001
```

## Local Build

To build this image on local system, use the following command in your CLI

```shell
docker build -t dmetzler1988/alpine-minimal .
```

## Build Process

The CI/CD setup uses the [Docker build-push Action](https://github.com/docker/build-push-action) to publish container images.  
This is managed in [.github/workflows/release.yaml](./.github/workflows/release.yaml).

## License

This application is free software: you can redistribute it and/or modify it under the terms of 
the [GNU Affero General Public License v3](https://www.gnu.org/licenses/agpl-3.0.txt).

## Copyright

Copyright (c) 2024 [dmetzler1988](https://github.com/dmetzler1988)
