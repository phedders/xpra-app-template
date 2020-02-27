# The image is based on the Debian Wheezy distribution.
FROM debian:bullseye-slim
EXPOSE 22

# NB eatmydata is horrible. But it does make builds faster and if the fs fails - you got bigger problems. Fix then rebuild.

# install pre-dependancies
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt install -y gnupg2 curl eatmydata
run sed -i "s/main$/main non-free contrib/" /etc/apt/sources.list
RUN echo "deb https://xpra.org/ bullseye main" > /etc/apt/sources.list.d/xpra.list
RUN curl https://xpra.org/gpg.asc | apt-key add -

# install dependencies
RUN DEBIAN_FRONTEND=noninteractive eatmydata apt-get update -y && apt-get install -y
RUN eatmydata apt-get install --no-install-recommends -y -q locales-all bash rxvt-unicode openssh-server xauth \
        x11-apps x11-utils xserver-xephyr tinywm xpra xpra-html5 python3-paramiko python3-pydbus

# install other bits I tend to need... these are not all required for xpra.
RUN eatmydata apt install -y liblz4-1 python3-netifaces python3-pil xinput libasound2 libbsd0 libc6 libfreetype6 libgcc1 \
        libgcc-8-dev libgcc-9-dev libpng16-16 libstdc++6 libx11-6 libxau6 libxcb1 libxdmcp6 libxext6 zlib1g x11-utils

# tidy up
RUN eatmydata apt-get clean && \
    eatmydata apt-get autoclean && \
    eatmydata apt-get autoremove
RUN eatmydata rm -rf /usr/share/man/?? /usr/share/man/??_*
RUN eatmydata rm -rf /var/lib/apt/lists/* /var/cache/apt/* /root/.npm /tmp/npm*

# now setup some ssh bits - you could just use tcp connections - I like to have both
RUN mkdir /var/run/sshd 
RUN adduser --disabled-password --gecos "XPRA User" --uid 9991 user
RUN mkdir -p /home/user/.ssh/ /run/user/9991/xpra && chown user:user /run/user/9991/xpra

RUN chmod +rwx /run
VOLUME /home/user
ENV DISPLAY=:100
ADD xpra-display /tmp/xpra-display
RUN echo "$(cat /tmp/xpra-display)\n$(cat /etc/bash.bashrc)" > /etc/bash.bashrc 
RUN echo AddressFamily inet >> /etc/ssh/sshd_config

ADD entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
