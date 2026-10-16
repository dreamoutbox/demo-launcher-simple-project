FROM mcr.microsoft.com/devcontainers/universal:2
# USER root
# RUN apt-get update \
# 	&& apt-get install -y --no-install-recommends systemd systemd-sysv dbus \
# 	&& rm -rf /var/lib/apt/lists/* \
# 	# mask units that fail or hang in containers
# 	&& systemctl mask \
# 		systemd-udevd.service systemd-udev-trigger.service \
# 		systemd-remount-fs.service getty.target \
# 		sys-kernel-debug.mount sys-kernel-tracing.mount
# STOPSIGNAL SIGRTMIN+3
# ENTRYPOINT ["/sbin/init"]
