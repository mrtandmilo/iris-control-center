ARG IMAGE=intersystems/iris-community:2026.1@sha256:c57b65b2b454494091e7b3e49f6a53b3335f40adf475bcfcee0866083f35a7c2
FROM $IMAGE

WORKDIR /home/irisowner/dev

COPY src ./src
COPY web ./web
COPY iris.script ./iris.script

RUN iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly
