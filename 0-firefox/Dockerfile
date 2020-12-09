# docker build -t mwdsouza/mesh-artifact-0-firefox .

# copy new mesh build into old build
FROM mwdsouza/mesh:git-bee5b676ecca903cadbcf4b470269af8d96d5672 as mesh

FROM bpowers/mesh-artifact-0-firefox:latest

COPY --from=mesh /usr/local/lib/libmesh* /usr/local/lib/
COPY --from=mesh /usr/local/lib/libmesh2y.so /usr/local/lib/libmesh.so


# The image's apt sources have been moved to old-releases.ubuntu.com
RUN sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    linux-tools-generic

# I'm sorry
# The docker image runs on the host kernel which is newer than the image distro, so it won't be able to find the
# correct packages for this kernel. Symlinking this version directly seems to work OK.
RUN ln -sf /usr/lib/linux-tools/4.18.0-25-generic/perf /usr/bin/perf

# use our copy of atsy + Speedometer (testing less allocators, reporting different metrics)
COPY atsy/run_speedometer atsy/run_speedometer
COPY atsy/firefox-test-wrapper atsy/firefox-test-wrapper
COPY atsy/firefox-test-wrapper-perf atsy/firefox-test-wrapper-perf
COPY atsy/atsy atsy/atsy

COPY Speedometer Speedometer
COPY entrypoint.sh entrypoint.sh
