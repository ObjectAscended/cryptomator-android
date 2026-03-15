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