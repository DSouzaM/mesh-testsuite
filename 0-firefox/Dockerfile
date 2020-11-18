# docker build -t mwdsouza/mesh-artifact-0-firefox .

FROM mwdsouza/mesh:git-bee5b676ecca903cadbcf4b470269af8d96d5672 as mesh
FROM bpowers/mstat:git-497eeeee07e6813ebc4d557d50ebe82bbfc05318 as mstat
FROM bpowers/hoard:git-761c11f966d2891b1800844bffe10e176b66d04b as hoard

FROM mwdsouza/mesh-artifact-0-firefox-base:latest

RUN apt-get update && apt-get install -y \
  build-essential \
  python-dev \
  python-setuptools \
  linux-tools-common \
  linux-tools-generic \
  gdb \
  strace \
  libgoogle-perftools-dev \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /data

COPY --from=mstat /usr/local/bin/mstat /usr/local/bin/
COPY --from=mesh /usr/local/lib/libmesh* /usr/local/lib/
COPY --from=mesh /usr/local/lib/libmesh2y.so /usr/local/lib/libmesh.so

RUN ldconfig

WORKDIR /src

COPY . .

RUN cd /src/atsy/atsy \
 && python setup.py develop

CMD [ "./entrypoint.sh" ]
