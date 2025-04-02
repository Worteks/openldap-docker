# Base Image
FROM debian:stable-slim
LABEL org.opencontainers.image.authors="Worteks" \
      name="openldap-ltb"

# Install required binaries
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt upgrade --no-install-recommends -y && \
    apt install --no-install-recommends -y curl && \
    apt install --no-install-recommends -y gpg && \
    apt install --no-install-recommends -y ca-certificates && \
    apt install --no-install-recommends -y wget

# Openldap-ltb GPG and Repostiory
RUN curl https://ltb-project.org/documentation/_static/RPM-GPG-KEY-LTB-project | gpg --dearmor > /usr/share/keyrings/ltb-project-openldap-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ltb-project-openldap-archive-keyring.gpg] https://ltb-project.org/debian/openldap26/bookworm bookworm main" > /etc/apt/sources.list.d/ltb-project.list
RUN apt update

# Installing Openldap-ltb
RUN apt install --no-install-recommends -y openldap-ltb && \
    apt install --no-install-recommends -y openldap-ltb-contrib-overlays && \
    apt install --no-install-recommends -y openldap-ltb-mdb-utils && \
    apt install --no-install-recommends -y openldap-ltb-explockout && \
    apt install --no-install-recommends -y ldapvi

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
WORKDIR /usr/local/openldap

# Clean up
RUN echo "# Clean up image" && \
    rm -rf /tmp/* && \
    apt clean && \
    apt autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Mount locations
VOLUME /usr/local/openldap/etc/openldap/slapd.d
VOLUME /usr/local/openldap/var/openldap-data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
