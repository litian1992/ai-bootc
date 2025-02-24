FROM --platform=linux/amd64 docker.io/library/rust:slim

RUN apt-get update && apt-get install -y libtss2-esys-3.0.2-0 libtss2-tctildr0
COPY ./kbs-client /kbs-client
