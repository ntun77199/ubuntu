FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/vevc/ubuntu"

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=ubuntu!23 \
    SECRET_KEY=d2026f34965625b4c22f73e4283b0273d9c5cfbf080dee0523fa2512f0081afb

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools cron unzip iputils-ping telnet git iproute2 --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    \
    # Download Playit agent
    curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.15/playit-linux_amd64 -o /usr/local/bin/playit-agent && \
    chmod +x /usr/local/bin/playit-agent

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

# Start SSHD in foreground AND Playit agent in background
CMD /usr/local/bin/playit-agent --secret $SECRET_KEY & /usr/sbin/sshd -D
