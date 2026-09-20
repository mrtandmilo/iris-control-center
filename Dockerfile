ARG IMAGE=intersystems/iris-community:2026.1@sha256:c57b65b2b454494091e7b3e49f6a53b3335f40adf475bcfcee0866083f35a7c2
FROM $IMAGE

WORKDIR /home/irisowner/dev

COPY src ./src
COPY web ./web
COPY iris.script ./iris.script
COPY scripts/container-entrypoint.sh ./scripts/container-entrypoint.sh

# Create only the named-volume mountpoint. Keep it empty so iris-main can
# initialize ISC_DATA_DIRECTORY atomically on first startup.
RUN mkdir -p /home/irisowner/irisdata && \
    chown irisowner:irisowner /home/irisowner/irisdata

RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly

# Run through bash rather than relying on the source file's executable bit; the
# GitHub contents API may create text files as 0644. The wrapper delegates to
# the vendor iris-main entrypoint after creating its one-use password file.
ENTRYPOINT ["/bin/bash", "/home/irisowner/dev/scripts/container-entrypoint.sh"]
