# alpine-minimal

Minimal base image on [Alpine Linux](https://hub.docker.com/_/alpine), rebuilt daily so Alpine's security
fixes arrive without anyone touching the repository.

- Alpine with all packages upgraded at build time, plus `ca-certificates` and `tzdata`
- Runs as the non-root user `app`, UID/GID `10001`
- Ships `/usr/local/sbin/finalize` to remove the package manager in images built on top of it
- Built for `linux/amd64` and `linux/arm64`, signed with cosign, with an SBOM and a vulnerability report attached

## Tags

| Tag | Meaning |
|---|---|
| `3.24.4` | This Alpine version, moves to every new build of it |
| `3.24` | Latest build of Alpine 3.24 |
| `3` | Latest build of Alpine 3 |
| `latest` | Newest release, same as `3` today |
| `3.24.4-1.0.1` | One specific release; never moves. Use it to roll back |

The moving tags work like `latest`: a new build re-points them. Pin them by digest and let your update bot
(Dependabot or Renovate) bump the digest:

```Dockerfile
FROM ghcr.io/dmetzler1988-org/alpine-minimal:3.24@sha256:<digest>
```

The old tags `0.0.1`, `0.0.2`, `0.0.3` and `0.0` were a proof of concept on Alpine 3.20, which is out of
support. They are not updated anymore. Until release 1.0.1, `latest` still pointed to `0.0.3`.

## Usage

Install what your image needs as root, run `finalize` last, then switch back to the non-root user:

```Dockerfile
FROM ghcr.io/dmetzler1988-org/alpine-minimal:3.24@sha256:<digest>

USER root
RUN apk add --no-cache libpq \
 && /usr/local/sbin/finalize
USER 10001

COPY --chown=10001:10001 app/ /app/
```

`finalize` removes `apk`, its repositories, keys and caches, and strips setuid/setgid bits. It keeps apk's
package database, so vulnerability scanners still see every installed package. It refuses to run as non-root
or without the package database.

## Releases

Every release has a SemVer version and a [GitHub Release](../../releases) listing the Alpine version and the
image digest. `versions.lock` records the last release; the pipeline writes it, never edit it by hand.

| Change since the last release | Level |
|---|---|
| New Alpine minor version (3.24 to 3.25) | minor. Library versions change, rebuild your own native extensions |
| New Alpine patch version, new upstream image digest, updated packages, or changes to `Dockerfile` / `rootfs/` | patch |
| Nothing | no release |

A manual run of the CI workflow can raise the level to `minor` or `major`.

The build, test, release and signing steps live in
[dmetzler1988-org/container-workflows](https://github.com/dmetzler1988-org/container-workflows).

## Local build and tests

```shell
docker build -t alpine-minimal:local .
IMAGE=alpine-minimal:local tests/run.sh
```

## License

This application is free software: you can redistribute it and/or modify it under the terms of
the [GNU Affero General Public License v3](https://www.gnu.org/licenses/agpl-3.0.txt).

## Copyright

Copyright (c) 2024 [dmetzler1988](https://github.com/dmetzler1988)
