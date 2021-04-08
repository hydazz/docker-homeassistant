FROM vcxpz/baseimage-alpine:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HACS_RELEASE
LABEL build_version="Home Assistant version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydaz"

# environment settings
ENV PIPFLAGS="--no-cache-dir --find-links https://wheels.home-assistant.io/alpine-3.12/amd64/" \
	PYTHONPATH="/pip-packages:$PYTHONPATH"

# copy local files
COPY root/ /

# https://github.com/home-assistant/core/pull/43771

# install packages
RUN \
	echo "**** install build packages ****" && \
	apk add --no-cache --virtual=build-dependencies \
		autoconf \
		ca-certificates \
		g++ \
		gcc \
		jpeg-dev \
		jq \
		libffi-dev \
		libgcc \
		libxml2-dev \
		libxslt-dev \
		make \
		musl-dev \
		openssl-dev \
		python3-dev \
		unzip \
		zlib-dev && \
	echo "**** install runtime packages ****" && \
	apk add --no-cache \
		bluez-deprecated \
		curl \
		eudev-libs \
		ffmpeg \
		iputils \
		libcap \
		libjpeg-turbo \
		libstdc++ \
		libxslt \
		openssl \
		postgresql-libs \
		py3-pip \
		python3 \
		tiff && \
	echo "**** install homeassistant ****" && \
	mkdir -p \
		/tmp/core && \
	if [ -z ${VERSION+x} ]; then \
		VERSION=$(curl -sX GET https://api.github.com/repos/home-assistant/core/releases/latest | \
			jq -r .tag_name); \
	fi && \
	curl -o \
		/tmp/core.tar.gz -L \
		"https://github.com/home-assistant/core/archive/${VERSION}.tar.gz" && \
	tar xf \
		/tmp/core.tar.gz -C \
		/tmp/core --strip-components=1 && \
	HASS_BASE=$(cat /tmp/core/build.json | \
		jq -r .build_from.amd64 | \
		cut -d: -f2) && \
	mkdir -p /pip-packages && \
	pip install --target /pip-packages --no-cache-dir --upgrade \
		distlib && \
	pip install --no-cache-dir --upgrade \
		pip==20.3 \
		wheel && \
	pip install ${PIPFLAGS} \
		homeassistant==${VERSION} && \
	cd /tmp/core && \
	pip install ${PIPFLAGS} \
		-r requirements_all.txt && \
	pip install ${PIPFLAGS} \
		-r https://raw.githubusercontent.com/home-assistant/docker/${HASS_BASE}/requirements.txt && \
	echo "**** install dependencies for hacs.xyz ****" && \
	if [ -z ${HACS_RELEASE+x} ]; then \
		HACS_RELEASE=$(curl -sL "https://api.github.com/repos/hacs/integration/releases/latest" | \
			awk '/tag_name/{print $4;exit}' FS='[""]'); \
	fi && \
	mkdir -p \
		/tmp/hacs-source && \
	curl -o \
		/tmp/hacs.tar.gz -L \
		"https://github.com/hacs/integration/archive/${HACS_RELEASE}.tar.gz" && \
	tar xf \
		/tmp/hacs.tar.gz -C \
		/tmp/hacs-source --strip-components=1 && \
	pip install ${PIPFLAGS} \
		-r /tmp/hacs-source/requirements.txt && \
	echo "**** cleanup ****" && \
	apk del --purge \
		build-dependencies && \
	rm -rf \
		/tmp/* \
		/root/.cache

# environment settings. used so pip packages installed by home assistant installs in /config
ENV HOME="/config"

# ports and volumes
EXPOSE 8123
VOLUME /config
