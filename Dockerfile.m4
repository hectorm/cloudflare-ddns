m4_changequote([[, ]])

##################################################
## "main" stage
##################################################

m4_ifdef([[CROSS_ARCH]], [[FROM docker.io/CROSS_ARCH/ubuntu:24.04]], [[FROM docker.io/ubuntu:24.04]]) AS main

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
RUN userdel -rf "$(id -nu 1000)" && useradd -u 1000 -g 0 -s "$(command -v bash)" -m ddns

# Drop root privileges
USER ddns:root

CMD ["/bin/sh", "-euc", "while true; do /usr/bin/cloudflare-ddns; sleep \"${CF_CHECK_INTERVAL:-60}\"; done"]
