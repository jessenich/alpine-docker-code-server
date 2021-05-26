ARG KEPLER_CODE_SERVER_IMAGE_VERSION_TAG="latest" \
    NODE_ALPINE_IMAGE_TAG="current-alpine" \
    CODE_SERVER_VERSION_ARG="auto" \
    PNP_USER_ARG="keplerdev" \
    PNP_GROUP_ARG="keplerdev" \
    PNP_SERVE_IP_ARG="0.0.0.0" \
    PNP_SERVE_PORT_ARG="4999" \
    PNP_SHELL_ARG="/bin/zsh"

FROM node:"${NODE_ALPINE_IMAGE_TAG}"

LABEL \
    com.keplerdev="https://github.com/kplrio/" \
    com.keplerdev.name="kepler-code-server-alpine3"  \
    com.keplerdev.version="${IMAGE_VERSION_TAG}" \
    com.keplerdev.readme="https://github.com/jessenich91/alpine-docker-code-server/README.md" \
    com.keplerdev.tldr.pull="docker pull jessenich91/alpine-code-server:latest" \
    com.keplerdev.tldr.run="docker run jessenich91/alpine-code-server --name 'keplerdev-code-server'" \
    com.keplerdev.author.name="Jesse N." \
    com.keplerdev.author.github-url="https://github.com/jessenich91/" \
    com.keplerdev.author.github-username="jessenich" \
    com.keplerdev.maintainer.name="Jesse N." \
    com.keplerdev.maintainer.github-url="https://github.com/jessenich91/" \
    com.keplerdev.maintainer.github-username="jessenich"

ENV code_version="${VSCODE_VERSION_ARG}" \
    code_server_version="${CODE_SERVER_VERSION_ARG}" \
    http_server_ipaddr="${PNP_SERVE_IP_ARG}" \
    http_server_port="${PNP_SERVE_PORT_ARG}" \
    username="${PNP_USER_ARG}" \
    group="${PNP_GROUP_ARG}" \
    shell="${PNP_SHELL_ARG}"

RUN set -ex; \
    adduser --gecos '' --disabled-password codeserver;

RUN apk update && \
    apk add --no-cache && \ 
    dumb-init \
    bash \
    icu-libs \
    krb5-libs \
    libgcc  \
    libintl \
    libssl1.1 \
    libstdc++ \
    zlib \
    ca-certificates \
    curl \
    jq \
    git \
    gnupg \
    gcc \
    sudo \
    snap \
    zsh && \
    rm -rf /var/lib/apt/lists/*;

COPY ./scripts/install_code_server.sh /dockerfile-build/install_code_server.sh
RUN /bin/zsh /dockerfile-build/install_code_server.sh

RUN addgroup "${group}" && \
    adduser -G "${group}" -s "${shell}" -D "${username}";

USER "${username}";
WORKDIR /home/"${username}"

RUN echo "export POWERSHELL_TELEMETRY_OPTOUT=1" > .zshrc

RUN chown -R root:root /usr/local/bin

## dotnet-install.sh  [--architecture <ARCHITECTURE>] [--azure-feed]
##     [--channel <CHANNEL>] [--dry-run] [--feed-credential]
##     [--install-dir <DIRECTORY>] [--jsonfile <JSONFILE>]
##     [--no-cdn] [--no-path] [--runtime <RUNTIME>] [--runtime-id <RID>]
##     [--skip-non-versioned-files] [--uncached-feed] [--verbose]
##     [--version <VERSION>]
RUN curl -sL https://dot.net/v1/dotnet-install.sh /dockerfile-build/dotnet-install.sh | \
    bash --architecture amd64 --channel current --os linux

COPY ./scripts/install_pwsh.sh /dockerfile-build/install_pwsh.sh
RUN /dockerfile-build/install_pwsh.sh

EXPOSE "${http_server_port}"
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "/usr/lib/code-server/out/node/entry.js", "--disable-updates", "--disable-telemetry", "--bind-addr", "${http_server_ipaddr}:${http_server_port}", "."]