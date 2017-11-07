#!/usr/bin/env bash

# Rebuilds an up to date debug muon and upload to S3. 

# Usage:
# AWS_ACCESS_KEY_ID="1231231213" AWS_SECRET_ACCESS_KEY="asdasdasdaf" ./rebuild-debug-muon.sh

if [ ! -d "$(pwd)/browser-laptop-bootstrap" ]; then
  echo "Couldn't find ./browser-laptop-bootstrap in the working directory; exiting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."
  exit 1
fi

docker run --rm -it -v $(pwd)/browser-laptop-bootstrap:/src -v $(pwd)/sccache:/root/.cache/sccache blb /bin/sh -c "git pull; npm install; npm run sync -- --all; npm run build -- --debug_build=true --official_build=false"
BUILD_EXIT_CODE=$?
if [ ! $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Build exited with nonzero code: $BUILD_EXIT_CODE, aborting"
  exit 1
fi

MUON_SHA=$((cd browser-laptop-bootstrap/src/electron && git rev-parse --short HEAD) | tail -1)
docker run -it --rm -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" -v $(pwd)/browser-laptop-bootstrap/src/out/Release/:/opt/target build-uploader s3://brave-test-builds/muon/muon-${MUON_SHA}-debug-linux-x64.zip
echo "Uploaded debug muon ${MUON_SHA}"

docker run -it --rm -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" -v $(pwd)/browser-laptop-bootstrap/src/out/Release/:/opt/target --entrypoint=/bin/sh build-uploader -c "aws s3 cp --acl public-read s3://brave-test-builds/muon/muon-${MUON_SHA}-debug-linux-x64.zip s3://brave-test-builds/muon/brave-debug-latest-linux-x64.zip"
echo "Updated latest build to ${MUON_SHA}"
