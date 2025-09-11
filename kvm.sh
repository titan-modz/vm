#!/bin/bash
set -e

# Build the KVM-enabled Debian 12 image
cat > Dockerfile <<'EOF'
FROM debian:12

# Install dependencies for KVM + QEMU
RUN apt-get update && apt-get install -y \
    qemu-kvm \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    virt-manager \
    bridge-utils \
    && rm -rf /var/lib/apt/lists/*

# Default to root shell
CMD ["/bin/bash"]
EOF

# Build the image
docker build -t kvm-debian12 .

# Create vmdata folder if not exists
mkdir -p ./vmdata

# Run the container
docker run -it --rm \
  --name hopingboyz \
  --hostname azimeee \
  --device /dev/kvm \
  -v $PWD/vmdata:/vmdata \
  -e RAM=8000 \
  -e CPU=4 \
  -e DISK_SIZE=100G \
  kvm-debian12
