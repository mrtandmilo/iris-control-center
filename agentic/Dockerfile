# Judges must load the EAP build 154 image locally; never redistribute it.
ARG IMAGE=iris-community:2026.3.0AI.154.0
FROM ${IMAGE}

WORKDIR /home/irisowner/dev
COPY agentic/src ./agentic/src
COPY agentic/iris.script ./agentic/iris.script
COPY scripts/container-entrypoint.sh ./scripts/container-entrypoint.sh

RUN mkdir -p /home/irisowner/irisdata && chown irisowner:irisowner /home/irisowner/irisdata
RUN iris start IRIS && iris session IRIS < agentic/iris.script && iris stop IRIS quietly

ENTRYPOINT ["/bin/bash", "/home/irisowner/dev/scripts/container-entrypoint.sh"]
