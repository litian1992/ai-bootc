FROM registry.redhat.io/rhel9/rhel-bootc:9.5

ARG ORG_ID
ARG ACTIVATION_KEY

ENV ORG_ID=$ORG_ID
ENV ACTIVATION_KEY=$ACTIVATION_KEY

RUN subscription-manager register --org=${ORG_ID} --activationkey=${ACTIVATION_KEY}

RUN dnf -y install cloud-init && \
    ln -s ../cloud-init.target /usr/lib/systemd/system/default.target.wants && \
    rm -rf /var/{cache,log} /var/lib/{dnf,rhsm}

ADD ./wheel-nopasswd /etc/sudoers.d/

RUN dnf install -y gcc gcc-c++ make git python3.11 python3.11-devel python3-pip

USER root
ENV VIRTUAL_ENV=/opt/venv
RUN python3.11 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN  pip install instructlab && \
     pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
     pip install hf_transfer


#RUN mkdir -p /usr/lib/bootc/install
#RUN cat <<EOF >> /usr/lib/bootc/install/00-kargs.toml
#[install.filesystem.root]
#type = "ext4"
#[install]
#kargs = [ "console=ttyS0", "selinux=0", "enforcing=0", "audit=0"]
#match-architectures = ["x86_64"]
#EOF

