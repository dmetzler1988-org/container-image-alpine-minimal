# syntax=docker/dockerfile:1

# No digest here on purpose: Dependabot can then propose the next Alpine release. CI pins the digest at build
# time with --build-context and records it in versions.lock (see DECISIONS.md, "FROM digest exception").
FROM alpine:3.24

# Set by CI (full version and digest). Local builds keep "unknown"; tests skip the label check then.
ARG ALPINE_IMAGE=unknown
ARG ALPINE_DIGEST=unknown
ARG APP_UID=10001
ARG APP_GID=10001

LABEL org.opencontainers.image.title="alpine-minimal" \
      org.opencontainers.image.description="Minimal Alpine Linux base image, runs as non-root user 10001." \
      org.opencontainers.image.source="https://github.com/dmetzler1988-org/container-image-alpine-minimal" \
      org.opencontainers.image.base.name="${ALPINE_IMAGE}" \
      org.opencontainers.image.base.digest="${ALPINE_DIGEST}"

RUN apk upgrade --no-cache \
 && apk add --no-cache ca-certificates tzdata \
 && addgroup -g "${APP_GID}" app \
 && adduser -D -H -u "${APP_UID}" -G app -s /sbin/nologin app

COPY --chmod=0755 rootfs/usr/local/sbin/finalize /usr/local/sbin/finalize

USER ${APP_UID}
