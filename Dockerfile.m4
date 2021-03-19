m4_changequote([[, ]])

##################################################
## "cloudflare-ddns" stage
##################################################

m4_ifdef([[CROSS_ARCH]], [[FROM docker.io/CROSS_ARCH/ubuntu:20.04]], [[FROM docker.io/ubuntu:20.04]]) AS cloudflare-ddns
m4_ifdef([[CROSS_QEMU]], [[COPY --from=docker.io/hectormolinero/qemu-user-static:latest CROSS_QEMU CROSS_QEMU]])

# Install system packages
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		jq \
		knot-dnsutils \
	&& rm -rf /var/lib/apt/lists/*

# Copy script
COPY --chown=root:root ./cloudflare-ddns /usr/bin/cloudflare-ddns
RUN chmod 0755 /usr/bin/cloudflare-ddns

# Create unprivileged user
RUN useradd -u 100000 -g 0 -MN ddns
USER 100000:0

ENTRYPOINT ["/bin/sh"]
CMD ["-c", "while true; do /usr/bin/cloudflare-ddns; sleep 120; done"]
