FROM node:25

# Metadata
LABEL maintainer="teslafields"
LABEL description="GitHub Copilot CLI with shell integration"
LABEL version="1.0"

ARG UID
ARG GID

ARG USER_NAME
ARG GROUP_NAME

ENV HOME_DIR /home/$USER_NAME

# Install system dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    git \
    bash \
    bash-completion \
    curl \
    vim \
    openssh-client \
    ca-certificates \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Handle GID conflict: if GID exists, modify it to free up the ID
RUN if getent group ${GID} >/dev/null 2>&1; then \
      EXISTING_GROUP=$(getent group ${GID} | cut -d: -f1); \
      echo "GID ${GID} already used by group '${EXISTING_GROUP}', reassigning..."; \
      groupmod -g $((GID + 10000)) ${EXISTING_GROUP}; \
    fi

# Handle UID conflict: if UID exists, modify it to free up the ID
RUN if getent passwd ${UID} >/dev/null 2>&1; then \
      EXISTING_USER=$(getent passwd ${UID} | cut -d: -f1); \
      echo "UID ${UID} already used by user '${EXISTING_USER}', reassigning..."; \
      usermod -u $((UID + 10000)) ${EXISTING_USER}; \
    fi

# Create non-root user (optional security)
RUN addgroup --gid $GID $GROUP_NAME
RUN adduser --home $HOME_DIR --shell /bin/bash --uid $UID --gid $GID $USER_NAME

RUN mkdir -p  \
    $HOME_DIR/.bin \
    $HOME_DIR/.ssh && \
    chmod -R 700 $HOME_DIR/.ssh

# Create workspace
WORKDIR $HOME_DIR
RUN chown -R $USER_NAME:$GROUP_NAME $HOME_DIR

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to non-root user
USER $USER_NAME

# Install copilot
RUN curl -fsSL https://gh.io/copilot-install -o /tmp/copilot-install.sh && \
    bash /tmp/copilot-install.sh && \
    rm /tmp/copilot-install.sh
RUN echo "export PATH=~/.local/bin:\$PATH" >> $HOME_DIR/.bashrc

# Set environment
ENV SHELL=/bin/bash

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["~/.local/bin/copilot", "--yolo"]
