FROM nanobox/build:beta

# Remove existing engines, we don't want to test those
RUN rm -rf /opt/engines/*

# Create folders for this engine
RUN mkdir -p /opt/engines/scala/bin && \
    mkdir -p /opt/engines/scala/lib && \
    mkdir -p /opt/engines/scala/templates && \
    mkdir -p /opt/tests/sample-scala

RUN curl https://codeload.github.com/nanobox-io/nanobox-engine-nodejs/tar.gz/master | \
    tar -xzC /opt/engines/scala --strip-components 1

RUN curl https://codeload.github.com/nanobox-io/nanobox-engine-java/tar.gz/master | \
    tar -xzC /opt/engines/scala --strip-components 1

# Add in this engine's files
ADD bin/. /opt/engines/scala/bin
ADD lib/. /opt/engines/scala/lib
ADD templates/. /opt/engines/scala/templates
ADD tests/sample-scala/src/. /opt/tests/sample-scala