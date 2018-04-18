FROM ubuntu:bionic
LABEL maintainer="Michaël Roynard <mroynard@lrde.epita.fr>"

ENV container docker
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install all pkg
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get dist-upgrade -y && apt-get upgrade -y
RUN apt-get install -y \
    build-essential binutils-dev git ninja-build cmake bear python python3 python-pip python3-pip \
    curl wget libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev graphviz vim doxygen tree
RUN apt-get install -y \
    gcc g++ libgomp1 libpomp-dev
RUN apt-get install -y \
    clang clang-tidy clang-format lld clang-tools-5.0 \
    clang-6.0 lldb-6.0 clang-tidy-6.0 clang-format-6.0 lld-6.0 clang-tools-6.0 python-clang-6.0 python-lldb-6.0
RUN apt-get install -y \
    libboost-all-dev libpoco-dev catch libsdl2-dev libsfml-dev libeigen3-dev libtbb-dev
RUN apt-get install -y \
    protobuf-compiler protobuf-c-compiler libtinyxml2-dev nlohmann-json-dev lcov gcovr \
    glew-utils libglew-dev freeglut3-dev imagemagick libmagick++-dev libfreeimage-dev
RUN apt-get update && apt-get upgrade -y

# Clean
RUN apt-get autoremove -y && apt-get autoclean -y
# RUN rm -rf /var/lib/apt/lists/

# Install python packages
RUN echo y | pip install -U pip six wheel setuptools
RUN echo y | pip install scan-build conan \
    numpy scipy requests scrapy scapy nltk sympy \
    pillow sqlalchemy beautifulsoup twisted matplotlib pyglet
RUN echo y | pip3 install -U pip six wheel setuptools
RUN echo y | pip3 install scan-build conan \
    numpy scipy requests scrapy nltk sympy \
    pillow sqlalchemy twisted matplotlib pyglet

# Google Test
WORKDIR /tmp
RUN git clone https://github.com/google/googletest.git
WORKDIR /tmp/googletest/build
RUN cmake -G Ninja .. && cmake --build . --config Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/googletest

# Google Benchmark
WORKDIR /tmp
RUN git clone https://github.com/google/benchmark.git && git clone https://github.com/google/googletest.git /tmp/benchmark/googletest
WORKDIR /tmp/benchmark/build
RUN cmake -G Ninja .. && cmake --build . --config Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/benchmark

# GSL
WORKDIR /tmp
RUN git clone https://github.com/Microsoft/GSL.git
WORKDIR /tmp/GSL/build
RUN cmake -G Ninja -DCMAKE_CXX_FLAGS=-Wno-error=sign-conversion .. && cmake --build . --config Release && ctest -C Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/GSL

# Kcov
WORKDIR /tmp
RUN git clone https://github.com/SimonKagstrom/kcov.git
WORKDIR /tmp/kcov/build
RUN cmake -G Ninja .. && cmake --build . --config Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/kcov

WORKDIR /workspace

CMD ["/bin/bash"]
