# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run

FROM debian:buster

MAINTAINER Vincent Lefoulon <vincent.lefoulon@laetis.fr>

# TIMEZONE
RUN echo "Europe/Paris" > /etc/timezone \
    && apt-get update \
    && apt-get install -y locales \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-reconfigure -f noninteractive tzdata \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="fr_FR.UTF-8"' > /etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

# DEBIAN PACKAGES
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && echo "deb http://httpredir.debian.org/debian buster main" >> /etc/apt/sources.list \
    && echo "deb http://ftp.fr.debian.org/debian buster-updates main" >> /etc/apt/sources.list \
    && echo "deb http://ftp.fr.debian.org/debian buster-backports main" >> /etc/apt/sources.list \
    && echo "deb http://deb.entrouvert.org/ buster main" > /etc/apt/sources.list.d/entrouvert-tmp.list \
    && wget -q -O- https://deb.entrouvert.org/entrouvert.gpg | apt-key add - \
    && apt-get update \
    && apt-get install -y entrouvert-repository entrouvert-repository-hotfix \
    && rm /etc/apt/sources.list.d/entrouvert-tmp.list \
    && apt-get update \
    && apt-get install -y vim gettext nginx-full quilt gnupg git \
    && apt-get install -y zip ca-certificates-entrouvert libreoffice sassc \
    && apt-get install -y publik-common \
      authentic2-multitenant \
      combo \
      fargo \
      hobo \
      hobo-agent \
      passerelle \
      wcs \
      wcs-au-quotidien \
    && rm -rf /var/lib/apt/lists/*

# NGINX
COPY nginx/*.template /etc/nginx/conf.d/ 
COPY nginx/global.conf /etc/nginx/conf.d/ 

# SCRIPTS
RUN mkdir /root/bin
COPY bin/* /root/bin/
RUN chmod +x /root/bin/* && mv /root/bin/* /usr/local/bin && rm -r /root/bin
COPY common.py.template /tmp/

# AUTHENTIC
RUN mkdir -p /etc/authentic2-multitenant/settings.d/ 
COPY authentic.settings.py /etc/authentic2-multitenant/settings.d/custom.py
COPY secret /etc/authentic2-multitenant/secret
RUN chmod 755 /etc/authentic2-multitenant/secret

# COMBO
RUN mkdir -p /etc/combo/settings.d/ 
COPY combo.settings.py /etc/combo/settings.d/custom.py
COPY secret /etc/combo
RUN chmod 755 /etc/combo/secret
RUN usermod combo -s /bin/bash

# FARGO
RUN mkdir -p /etc/fargo/settings.d/ 
COPY fargo.settings.py /etc/fargo/settings.d/custom.py
COPY secret /etc/fargo
RUN chmod 755 /etc/fargo/secret
RUN usermod fargo -s /bin/bash

# HOBO
COPY deploy/* /tmp/
RUN mkdir -p /etc/hobo/settings.d/ /etc/hobo-agent/settings.d
COPY hobo.settings.py /etc/hobo/settings.d/custom.py
COPY hobo-agent.settings.py /etc/hobo-agent/settings.d/custom.py
RUN usermod hobo -s /bin/bash

# PASSERELLE
RUN mkdir -p /etc/passerelle/settings.d/ 
COPY passerelle.settings.py /etc/passerelle/settings.d/custom.py
RUN usermod passerelle -s /bin/bash

# WCS
RUN mkdir -p /var/lib/wcs/skeletons
RUN mkdir -p /etc/wcs/settings.d/
COPY wcs.settings.py /etc/wcs/settings.d/custom.py
RUN usermod wcs -s /bin/bash

COPY commit-build.log /tmp/commit-build.log

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 8080
