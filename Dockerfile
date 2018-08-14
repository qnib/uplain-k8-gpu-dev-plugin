ARG FROM_IMG_REGISTRY=docker.io
ARG FROM_IMG_REPO=qnib
ARG FROM_IMG_NAME="uplain-cuda8-nvml"
ARG FROM_IMG_TAG="8.0.61-1"
ARG FROM_IMG_HASH=""
FROM ${FROM_IMG_REGISTRY}/${FROM_IMG_REPO}/${FROM_IMG_NAME}:${FROM_IMG_TAG}${DOCKER_IMG_HASH}

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        ca-certificates \
        wget \
        cuda-cudart-dev-8-0 \
        cuda-misc-headers-8-0 \
        cuda-nvml-dev-8-0 \
        git \
 && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.4
RUN wget -nv -O - https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ENV CGO_CFLAGS "-I /usr/local/cuda-8.0/include"
ENV CGO_LDFLAGS "-L /usr/local/cuda-8.0/lib64"
ENV PATH=$PATH:/usr/local/nvidia/bin:/usr/local/cuda/bin
WORKDIR /go/src/github.com/NVIDIA/
RUN git clone https://github.com/NVIDIA/k8s-device-plugin.git nvidia-device-plugin
WORKDIR /go/src/github.com/NVIDIA/nvidia-device-plugin
RUN git checkout -b v1.8 remotes/origin/v1.8
RUN export CGO_LDFLAGS_ALLOW='-Wl,--unresolved-symbols=ignore-in-object-files' \
 && go install -ldflags="-s -w"
CMD ["nvidia-device-plugin"]
