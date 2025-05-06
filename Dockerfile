FROM ubuntu:20.04

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    curl \
    nodejs \
    npm \
    python3 \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH Server setup
RUN mkdir -p /var/run/sshd
RUN echo 'root:render123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
RUN sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash tunneluser
RUN echo 'tunneluser:tunnel123' | chpasswd

# Install localtunnel
RUN npm install -g localtunnel

# Add dummy index.html
RUN echo "Tunnel is running" > /index.html

# Update supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 22 80 443

# Default command
CMD ["/usr/bin/supervisord"]
