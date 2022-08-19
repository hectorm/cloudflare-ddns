m4_changequote([[, ]])

##################################################
## "main" stage
##################################################

m4_ifdef([[CROSS_ARCH]], [[FROM docker.io/CROSS_ARCH/ubuntu:22.04]], [[FROM docker.io/ubuntu:22.04]]) AS main
m4_ifdef([[CROSS_QEMU]], [[COPY --from=docker.io/hectorm/qemu-user-static:latest CROSS_QEMU CROSS_QEMU]])

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
RUN find /usr/bin/cloudflare-ddns -type f -not -perm 0755 -exec chmod 0755 '{}' ';'

# Create unprivileged user
RUN useradd -u 100000 -g 0 -MN ddns
USER 100000:0

CMD ["/bin/sh", "-c", "while true; do /usr/bin/cloudflare-ddns; sleep 60; done"]
