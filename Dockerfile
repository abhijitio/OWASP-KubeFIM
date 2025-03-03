# Start from a base image that supports the necessary dependencies
FROM ubuntu:20.04
#FROM alpine:3.8
# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

#RUN apt update && apt install -y linux-headers-$(uname -r)

# Install necessary packages
#RUN apt update && \
#    apt install -y \
#    bcc-tools libbcc-examples linux-headers-$(uname -r) \
#    clang llvm libelf-dev gcc iproute2 git cmake make iputils-ping \
#    curl
#

# Install Golang
RUN apt update && apt install -y \
    bc \
    python3 \
    bison \
    flex \
    curl \
    make

RUN apt update && apt install -y curl && apt install -y clang && apt install -y llvm

RUN curl -OL https://golang.org/dl/go1.22.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz && \
    rm go1.22.2.linux-amd64.tar.gz

# Set the environment variable for Go
ENV PATH=$PATH:/usr/local/go/bin

RUN apt install -y gcc-multilib
RUN apt install -y pkg-config
RUN apt install -y m4
RUN apt install -y libelf-dev
RUN apt install -y libpcap-dev
RUN apt install -y gcc-multilib
RUN apt install -y libbpf-dev

RUN mkdir /usr/src/kubefim_program
# Copy your eBPF program into the container
COPY kprobe.c /usr/src/kubefim_program
COPY main.go /usr/src/kubefim_program
COPY gen.go /usr/src/kubefim_program



# Set the working directory
WORKDIR /usr/src/kubefim_program

RUN go mod init kubefim
RUN go mod tidy
RUN go generate
RUN go build

RUN ls
# Command to run your eBPF program
CMD ["./kubefim"]