FROM amazonlinux:2 as installer

RUN yum update -y \
  && yum install -y unzip wget \
  && wget  https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  && unzip awscli-exe-linux-x86_64.zip \
  && wget https://releases.hashicorp.com/vault/1.9.2/vault_1.9.2_linux_amd64.zip \
  && unzip vault_1.9.2_linux_amd64.zip -d /opt && chmod +x /opt/vault  \
  && wget -O /opt/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && chmod +x /opt/jq \
  && ./aws/install --bin-dir /aws-cli-bin/

FROM amazonlinux:2
RUN yum update -y \
  && yum install -y less groff \
  && yum clean all \
  && rm -rf /var/cache/yum
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/
COPY --from=installer /opt/vault usr/local/bin/
COPY --from=installer /opt/jq usr/local/bin/
WORKDIR /aws
ENTRYPOINT ["/usr/local/bin/aws"]
