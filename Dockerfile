ARG IMAGE=containers.intersystems.com/intersystems/iris-community:latest-em
FROM $IMAGE

WORKDIR /home/irisowner/dev

COPY src ./src
COPY web ./web
COPY iris.script ./iris.script

RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly
