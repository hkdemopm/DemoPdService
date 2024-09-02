# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-DemoPdService"
LABEL REPO="https://github.com/lacion/DemoPdService"

ENV PROJPATH=/go/src/github.com/lacion/DemoPdService

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/DemoPdService
WORKDIR /go/src/github.com/lacion/DemoPdService

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/DemoPdService"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/DemoPdService/bin

WORKDIR /opt/DemoPdService/bin

COPY --from=build-stage /go/src/github.com/lacion/DemoPdService/bin/DemoPdService /opt/DemoPdService/bin/
RUN chmod +x /opt/DemoPdService/bin/DemoPdService

# Create appuser
RUN adduser -D -g '' DemoPdService
USER DemoPdService

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/DemoPdService/bin/DemoPdService"]
