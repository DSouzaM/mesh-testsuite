# docker build -t mwdsouza/mesh-artifact-1-redis .

FROM mwdsouza/mesh:git-bee5b676ecca903cadbcf4b470269af8d96d5672 as mesh
FROM bpowers/mstat:git-497eeeee07e6813ebc4d557d50ebe82bbfc05318 as mstat
FROM bpowers/hoard:git-761c11f966d2891b1800844bffe10e176b66d04b as hoard
FROM bpowers/dev:v3 as builder

COPY --from=mesh /usr/local/lib/libmesh* /usr/local/lib/
COPY --from=hoard /usr/local/lib/libhoard.so /usr/local/lib/
RUN ldconfig

RUN apt-get update && apt-get install -y \
      libgoogle-perftools-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY . .

RUN ./build


FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
      python3 \
      libtcmalloc-minimal4 \
      libjemalloc-dev \
      linux-tools-generic \
      linux-tools-4.15.0-66-generic \
      time \
 && rm -rf /var/lib/apt/lists/* \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
 && rm -rf /usr/local/lib/python3.6 \
 && mkdir /data

COPY --from=mstat /usr/local/bin/mstat /usr/local/bin/
COPY --from=hoard /usr/local/lib/libhoard.so /usr/local/lib/
COPY --from=mesh /usr/local/lib/libmesh* /usr/local/lib/
RUN ldconfig

WORKDIR /src

COPY . .

COPY --from=builder /src/bin/* /src/bin/

CMD [ "./test", "--data-dir=/data/1-redis" ]
