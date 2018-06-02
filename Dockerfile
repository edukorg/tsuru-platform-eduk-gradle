FROM tsuru/base-platform
ADD https://github.com/edukorg/tsuru-platform-eduk-gradle/raw/master/deploy /var/lib/tsuru/eduk-gradle/deploy
ADD https://github.com/edukorg/tsuru-platform-eduk-gradle/raw/master/sdk-source.sh /etc/profile.d/sdk-source.sh
RUN set -ex; \
    sudo apt-get update \
    && sudo apt-get install -y zip unzip \
    && curl -s "https://get.sdkman.io" | bash \
    && sudo chown -R ubuntu: /home/ubuntu/ \
    && sudo apt-get autoremove -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && cd /bin && sudo rm -f sh && sudo ln -s /bin/bash /bin/sh \
    && sudo chmod 777 /var/lib/tsuru/eduk-gradle/deploy \
    && sudo cp -p /var/lib/tsuru/eduk-gradle/deploy /var/lib/tsuru \
    && sudo chmod 777 /etc/profile.d/sdk-source.sh
ENV ENV=/etc/profile.d/sdk-source.sh
