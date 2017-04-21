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


macro(GetUrlFilename TargetVariable Url)
  string(REGEX REPLACE "^.*/" "" ${TargetVariable} "${Url}")
endmacro()


macro(GetUrlExtension TargetVariable Url)
  #string(REGEX REPLACE "^.*/[^.]*\\." "" TMP "${Url}")
  string(REGEX REPLACE "^.*\\." "" TMP "${Url}")
  string(TOLOWER "${TMP}" "${TargetVariable}")
endmacro()



##
## Check the existence of the required decompression tools
##

if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
  find_program(ZIP_EXECUTABLE 7z 
    PATHS 
    "$ENV{ProgramFiles}/7-Zip"
    "$ENV{ProgramW6432}/7-Zip"
    )

  if (${ZIP_EXECUTABLE} MATCHES "ZIP_EXECUTABLE-NOTFOUND")
    message(FATAL_ERROR "Please install the '7-zip' software (http://www.7-zip.org/)")
  endif()

else()
  find_program(UNZIP_EXECUTABLE unzip)
  if (${UNZIP_EXECUTABLE} MATCHES "UNZIP_EXECUTABLE-NOTFOUND")
    message(FATAL_ERROR "Please install the 'unzip' package")
  endif()

  find_program(TAR_EXECUTABLE tar)
  if (${TAR_EXECUTABLE} MATCHES "TAR_EXECUTABLE-NOTFOUND")
    message(FATAL_ERROR "Please install the 'tar' package")
  endif()
endif()


macro(DownloadPackage MD5 Url TargetDirectory)
  if (NOT IS_DIRECTORY "${TargetDirectory}")
    GetUrlFilename(TMP_FILENAME "${Url}")

    set(TMP_PATH "${CMAKE_SOURCE_DIR}/ThirdPartyDownloads/${TMP_FILENAME}")
    if (NOT EXISTS "${TMP_PATH}")
      message("Downloading ${Url}")

      file(DOWNLOAD "${Url}" "${TMP_PATH}" 
        SHOW_PROGRESS EXPECTED_MD5 "${MD5}"
        TIMEOUT 60 INACTIVITY_TIMEOUT 60)
    else()
      message("Using local copy of ${Url}")
    endif()

    GetUrlExtension(TMP_EXTENSION "${Url}")
    #message(${TMP_EXTENSION})
    message("Uncompressing ${TMP_FILENAME}")

    if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
      # How to silently extract files using 7-zip
      # http://superuser.com/questions/331148/7zip-command-line-extract-silently-quietly

      if (("${TMP_EXTENSION}" STREQUAL "gz") OR 
          ("${TMP_EXTENSION}" STREQUAL "tgz") OR
          ("${TMP_EXTENSION}" STREQUAL "xz"))
        execute_process(
          COMMAND ${ZIP_EXECUTABLE} e -y ${TMP_PATH}
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          OUTPUT_QUIET
          )

        if (Failure)
          message(FATAL_ERROR "Error while running the uncompression tool")
        endif()

        if ("${TMP_EXTENSION}" STREQUAL "tgz")
          string(REGEX REPLACE ".tgz$" ".tar" TMP_FILENAME2 "${TMP_FILENAME}")
        elseif ("${TMP_EXTENSION}" STREQUAL "gz")
          string(REGEX REPLACE ".gz$" "" TMP_FILENAME2 "${TMP_FILENAME}")
        elseif ("${TMP_EXTENSION}" STREQUAL "xz")
          string(REGEX REPLACE ".xz" "" TMP_FILENAME2 "${TMP_FILENAME}")
        endif()

        execute_process(
          COMMAND ${ZIP_EXECUTABLE} x -y ${TMP_FILENAME2}
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          OUTPUT_QUIET
          )
      elseif ("${TMP_EXTENSION}" STREQUAL "zip")
        execute_process(
          COMMAND ${ZIP_EXECUTABLE} x -y ${TMP_PATH}
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          OUTPUT_QUIET
          )
      else()
        message(FATAL_ERROR "Support your platform here")
      endif()

    else()
      if ("${TMP_EXTENSION}" STREQUAL "zip")
        execute_process(
          COMMAND sh -c "${UNZIP_EXECUTABLE} -q ${TMP_PATH}"
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
        )
      elseif (("${TMP_EXTENSION}" STREQUAL "gz") OR ("${TMP_EXTENSION}" STREQUAL "tgz"))
        #message("tar xvfz ${TMP_PATH}")
        execute_process(
          COMMAND sh -c "${TAR_EXECUTABLE} xfz ${TMP_PATH}"
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          )
      elseif ("${TMP_EXTENSION}" STREQUAL "bz2")
        execute_process(
          COMMAND sh -c "${TAR_EXECUTABLE} xfj ${TMP_PATH}"
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          )
      elseif ("${TMP_EXTENSION}" STREQUAL "xz")
        execute_process(
          COMMAND sh -c "${TAR_EXECUTABLE} xf ${TMP_PATH}"
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          RESULT_VARIABLE Failure
          )
      else()
        message(FATAL_ERROR "Unknown package format.")
      endif()
    endif()
   
    if (Failure)
      message(FATAL_ERROR "Error while running the uncompression tool")
    endif()

    if (NOT IS_DIRECTORY "${TargetDirectory}")
      message(FATAL_ERROR "The package was not uncompressed at the proper location. Check the CMake instructions.")
    endif()
  endif()
endmacro()
