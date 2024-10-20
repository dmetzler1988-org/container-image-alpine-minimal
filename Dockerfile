FROM alpine:3.20.3

LABEL maintainer="dmetzler1988"
LABEL version="1.0"
LABEL description="Basic container image based on alpine linux."

RUN apk --no-cache update && apk --no-cache upgrade
