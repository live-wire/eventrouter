# Copyright 2017 Heptio Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:alpine as build-env
MAINTAINER Dhruv Batheja "dhruvb@spotify.com"
# All these steps will be cached
# RUN apk add --no-cache ca-certificates
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
EXPOSE 8080/tcp
CMD ["/bin/sh", "-c", "/go/bin/eventrouter -v 3 -logtostderr"]
