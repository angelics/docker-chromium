#
# chromium Dockerfile
#
# https://github.com/jlesage/docker-chromium
#

# Build the PID namespace check tool.
FROM alpine:3.22 AS pid-namespace-check
WORKDIR /tmp
COPY src/check_pid_namespace/check_pid_namespace.c .
RUN apk --no-cache add build-base linux-headers
RUN gcc -static -Wall -Werror -o check_pid_namespace check_pid_namespace.c
RUN strip check_pid_namespace
RUN chmod u+s check_pid_namespace

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.23-v4.11.3

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG CHROMIUM_VERSION=147.0.7727.116-r0

# Define software download URLs.

# Define working directory.
WORKDIR /tmp

# Install Chromium.
RUN \
    add-pkg \
        chromium=${CHROMIUM_VERSION}

# Install extra packages.
RUN \
    add-pkg \
        adwaita-icon-theme \
        mesa-gl \
        mesa-dri-gallium \
        mesa-va-gallium \
		python3 \
		py3-pip \
		chromium-chromedriver=${CHROMIUM_VERSION}

# Install Python dependencies.
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir selenium>=4.15.0 setuptools>=69.0.0 python-dotenv>=1.0.0 websockets>=12.0 flask>=3.0.0 requests>=2.33.0 matplotlib>=3.10.0
ENV PATH="/opt/venv/bin:$PATH"

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/chromium-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=pid-namespace-check /tmp/check_pid_namespace /usr/bin/

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "Chromium" && \
    set-cont-env APP_VERSION "$CHROMIUM_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    CHROMIUM_APP_URL=

# Expose ports.
EXPOSE 5801

# Health check — catches hung processes (e.g. deadlocked Selenium lock).
# Works in both automation and browser-only modes: checks Flask /api/status
# first, falls back to verifying the Chromium process is alive.
# Script is installed via the COPY rootfs/ / below.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD /etc/services.d/app/healthcheck.sh

# Metadata.
LABEL \
      org.label-schema.name="chromium" \
      org.label-schema.description="Docker container for Chromium" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-chromium" \
      org.label-schema.schema-version="1.0"
