echo running tests for scala
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build-scala sleep 365d

defer docker kill $UUID

pass "unable to create code folder" docker exec $UUID bash -c "cd /opt/engines/scala/bin; ./boxfile '$(payload default-boxfile)'"
