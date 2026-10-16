FROM mcr.microsoft.com/devcontainers/base:noble

RUN apt update

RUN apt-get install -y --no-install-recommends systemd systemd-sysv dbus sudo \
    # && rm -rf /var/lib/apt/lists/* \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && visudo -cf /etc/sudoers.d/vscode \
    && systemctl mask \
        systemd-udevd.service systemd-udev-trigger.service \
        systemd-remount-fs.service getty.target \
        sys-kernel-debug.mount sys-kernel-tracing.mount

STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/sbin/init"]
