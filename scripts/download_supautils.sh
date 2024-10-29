#!/bin/sh
set -e
# Ensure mandatory environment variables are set
: "${supautils_release:?Environment variable supautils_release is required}"
: "${postgresql_major:?Environment variable postgresql_major is required}"
: "${supautils_release_arm64_deb_checksum:?Environment variable supautils_release_arm64_deb_checksum is required}"
: "${supautils_release_amd64_deb_checksum:?Environment variable supautils_release_amd64_deb_checksum is required}"

# Fallback to uname -m if TARGETARCH is not set
TARGETARCH=${TARGETARCH:-$(uname -m)}

if [ "$TARGETARCH" = "x86_64" ] || [ "$TARGETARCH" = "amd64" ]; then
    CHECKSUM="${supautils_release_amd64_deb_checksum}"
    ARCH="amd64"
elif [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "aarch64" ]; then
    CHECKSUM="${supautils_release_arm64_deb_checksum}"
    ARCH="arm64"
else
    echo "Unsupported architecture: $TARGETARCH" >&2
    exit 1
fi
CHECKSUM=$(echo $CHECKSUM | sed "s/^sha256://")
curl -fsSL -o /tmp/supautils.deb \
    "https://github.com/supabase/supautils/releases/download/v${supautils_release}/supautils-v${supautils_release}-pg${postgresql_major}-$ARCH-linux-gnu.deb"
CHECKSUM_LINE=$(echo "$CHECKSUM  /tmp/supautils.deb")
echo "$CHECKSUM_LINE" | sha256sum -c -
