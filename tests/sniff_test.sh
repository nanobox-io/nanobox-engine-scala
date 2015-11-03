echo running tests for scala
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build-scala sleep 365d

defer docker kill $UUID

pass "unable to create code folder" docker exec $UUID mkdir -p /opt/code

fail "Detected something when there shouldn't be anything" docker exec $UUID bash -c "cd /opt/engines/scala/bin; ./sniff /opt/code"

pass "Failed to inject scala file" docker exec $UUID touch /opt/code/build.sbt

pass "Failed to detect Scala" docker exec $UUID bash -c "cd /opt/engines/scala/bin; ./sniff /opt/code"