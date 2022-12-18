#!/bin/bash

set -ex

cd "${0%/*}"

CONT=$(buildah from veita/debian-multiservice-bullseye)

buildah copy $CONT etc/ /etc
buildah copy $CONT root/ /root
buildah copy $CONT services/ /services
buildah copy $CONT qsk/ /qsk
buildah copy $CONT setup/ /setup
buildah run $CONT /bin/bash /setup/setup.sh
buildah run $CONT rm -rf /setup

buildah config --workingdir '/' $CONT
buildah config --cmd '["/services/init.sh"]' $CONT

buildah config --port 22/tcp $CONT
buildah config --port 25/tcp $CONT
buildah config --port 465/tcp $CONT
buildah config --port 587/tcp $CONT
buildah config --port 143/tcp $CONT
buildah config --port 993/tcp $CONT

buildah config --author "Alexander Veit" $CONT
buildah config --label commit=$(git describe --always --tags --dirty=-dirty) $CONT

buildah commit --rm $CONT localhost/test-postfix-dovecot:latest

