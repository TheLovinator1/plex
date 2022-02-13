FROM ghcr.io/thelovinator1/base:master

# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.authors="Joakim Hellsén <tlovinator@gmail.com>" \ 
org.opencontainers.image.url="https://github.com/TheLovinator1/docker-arch-plex" \
org.opencontainers.image.documentation="https://github.com/TheLovinator1/docker-arch-plex" \
org.opencontainers.image.source="https://github.com/TheLovinator1/docker-arch-plex" \
org.opencontainers.image.vendor="Joakim Hellsén" \
org.opencontainers.image.license="GPL-3.0+" \
org.opencontainers.image.title="Plex Media Server" \
org.opencontainers.image.description="The back-end media server component of Plex" \
org.opencontainers.image.base.name="docker.io/library/archlinux"

# https://forums.plex.tv/t/plex-media-server/30447.rss
ARG pkgver="1.25.4.5487"
ARG _pkgsum=648a8f9f9

# Use a temporary directory for the installation, we will remove it later.
WORKDIR /tmp/plex

# Download and extract the latest version of Plex Media Server
# TODO: We should check checksums here.
ADD "https://downloads.plex.tv/plex-media-server-new/${pkgver}-${_pkgsum}/redhat/plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" "/tmp/plex/plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm"
RUN bsdtar -xf "plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" -C /tmp/plex && \
rm "plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" && \
cp -dr --no-preserve='ownership' "usr/lib/plexmediaserver" "/usr/lib/" && \
install -d -o lovinator -g lovinator -m 775 /usr/lib/plexmediaserver /var/lib/plex /tmp/plex /media && \
chown -R lovinator:lovinator /usr/lib/plexmediaserver /var/lib/plex && \
rm -rf "/tmp/plex" && \
rm -rf /var/cache/*

# Change to the directory where the Plex Media Server binary is located.
WORKDIR /usr/lib/plexmediaserver

# 32400/tcp         Access to the Plex Media Server                 (Requred)
# 1900/udp          Plex DLNA Server                                (Optional)
# 5353/udp          Older Bonjour/Avahi network discovery           (Optional)
# 8324/tcp          Controlling Plex for Roku via Plex Companion    (Optional)
# 32410/udp         Current GDM network discovery                   (Optional)
# 32412-32414/udp   Current GDM network discovery                   (Optional)
# 32469/tcp         Plex DLNA Server                                (Optional)
#
# Warning!: For security, we very strongly recommend that you do not allow any of these “optional” ports through
# the firewall or to be forwarded in your router, in cases specifically where your Plex Media Server is running
# on a machine with a public/WAN IP address. This includes those hosted in a data center as well as machines on
# a “local network” that have been put into the “DMZ” (the “de-militarized zone”) of the network router.
EXPOSE 32400/tcp 1900/udp 5353/udp 8324/tcp 32410/udp 32412-32414/udp 32469/tcp

# /media can be read only to be more secure.
VOLUME ["/media", "/var/lib/plex"]

# Don't run as root.
USER lovinator

# Taken from https://aur.archlinux.org/cgit/aur.git/tree/plexmediaserver.conf.d?h=plex-media-server

# Where the binaries and libraries are located.
ENV LD_LIBRARY_PATH=/usr/lib/plexmediaserver/lib
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver

# Where Plex will store its data.
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex

# The number of plugins that can run at the same time.
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6

# Where we will store transcodes
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV TMPDIR=/tmp

# If Plex Media Server is shut down abruptly, it can leave behind a PID file and if it exists, Plex can't start.
# This script will remove the PID file if it exists and then start Plex.
ADD --chown=lovinator:lovinator start.sh /start.sh
CMD ["/start.sh"]
