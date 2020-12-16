# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run

FROM debian:stretch

MAINTAINER Vincent Lefoulon <vincent.lefoulon@laetis.fr>

ARG authentic_version
ARG combo_version
ARG fargo_version
ARG hobo_version
ARG hobo_agent_version
ARG passerelle_version
ARG wcs_version
ARG wcs_au_quotidien_version
ARG publik_base_theme_version
ARG publik_common_version

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
    && echo "deb http://httpredir.debian.org/debian stretch main" >> /etc/apt/sources.list \
    && echo "deb http://ftp.fr.debian.org/debian stretch-updates main" >> /etc/apt/sources.list \
    && echo "deb http://ftp.fr.debian.org/debian stretch-backports main" >> /etc/apt/sources.list \
    && echo "deb http://deb.entrouvert.org/ stretch main" > /etc/apt/sources.list.d/entrouvert-tmp.list \
    && wget -q -O- https://deb.entrouvert.org/entrouvert.gpg | apt-key add - \
    && apt-get update \
    && apt-get install -y entrouvert-repository \
    && rm /etc/apt/sources.list.d/entrouvert-tmp.list \
    && apt-get update \
    && apt-get install -y vim gettext nginx-full quilt gnupg git \
    && apt-get install -y zip ca-certificates-entrouvert libreoffice sassc \
    && apt-get install -y publik-base-theme=$publik_base_theme_version \
      publik-common=$publik_common_version \
      authentic2-multitenant=$authentic_version \
      combo=$combo_version \
      fargo=$fargo_version \
      hobo=$hobo_version \
      hobo-agent=$hobo_agent_version \
      passerelle=$passerelle_version \
      wcs=$wcs_version \
      wcs-au-quotidien=$wcs_au_quotidien_version \
    && rm -rf /var/lib/apt/lists/*

# THEMES
# We clone the repo to be able to build custom themes without having to pull
# the repo every time
RUN cd /usr/share/publik \
    && git clone https://git.entrouvert.org/publik-base-theme.git

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
