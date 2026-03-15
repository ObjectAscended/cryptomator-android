FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openjdk-17-jdk \
    sdkmanager \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/usr/lib/android-sdk

RUN yes | sdkmanager --licenses

COPY build.sh /build/build.sh

WORKDIR /build/cryptomator-android/

ENTRYPOINT ["/bin/bash", "/build/build.sh"]


FROM ubuntu:26.04 AS signer

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apksigner \
    && rm -rf /var/lib/apt/lists/*

COPY sign.sh /build/sign.sh

WORKDIR /build/artifacts/

ENTRYPOINT ["/bin/bash", "/build/sign.sh"]