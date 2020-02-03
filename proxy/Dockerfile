# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run

FROM nginx:1.17.6

MAINTAINER Vincent Lefoulon <vincent.lefoulon@laetis.fr>

# HTTPS AUTO Let's encrypt certificates
RUN apt-get update \
	  && apt-get install -y certbot \
    && rm -rf /var/lib/apt/lists/*

ADD *.template /etc/nginx/conf.d/ 

# TIMEZONE
RUN rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
