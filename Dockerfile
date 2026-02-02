FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openjdk-17-jdk \
    apksigner \
    sdkmanager \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/usr/lib/android-sdk

RUN yes | sdkmanager --licenses

COPY build.sh /build/build.sh

WORKDIR /build/cryptomator-android/

ENTRYPOINT ["/bin/bash", "/build/build.sh"]
