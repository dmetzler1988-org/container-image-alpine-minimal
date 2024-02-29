FROM alpine:3.19.1

LABEL maintainer="dmetzler1988"
LABEL version="1.0"
LABEL description="Basic container image based on alpine linux."

RUN apk --no-cache update && apk --no-cache upgrade
