# Base Image
FROM debian:stable-slim
LABEL org.opencontainers.image.authors="Abhishek Pai" \
      name="openldap-ltb"

# Install required binaries
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl && \
    apt install -y gpg && \
    apt install -y wget

# Openldap-ltb GPG and Repostiory
RUN curl https://ltb-project.org/documentation/_static/RPM-GPG-KEY-LTB-project | gpg --dearmor > /usr/share/keyrings/ltb-project-openldap-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ltb-project-openldap-archive-keyring.gpg] https://ltb-project.org/debian/openldap26/bookworm bookworm main" > /etc/apt/sources.list.d/ltb-project.list
RUN apt update

# Installing Openldap-ltb
RUN apt install -y openldap-ltb && \
    apt install -y openldap-ltb-contrib-overlays && \
    apt install -y openldap-ltb-mdb-utils && \
    apt install -y ldapvi

# working dir
WORKDIR /tmp

# download tar && extract
RUN wget https://ltb-project.org/archives/slapd-cli-3.5.tar.gz
RUN tar xvf slapd-cli-3.5.tar.gz

# working directory
WORKDIR slapd-cli-3.5
RUN mkdir -p /usr/local/openldap/etc/openldap

# copy configurations and binaries
RUN cp slapd-cli /usr/local/openldap/sbin
RUN cp slapd-cli.conf /usr/local/openldap/etc/openldap/
RUN cp *-template* /usr/local/openldap/etc/openldap/
RUN cp lload.conf /usr/local/openldap/etc/openldap/
RUN cp slapd-cli-prompt /etc/bash_completion.d/
RUN cp slapd-ltb.service /lib/systemd/system/
RUN cp lload-ltb.service /lib/systemd/system/

# permissions
RUN chmod +x /usr/local/openldap/sbin/slapd-cli
RUN chmod 600 /usr/local/openldap/etc/openldap/slapd-cli.conf
RUN chmod 600 /usr/local/openldap/etc/openldap/lload.conf

# add to $PATH
ENV PATH=/usr/local/openldap/bin:/usr/local/openldap/sbin:$PATH
ENV SLAPD_CONF_DIR=/usr/local/openldap/etc/openldap/slapd.d/

# add slapd customisation
RUN sed "s/SLAPD_CONF_DIR=\"\"/SLAPD_CONF_DIR=\"\$SLAPD_PATH\/etc\/openldap\/slapd.d\"/g" -i /usr/local/openldap/etc/openldap/slapd-cli.conf

# Set working directory
WORKDIR /openldap

# Clean up
RUN echo "# Clean up image" && \
    rm -rf /tmp/* && \
    apt clean && \
    apt autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
