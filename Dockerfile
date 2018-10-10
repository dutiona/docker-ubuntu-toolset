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
  gcc g++ libgomp1 libpomp-dev lcov gcovr gcc-8 g++-8
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

# Kcov
WORKDIR /tmp
RUN git clone https://github.com/SimonKagstrom/kcov.git
WORKDIR /tmp/kcov/build
RUN cmake -G Ninja .. && cmake --build . --config Release && ninja install
WORKDIR /tmp
RUN rm -rf /tmp/kcov

WORKDIR /root/.conan/profiles
COPY conan-profiles/* ./

WORKDIR /workspace

CMD ["/bin/bash"]
