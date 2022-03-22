FROM golang:1.12 as build-env
# All these steps will be cached
# RUN apk add --no-cache ca-certificates
# RUN apk --no-cache add build-base git mercurial gcc librdkafka-dev pkgconf
RUN apt update && apt install ca-certificates libgnutls30 -y
RUN mkdir /app
WORKDIR /app

# <- COPY go.mod and go.sum files to the workspace
COPY go.mod .
COPY go.sum .

# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download
# COPY the source code as the last step
COPY . .

# Build the binary
RUN go build -tags musl -o /go/bin/eventrouter

# <- Second step to build minimal image
FROM alpine:latest 
# COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build-env /go/bin/eventrouter /go/bin/eventrouter
RUN apk add gcompat
EXPOSE 8080/tcp
CMD ["/go/bin/eventrouter", "-v", "5", "-logtostderr"]
