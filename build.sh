#!/bin/bash

# use build_variant arg to build a specific variant. if not set, all variants will be built
build_variant=$1

# build
./gradlew assemble${build_variant^}Release --parallel

# gather release variants
if [[ -n $build_variant ]]; then
	release_variants=($build_variant)
else
	release_variants=($(ls ./presentation/build/outputs/apk/))
fi

# collect artifacts
for variant in "${release_variants[@]}"; do
	cp ./presentation/build/outputs/apk/$variant/release/presentation-$variant-release-unsigned.apk \
		../artifacts/cryptomator-$variant-unsigned.apk
done

# move to artifacts directory
cd ../artifacts

# sign apks
if [ "$SIGNING_ENABLED" == "true" ]; then
	for variant in "${release_variants[@]}"; do
		apksigner sign \
			--v4-signing-enabled false \
			--ks ../release.p12 \
			--ks-pass pass:$SIGNING_KEYSTORE_PASSWORD \
			--ks-key-alias $SIGNING_KEY_ALIAS \
			--key-pass pass:$SIGNING_KEY_PASSWORD \
			--out cryptomator-$variant.apk \
			cryptomator-$variant-unsigned.apk
	done
fi
