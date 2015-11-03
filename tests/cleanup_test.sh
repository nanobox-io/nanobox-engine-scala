echo running tests for scala
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build-scala sleep 365d

defer docker kill $UUID

pass "Failed to run cleanup script" docker exec $UUID bash -c "cd /opt/engines/scala/bin; ./cleanup '$(payload default-cleanup)'"