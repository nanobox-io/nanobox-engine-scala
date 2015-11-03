FROM nanobox/build:beta

# Remove existing engines, we don't want to test those
RUN rm -rf /opt/engines/*

# Create folders for this engine
RUN mkdir -p /opt/engines/scala/bin && \
    mkdir -p /opt/engines/scala/lib && \
    mkdir -p /opt/engines/scala/templates && \
    mkdir -p /opt/tests/sample-scala

# Add in this engine's files
ADD bin/. /opt/engines/scala/bin
ADD lib/. /opt/engines/scala/lib
ADD templates/. /opt/engines/scala/templates
ADD tests/sample-scala/src/. /opt/tests/sample-scala