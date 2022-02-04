FROM archlinux

ARG pkgver="1.25.4.5487"
ARG _pkgsum=648a8f9f9

# Add mirrors for Sweden. You can add your own mirrors to the mirrorlist file. Should probably use reflector.
ADD mirrorlist /etc/pacman.d/mirrorlist

# NOTE: For Security Reasons, archlinux image strips the pacman lsign key.
# This is because the same key would be spread to all containers of the same
# image, allowing for malicious actors to inject packages (via, for example,
# a man-in-the-middle).
RUN gpg --refresh-keys && pacman-key --init && pacman-key --populate archlinux

# Set locale. Needed for some programs.
# https://wiki.archlinux.org/title/locale
RUN echo "en_US.UTF-8 UTF-8" >"/etc/locale.gen" && locale-gen && echo "LANG=en_US.UTF-8" >"/etc/locale.conf"

# Create a new user with id 1000 and name "plex".
# https://linux.die.net/man/8/useradd
# https://linux.die.net/man/8/groupadd
RUN groupadd --gid 1000 --system plex && \
useradd --system --uid 1000 --gid 1000 plex && \
install -d -o plex -g plex -m 775 /usr/lib/plexmediaserver /var/lib/plex /tmp/plex /media

# Update the system and install depends
RUN pacman -Syu --noconfirm

WORKDIR /tmp/plex

ADD "https://downloads.plex.tv/plex-media-server-new/${pkgver}-${_pkgsum}/redhat/plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" "/tmp/plex/plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm"
RUN bsdtar -xf "plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" -C /tmp/plex && \
rm "plexmediaserver-${pkgver}-${_pkgsum}.x86_64.rpm" && \
cp -dr --no-preserve='ownership' "usr/lib/plexmediaserver" "/usr/lib/" && \
rm -rf "/tmp/plex" && \
chown -R plex:plex /usr/lib/plexmediaserver /var/lib/plex && \
rm -rf /var/cache/*

WORKDIR /usr/lib/plexmediaserver

# 32400             Access to the Plex Media Server                 (Requred)
# 1900/udp          Plex DLNA Server                                (Optional)
# 5353/udp          Older Bonjour/Avahi network discovery           (Optional)
# 8324              Controlling Plex for Roku via Plex Companion    (Optional)
# 32410/udp         Current GDM network discovery                   (Optional)
# 32412-32414/udp   Current GDM network discovery                   (Optional)
# 32469             Plex DLNA Server                                (Optional)
#
# Warning!: For security, we very strongly recommend that you do not allow any of these “optional” ports through
# the firewall or to be forwarded in your router, in cases specifically where your Plex Media Server is running
# on a machine with a public/WAN IP address. This includes those hosted in a data center as well as machines on
# a “local network” that have been put into the “DMZ” (the “de-militarized zone”) of the network router.
#

EXPOSE 32400
EXPOSE 1900/udp
EXPOSE 5353/udp
EXPOSE 8324
EXPOSE 32410/udp
EXPOSE 32412-32414/udp
EXPOSE 32469

VOLUME ["/media", "/var/lib/plex"]

USER plex

ENV LD_LIBRARY_PATH=/usr/lib/plexmediaserver/lib
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV TMPDIR=/tmp

ADD --chown=plex:plex start.sh /start.sh

CMD ["/start.sh"]
