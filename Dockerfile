FROM debian:stretch

# Install deps
RUN apt-get update; apt-get install -q -y openssl\
        ca-certificates postgresql-client wget cron\
        rsync procps

# Install rclone
#RUN wget https://downloads.rclone.org/v1.40/rclone-v1.40-linux-amd64.zip
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb
RUN dpkg -i rclone-current-linux-amd64.deb

# Add scripts
ADD rclone.conf /root/rclone.conf
ADD *.sh /root/
RUN chmod +x /root/*.sh

CMD ["/root/run_restore.sh"]
