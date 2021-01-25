FROM vcxpz/baseimage-alpine

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
	gcc \
	g++ \
	jq \
	make \
	python3-dev \
	unzip && \
   echo "**** install runtime packages ****" && \
   apk add --no-cache \
	bluez-deprecated \
	curl \
	eudev-libs \
	ffmpeg \
	libcap \
	libjpeg-turbo \
	libstdc++ \
	libxslt \
	tiff \
	openssl \
	py3-pip \
	python3 && \
   echo "**** install homeassistant ****" && \
   mkdir -p \
	/tmp/core && \
   curl -o \
	/tmp/core.tar.gz -L \
	"https://github.com/home-assistant/core/archive/${VERSION}.tar.gz" && \
   tar xf \
	/tmp/core.tar.gz -C \
	/tmp/core --strip-components=1 && \
   awk '/# Home Assistant core/,/^$/' /tmp/core/requirements_all.txt > /tmp/constraints_hass.txt && \
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
	-c /tmp/constraints_hass.txt \
	-r requirements_test_all.txt && \
   echo "**** install dependencies for hacs.xyz ****" && \
   if [ -z ${HACS_RELEASE+x} ]; then \
	HACS_RELEASE=$(curl -sX GET "https://api.github.com/repos/hacs/integration/releases/latest" \
		| awk '/tag_name/{print $4;exit}' FS='[""]'); \
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
