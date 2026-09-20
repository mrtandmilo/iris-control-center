ARG IMAGE=intersystems/iris-community:2026.1@sha256:c57b65b2b454494091e7b3e49f6a53b3335f40adf475bcfcee0866083f35a7c2
FROM $IMAGE

WORKDIR /home/irisowner/dev

COPY src ./src
COPY web ./web
COPY iris.script ./iris.script
COPY scripts/container-entrypoint.sh ./scripts/container-entrypoint.sh

# Seed the named-volume mountpoint with irisowner ownership. Docker copies these
# permissions and contents into a newly created volume. The private web server's
# CSP tree is relocated under ISC_DATA_DIRECTORY at first startup, so expose the
# immutable UI there with a symlink back to the application files in the image.
RUN mkdir -p /home/irisowner/irisdata/csp && \
    ln -s /home/irisowner/dev/web /home/irisowner/irisdata/csp/iris-control-center

RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly

# Run through bash rather than relying on the source file's executable bit; the
# GitHub contents API may create text files as 0644. The wrapper delegates to
# the vendor iris-main entrypoint after creating its one-use password file.
ENTRYPOINT ["/bin/bash", "/home/irisowner/dev/scripts/container-entrypoint.sh"]
