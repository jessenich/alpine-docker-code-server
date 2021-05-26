#!/bin/zsh

set -ex;

## Get latest version from releases page
if [[ "${vscode_version_number}" = "auto" ]] then;
    vscode_version_number=$(curl -sL https://api.github.com/repos/cdr/code-server/releases/latest | jq '.name' | sed -e 's/"//g')
fi

## Strip 'v' for URI compatible string
code_server_version_number="$(echo "${vscode_version_number}" | sed 's|v||g')";

## download specified release tarball to temp directory, extract, move to lib folder
curl -sL https://github.com/cdr/code-server/releases/download/"${code_server_version_number} "/code-server-"${vscode_version_number}"-linux-amd64.tar.gz -o /tmp/code-server-"${vscode_version_number}"-linux-amd64.tar.gz;
tar -xzf /tmp/code-server-"${vscode_version_number}"-linux-amd64.tar.gz -C /tmp;
mkdir /usr/local/lib/code-server;
mv /tmp/code-server-"${vscode_version_number}"-linux-amd64 /usr/local/lib/code-server;

## Create docker executable alias
echo "#!/bin/zsh\r\rsudo docker-bin $@" > /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker;

exit 0;