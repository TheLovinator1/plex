# Plex

Plex is a media server that can stream movies, TV shows, music, and more.

## Docker

This Docker image is using [Ubuntu 22.04](https://hub.docker.com/_/ubuntu/) as base image. Plex runs as a user with the
id `1000`.

## Ports

| Port            | Description                                  | Required |
| --------------- | -------------------------------------------- | -------- |
| 32400/tcp       | Access to the Plex Media Server              | Yes      |
| 1900/udp        | Plex DLNA Server                             | No       |
| 5353/udp        | Older Bonjour/Avahi network discovery        | No       |
| 8324/tcp        | Controlling Plex for Roku via Plex Companion | No       |
| 32410/udp       | Current GDM network discovery                | No       |
| 32412-32414/udp | Current GDM network discovery                | No       |
| 32469/tcp       | Plex DLNA Server                             | No       |

Warning!: For security, we very strongly recommend that you do not allow any of these "non-required" ports through
the firewall or to be forwarded in your router, in cases specifically where your Plex Media Server is running
on a machine with a public/WAN IP address. This includes those hosted in a data center as well as machines on
a "local network" that have been put into the "DMZ" (the "de-militarized zone") of the network router.

## Images

![Screenshot 1](img/plex-screenshot1.jpg)

## Need help?

- Email: [tlovinator@gmail.com](mailto:tlovinator@gmail.com)
- Discord: TheLovinator#9276
- Steam: [TheLovinator](https://steamcommunity.com/id/TheLovinator/)
- Send an issue: [plex/issues](https://github.com/feed-the-fish/plex/issues)
