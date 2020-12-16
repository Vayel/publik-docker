FROM debian:buster

RUN apt-get update \
    && apt-get install -y zip

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
