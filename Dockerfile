FROM ubuntu:bionic
LABEL maintainer="Michaël Roynard <mroynard@lrde.epita.fr>"

ENV container docker
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install all pkg
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get dist-upgrade -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential binutils git ninja-build cmake bear python python3 python-pip python3-pip \
    gcc g++ gcc-6 g++-6 libgomp1 libpomp-dev curl wget libcurl4-openssl-dev graphviz \
    fuse snapcraft snapd snap-confine squashfuse
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    clang-5.0 lld-5.0 python-lldb-5.0 lldb-5.0 clang-tidy-5.0 clang-format-5.0 libomp5 \
    libboost-all-dev libpoco-dev catch libsdl2-dev libsfml-dev libeigen3-dev libtbb-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    protobuf-compiler protobuf-c-compiler libtinyxml2-dev nlohmann-json-dev doxygen vim \
    glew-utils libglew-dev freeglut3-dev imagemagick libmagick++-dev libfreeimage-dev lcov gcovr
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y && rm -rf /var/lib/apt/lists/

# Install python packages
RUN echo y | pip install -U pip
RUN echo y | pip install -U six wheel setuptools
RUN echo y | pip install scan-build conan sphinx breathe exhale \
    numpy scipy requests scrapy scapy nltk sympy sphinx_rtd_theme \
    pillow sqlalchemy beautifulsoup twisted matplotlib pyglet
RUN echo y | pip3 install -U pip
RUN echo y | pip3 install -U six wheel setuptools			 
RUN echo y | pip3 install scan-build conan sphinx breathe exhale  \
    numpy scipy requests scrapy nltk sympy sphinx_rtd_theme \
    pillow sqlalchemy twisted matplotlib pyglet

# Google Test
WORKDIR /tmp/gtest
RUN git clone https://github.com/google/googletest.git
WORKDIR /tmp/gtest/build
RUN cmake -G Ninja ../googletest && cmake --build . --config Release && ninja install
RUN rm -rf /tmp/gtest

# Google Benchmark
WORKDIR /tmp/benchmark
RUN git clone https://github.com/google/benchmark.git && git clone https://github.com/google/googletest.git benchmark/googletest
WORKDIR /tmp/benchmark/build
RUN cmake -G Ninja ../benchmark && cmake --build . --config Release && ninja install
RUN rm -rf /tmp/benchmark

# GSL
WORKDIR /tmp/gsl
RUN git clone https://github.com/Microsoft/GSL.git
WORKDIR /tmp/gsl/build
RUN cmake -G Ninja -DCMAKE_CXX_FLAGS=-Wno-error=sign-conversion ../GSL && cmake --build . --config Release && ctest -C Release && ninja install
RUN rm -rf /tmp/gsl

ADD ./build-dispatch /usr/local/bin/

WORKDIR /workspace

CMD ["/bin/bash"]
# Entrypoint on build script, disabled for now
#ENTRYPOINT ["/usr/local/bin/build-dispatch"]
#CMD ["--help"]