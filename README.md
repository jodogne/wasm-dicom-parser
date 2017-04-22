# Parsing DICOM using WebAssembly

This repository contains a sample showing how
[WebAssembly](http://webassembly.org/) (`.wasm`) can be used to implement the
parsing of DICOM files client-side, i.e. directly by a Web browser. [DICOM](https://en.wikipedia.org/wiki/DICOM)
is the standard file format for medical imaging. The DICOM parser is
entirely written in C++ using the industrial-grade [DCMTK toolkit](http://dicom.offis.de/dcmtk.php.en).

## Demonstration

A live demonstration of this code is available on the [Orthanc homepage](http://www.orthanc-server.com/external/wasm-dicom-parser/).

## Compiling

Download the latest version of the [WebAssembly toolkit](http://webassembly.org/getting-started/developers-guide/) based upon Emscripten.

```
# mkdir Build
# cd Build
# cmake .. -DCMAKE_TOOLCHAIN_FILE=/home/jodogne/Downloads/emsdk/emscripten/incoming/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=.
# make install
# firefox ./wasm-dicom-parser/index.html
```

Obviously, adapt the path of the `CMAKE_TOOLCHAIN_FILE` of the `cmake` invokation to your own environment.

## Licensing

This sample code is provided courtesy of [Osimis](http://osimis.io/), and is licensed under AGPL.
