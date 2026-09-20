ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2026.1
FROM $IMAGE

WORKDIR /home/irisowner/dev

COPY src ./src
COPY web ./web
COPY iris.script ./iris.script

RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly
