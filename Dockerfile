FROM alpine:3.9
MAINTAINER Timothy St. Clair "tstclair@heptio.com"  

WORKDIR /app
RUN apk update --no-cache && apk add ca-certificates
ADD eventrouter /app/
USER nobody:nobody

CMD ["/bin/sh", "-c", "/app/eventrouter -v 3 -logtostderr"]
