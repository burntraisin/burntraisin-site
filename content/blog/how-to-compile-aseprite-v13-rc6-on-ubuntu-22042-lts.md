+++
title = "How to Compile Aseprite V1.3-RC6 on Ubuntu 22.04.2 LTS"
date = "2024-07-14"
tags = ["linux",]
+++

When trying to compile [Aseprite](https://www.aseprite.org/), I found that following the [install guide](https://github.com/aseprite/aseprite/blob/main/INSTALL.md) for Ubuntu 22.04.2 LTS led to a couple of error messages. I had a list of commands I used to successfully compile [Aseprite V1.3-RC6](https://github.com/aseprite/aseprite/releases/tag/v1.3-rc6) saved in a text file that I meant to upload a long time ago. Better late than never, I suppose.

In addition to the install guide, I remember referencing a couple of obscure blog posts and comments made on GitHub. Unfortuantely, I don't have them documented, so if anyone has a relevant link, please reach out to me at `rbkehan@gmail.com`!

## The Steps

1. Install the needed dependencies:
   ``` bash
   sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev
   ```
2. Check the version of `CMake`. Make sure it's 3.16+.
   ``` bash
   cmake --version
   ```
3. Install the `Ninja` build system:
   ``` bash
   sudo apt-get install ninja-build
   ```
4. Install `aseprite-m102` of the Skia library:
   ``` bash
   mkdir $HOME/deps
   cd $HOME/deps
   git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
   git clone -b aseprite-m102 https://github.com/aseprite/skia.git
   export PATH="${PWD}/depot_tools:${PATH}"
   cd skia
   # Install python-is-python3 because you may get error running python tools/git-sync-deps
   sudo apt install python-is-python3
   python tools/git-sync-deps
   # Comand below is modified; this uses clang 14.0.0, so make sure you have that version!
   gn gen out/Release-x64 --args='is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false cc="clang-14" cxx="clang++-14" extra_cflags_cc=["-stdlib=libc++"] extra_ldflags=["-stdlib=libc++"]' 
   ninja -C out/Release-x64 skia modules
   ```
5. Download and extract the [repository](https://github.com/aseprite/aseprite/releases/tag/v1.3-rc6).
6. Compile the program:
   ``` bash
   cd aseprite
   mkdir build
   cd build
   export CC=clang
   export CXX=clang++
   cmake \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo \
   -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
   -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
   -DLAF_BACKEND=skia \
   -DSKIA_DIR=$HOME/deps/skia \
   -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-x64 \
   -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-x64/libskia.a \
   -G Ninja \
   ..
   ninja aseprite
   ```
7. Open Aseprite:
   ``` bash
   cd build/bin
   ./aseprite
   ```