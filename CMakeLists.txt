# Parsing DICOM using WebAssembly
# Copyright (C) 2017 Sebastien Jodogne <s.jodogne@gmail.com>, Osimis,
# Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


cmake_minimum_required(VERSION 2.8.3)

# Configure the compiler
set(WASM_FLAGS "-s WASM=1")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${WASM_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WASM_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s ALLOW_MEMORY_GROWTH=1 --js-library ${CMAKE_SOURCE_DIR}/Sources/library.js")

# Download the source code of DCMTK 3.6.0
include(${CMAKE_SOURCE_DIR}/Resources/DownloadPackage.cmake)
set(DCMTK_SOURCES_DIR ${CMAKE_BINARY_DIR}/dcmtk-3.6.0)
DownloadPackage(
  "219ad631b82031806147e4abbfba4fa4"
  http://www.orthanc-server.com/downloads/third-party/dcmtk-3.6.0.zip
  ${DCMTK_SOURCES_DIR})
  

add_definitions(
  -DHAVE_CONFIG_H=1
  -DLOG4CPLUS_DISABLE_FATAL=1    # Disable the log4cplus support
  )

include_directories(
  ${CMAKE_SOURCE_DIR}/Resources  # To include the "dcmtk" folder
  ${DCMTK_SOURCES_DIR}/oflog/include
  ${DCMTK_SOURCES_DIR}/ofstd/include
  ${DCMTK_SOURCES_DIR}/dcmdata/include
  )

set(DCMTK_SOURCES_OFSTD
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofcmdln.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofconapp.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofcond.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofconfig.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofconsol.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofcrc32.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofdate.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofdatime.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/offname.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/oflist.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofstd.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofstring.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/ofthread.cc
  ${DCMTK_SOURCES_DIR}/ofstd/libsrc/oftime.cc
  )

set(DCMTK_SOURCES_DCMDATA
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/cmdlnarg.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcbytstr.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcchrstr.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dccodec.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdatset.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcddirif.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdicdir.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdicent.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdictbi.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdict.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdictzz.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcdirrec.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcelem.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcerror.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcfilefo.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dchashdi.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcistrma.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcistrmb.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcistrmf.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcistrmz.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcitem.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dclist.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcmetinf.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcobject.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcostrma.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcostrmb.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcostrmf.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcostrmz.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcpath.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcpcache.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcpixel.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcpixseq.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcpxitem.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrleccd.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrlecce.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrlecp.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrledrg.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrleerg.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcrlerp.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcsequen.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcstack.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcswap.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dctag.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dctagkey.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dctypes.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcuid.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvm.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrae.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvras.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrat.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvr.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrcs.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrda.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrds.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrdt.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrfd.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrfl.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvris.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrlo.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrlt.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrobow.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrof.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrpn.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrpobw.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrsh.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrsl.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrss.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrst.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrtm.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrui.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrul.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrulup.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrus.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcvrut.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcwcache.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/dcxfer.cc
  #${DCMTK_SOURCES_DIR}/dcmdata/libsrc/mkdeftag.cc
  #${DCMTK_SOURCES_DIR}/dcmdata/libsrc/mkdictbi.cc
  ${DCMTK_SOURCES_DIR}/dcmdata/libsrc/vrscan.cc

  ${CMAKE_SOURCE_DIR}/Resources/dcmtk/vrscanl.c
  )

add_library(dcmtk
  ${DCMTK_SOURCES_OFSTD}
  ${DCMTK_SOURCES_DCMDATA}
  )


# Regenerate a dummy "library.c" file each time the "library.js" file
# is modified, so as to force a new execution of the linking
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/library.c"
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_CURRENT_BINARY_DIR}/library.c" ""
    DEPENDS "${CMAKE_SOURCE_DIR}/Sources/library.js")
  

add_executable(parser
  Sources/parser.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/library.c
  )

target_link_libraries(parser dcmtk)

install(TARGETS parser
  DESTINATION wasm-dicom-parser
  )

install(FILES
  ${CMAKE_SOURCE_DIR}/Sources/index.html
  ${CMAKE_SOURCE_DIR}/Sources/app.js
  ${CMAKE_CURRENT_BINARY_DIR}/parser.wasm
  DESTINATION wasm-dicom-parser
  )
