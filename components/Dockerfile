FROM debian:stretch

MAINTAINER Vincent Lefoulon <vincent.lefoulon@laetis.fr>

# TIMEZONE
RUN echo "Europe/Paris" > /etc/timezone \
    && apt-get update \
    && apt-get install -y locales \
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
    && apt-get install -y zip ca-certificates-entrouvert libreoffice publik-base-theme publik-common \
    && apt-get install -y combo passerelle fargo hobo hobo-agent authentic2-multitenant wcs wcs-au-quotidien

# NGINX
COPY nginx/*.template /etc/nginx/conf.d/ 

# SCRIPTS
COPY tools/* /root/
RUN chmod +x /root/*.sh
RUN mkdir /root/bin
COPY bin/* /root/bin/
RUN chmod +x /root/bin/* && mv /root/bin/* /usr/local/bin && rm -r /root/bin
COPY settings.template /home/

# AUTHENTIC
COPY authentic.config.py /etc/authentic2-multitenant/config.py
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
COPY tmp/* /tmp/
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

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 8080
