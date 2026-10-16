ps -p 1 -o comm=                 # systemd
systemctl is-system-running      # running or degraded (degraded is fine)
systemctl --failed
