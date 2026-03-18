# Cryptomator Android Custom Build Environment

This repository contains scripts, patches, and automated workflows designed to build a custom, modified version of the official Cryptomator Android application. 

[![build cryptomator apk](https://github.com/ObjectAscended/cryptomator-android/actions/workflows/build.yml/badge.svg)](https://github.com/ObjectAscended/cryptomator-android/actions/workflows/build.yml)

## Features

* **Automated Containerized Builds:** Utilizes Podman to create a reproducible build and signing environment for the Android application.
* **License Verification Bypass:** Includes a git patch that modifies the `DoLicenseCheck.java` use case to return an empty string, bypassing the app's default license validation.
* **Custom Update Checker:** Patches `UpdateCheckRepositoryImpl.java` to fetch update information from a custom GitHub repository (`ObjectAscended/cryptomator-android`) and replaces the public key used for verifying app updates.
* **Automated Signing:** Uses a dedicated signing container to automatically sign the resulting APK artifacts using `apksigner`.

## Architecture & Workflow

The build process is managed primarily through GitHub Actions but uses a modular script architecture:

* **`Containerfile`**: Defines two isolated environments:
  * The `builder` image uses Ubuntu 26.04, JDK 17, and the Android SDK to compile the app.
  * The `signer` image uses Ubuntu 26.04 and `apksigner` to securely sign the artifacts.
* **`build.sh`**: A shell script executed inside the `builder` container. It runs the Gradle assemble tasks (`./gradlew assemble...Release`) to build the specific APK variants and collects the unsigned artifacts into an `/artifacts/` directory.
* **`sign.sh`**: Executed inside the `signer` container. It iterates through the unsigned APKs in the artifacts directory and signs them using the provided keystore.

## Configuration & Secrets

To build the project successfully, several environment variables and secrets must be configured. A template is provided in `.env_example`.

**Cloud Provider API Keys (Build Environment):**
* `DROPBOX_API_KEY`
* `ONEDRIVE_API_KEY`
* `ONEDRIVE_API_REDIRCT_URI`
* `PCLOUD_CLIENT_ID`

**Signing Credentials (Sign Environment):**
* `SIGNING_KEYSTORE_PASSWORD`
* `SIGNING_KEY_ALIAS`
* `SIGNING_KEY_PASSWORD`
* `SIGNING_KEYSTORE_BASE64` (Used to decode the `.p12` keystore file during CI)

**Update Checker Secrets:**
* `ES256_PRIVATE_KEY` (Used by a Node.js script in the pipeline to sign the `version.jwt` payload for the custom update checker)

## CI/CD Pipeline (GitHub Actions)

The provided `build.yml` workflow is fully automated and triggers on pushes, pull requests, or manual workflow dispatch.

1. **Environment Setup:** Builds the required Podman images (`builder` and `signer`) and configures the environment variable files (`.env.build` and `.env.sign`) using GitHub Secrets.
2. **Code Retrieval:** Checks out version `1.12.3` of the official `cryptomator/android` repository.
3. **Patch Application:** Automatically applies the custom patches using `git am --3way`.
4. **Build & Sign:** Runs the Podman containers to build the APK store variant and sign it.
5. **Release Preparation:** Uses a Node.js script to hash the APK and generate a signed JWT (`version.jwt`) containing release notes and the custom download URL.
6. **Publishing:** Automatically creates a GitHub Release with the compiled `cryptomator.apk` and the `version.jwt` file.

## File Ignoring

The repository is configured via `.gitignore` to safely ignore sensitive files like `.p12` keystores, local `.env.*` files, and generated directories like `/artifacts/` and `/android/`.