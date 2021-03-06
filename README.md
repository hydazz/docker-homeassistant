## docker-homeassistant

[![docker hub](https://img.shields.io/badge/docker_hub-link-blue?style=for-the-badge&logo=docker)](https://hub.docker.com/r/vcxpz/homeassistant) ![docker image size](https://img.shields.io/docker/image-size/vcxpz/homeassistant?style=for-the-badge&logo=docker) [![auto build](https://img.shields.io/badge/docker_builds-automated-blue?style=for-the-badge&logo=docker?color=d1aa67)](https://github.com/hydazz/docker-homeassistant/actions?query=workflow%3A"Auto+Builder+CI") [![codacy branch grade](https://img.shields.io/codacy/grade/e0be01bac4e84d9aa2f9f846c4ffc3a5/main?style=for-the-badge&logo=codacy)](https://app.codacy.com/gh/hydazz/docker-homeassistant)

**This is an unofficial image that has been modified for my own needs. If my needs match your needs, feel free to use this image at your own risk.**

Fork of [linuxserver/docker-homeassistant](https://github.com/linuxserver/docker-homeassistant/). (Equivalent to 2021.6.0-ls24)

[Home Assistant](https://www.home-assistant.io/) is open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts. Perfect to run on a Raspberry Pi or a local server.

## Usage

```bash
docker run -d \
  --name=homeassistant \
  --net=host \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Australia/Melbourne \
  -v <path to data>:/config \
  --device <path to device>:<path to device> \
  --restart unless-stopped \
  vcxpz/homeassistant
```

[![template](https://img.shields.io/badge/unraid_template-ff8c2f?style=for-the-badge&logo=docker?color=d1aa67)](https://github.com/hydazz/docker-templates/blob/main/hydaz/homeassistant.xml)

## New Environment Variables

| Name    | Description                                                                                              | Default Value |
| ------- | -------------------------------------------------------------------------------------------------------- | ------------- |
| `DEBUG` | set `true` to display errors in the Docker logs. When set to `false` the Docker log is completely muted. | `false`       |

**See other variables on the official [README](https://github.com/linuxserver/docker-homeassistant/)**

## Upgrading Home Assistant

To upgrade, all you have to do is pull the latest Docker image. We automatically check for Home Assistant updates daily. When a new version is released, we build and publish an image both as a version tag and on `:latest`.

## Fixing Appdata Permissions

If you ever accidentally screw up the permissions on the appdata folder, run `fix-perms` within the container. This will restore most of the files/folders with the correct permissions.
