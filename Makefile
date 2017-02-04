NAME =			torrents-9.6.0/0.13.6-
VERSION =		latest
VERSION_ALIASES =	1.3.0
TITLE =			Seedbox
DESCRIPTION =		rtorrent and ruTorrent (web interface)
SOURCE_URL =		https://github.com/scaleway-community/scaleway-torrents
SHELL_DOCKER_OPTS ?=	-p 80:80
DEFAULT_IMAGE_ARCH ?=	x86_64

IMAGE_VOLUME_SIZE =	100G
IMAGE_BOOTSCRIPT =	latest
IMAGE_NAME =		Torrents 1.3.0


## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
## Here you can add custom commands and overrides
