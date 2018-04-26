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
    curl wget libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev graphviz vim doxygen tree unzip
RUN apt-get install -y \
    gcc g++ libgomp1 libpomp-dev lcov gcovr
RUN apt-get install -y \
    clang clang-tidy clang-format clang-tools lld lldb python-clang-6.0 python-lldb-6.0
# To delete once vcpkg works
RUN apt-get install -y \
    libsfml-dev libtbb-dev imagemagick libmagick++-dev libboost-all-dev libpoco-dev \
    freeglut3-dev libfreeimage-dev catch protobuf-compiler protobuf-c-compiler \
    libtinyxml2-dev nlohmann-json-dev glew-utils libglew-dev
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

# VCPKG
WORKDIR /opt
RUN git clone https://github.com/Microsoft/vcpkg
WORKDIR /opt/vcpkg
RUN ./bootstrap-vcpkg.sh

# VCPKG packages
WORKDIR /opt/vcpkg
RUN ./vcpkg install gtest:x64-linux
RUN ./vcpkg install benchmark:x64-linux
RUN ./vcpkg install ms-gsl:x64-linux
RUN ./vcpkg install catch:x64-linux catch2:x64-linux
RUN ./vcpkg install sdl2:x64-linux
RUN ./vcpkg install eigen3:x64-linux
RUN ./vcpkg install protobuf:x64-linux
RUN ./vcpkg install tinyxml2:x64-linux
RUN ./vcpkg install rapidjson:x64-linux
RUN ./vcpkg install nlohmann-json:x64-linux
RUN ./vcpkg install glew:x64-linux
RUN ./vcpkg install itk:x64-linux

# does not work :(
# RUN ./vcpkg install boost:x64-linux
# RUN ./vcpkg install poco:x64-linux
# RUN ./vcpkg install freeglut:x64-linux
# RUN ./vcpkg install freeimage:x64-linux
# RUN ./vcpkg install allegro5:x64-linux
# RUN ./vcpkg install vtk:x64-linux
# RUN ./vcpkg install tbb:x64-linux
# RUN ./vcpkg install sfml:x64-linux
RUN rm -rf /buildtrees/*

# Kcov
WORKDIR /tmp
RUN git clone https://github.com/SimonKagstrom/kcov.git
WORKDIR /tmp/kcov/build
RUN cmake -G Ninja .. && cmake --build . --config Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/kcov

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

WORKDIR /workspace

CMD ["/bin/bash"]
