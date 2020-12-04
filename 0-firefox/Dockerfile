# docker build -t mwdsouza/mesh-artifact-0-firefox .

# copy new mesh build into old build
FROM mwdsouza/mesh:git-bee5b676ecca903cadbcf4b470269af8d96d5672 as mesh

FROM bpowers/mesh-artifact-0-firefox:latest

COPY --from=mesh /usr/local/lib/libmesh* /usr/local/lib/
COPY --from=mesh /usr/local/lib/libmesh2y.so /usr/local/lib/libmesh.so

# use our copy of atsy + Speedometer (testing less allocators, reporting different metrics)
COPY atsy/run_speedometer atsy/run_speedometer
COPY atsy/firefox-test-wrapper atsy/firefox-test-wrapper
COPY atsy/atsy atsy/atsy

COPY Speedometer Speedometer
COPY entrypoint.sh entrypoint.sh