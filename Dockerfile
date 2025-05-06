FROM ubuntu:20.04

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    curl \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 14.x (or later)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install localtunnel globally
RUN npm install -g localtunnel

# SSH Server setup
RUN mkdir -p /var/run/sshd
RUN echo 'root:render123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
RUN sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config

# Create a dedicated user
RUN useradd -m -s /bin/bash tunneluser
RUN echo 'tunneluser:tunnel123' | chpasswd

# Set up supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start SSH daemon
EXPOSE 22 80 443
CMD ["/usr/bin/supervisord"]
