FROM golang:alpine AS builder

ENV GIT_REPOSITORY https://github.com/wavefrontHQ/telegraf.git
ENV DEP_LOCATION https://raw.githubusercontent.com/golang/dep/master/install.sh
ENV BUILD_LOCATION src/telegraf/vendor/github.com/influxdata

RUN apk add curl git make

RUN curl $DEP_LOCATION | sh && \
    mkdir -p $GOPATH/$BUILD_LOCATION && \
    cd $GOPATH/$BUILD_LOCATION && \
    git clone $GIT_REPOSITORY -b feature-vsan && \
    cd telegraf && \
    make deps && \
    make static && \
    chmod +x telegraf
RUN cp $GOPATH/$BUILD_LOCATION/telegraf/telegraf /usr/bin/

FROM gcr.io/distroless/static
ENV DEP_LOCATION https://raw.githubusercontent.com/golang/dep/master/install.sh
ENV BUILD_LOCATION src/telegraf/vendor/github.com/influxdata
COPY --from=builder /usr/bin/telegraf /go/bin/telegraf

ENTRYPOINT ["/go/bin/telegraf"]