FROM golang:1.15-alpine
RUN apk add --update --no-cache bash \
                                build-base \
                                git \
                                python3 \
                                protobuf \
                                protobuf-dev \
                                wget \
                                procps

RUN wget https://github.com/cortesi/modd/releases/download/v0.8/modd-0.8-linux64.tgz && \
        tar xvf modd-0.8-linux64.tgz && \
        mv modd-0.8-linux64/modd /usr/bin/modd && \
        rm modd-0.8-linux64.tgz

ENV GOPROXY=https://proxy.golang.org

WORKDIR /app

COPY go/go.mod .
COPY go/go.sum .
COPY go/modd.conf .
RUN go mod download

COPY ops/wait-for-it.sh ./wait-for-it.sh

CMD ["./wait-for-it.sh", "postgres:5432", "--", "modd"]