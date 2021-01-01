# EPFiletree.cmake
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2021 Vilius Sutkus <ViliusSutkus89@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

function(ExternalProjectFiletree EXTERNAL_PROJECT_NAME)
  SET(INSTALLED_CANARY "${THIRDPARTY_PREFIX}/${EXTERNAL_PROJECT_NAME}.installed")
  if (EXISTS ${INSTALLED_CANARY})
    if (NOT TARGET ${EXTERNAL_PROJECT_NAME})
      add_custom_target(${EXTERNAL_PROJECT_NAME} COMMAND /bin/true)
    endif()
    return()
  endif()

  FILE(GLOB_RECURSE filesToCopy LIST_DIRECTORIES false
    RELATIVE "${CMAKE_CURRENT_LIST_DIR}/${EXTERNAL_PROJECT_NAME}/"
    "${CMAKE_CURRENT_LIST_DIR}/${EXTERNAL_PROJECT_NAME}/*")

  foreach(fileToCopy ${filesToCopy})
    get_filename_component(dstDirectory ${fileToCopy} DIRECTORY)
    FILE(MAKE_DIRECTORY "${THIRDPARTY_PREFIX}/${dstDirectory}")
    FILE(COPY "${CMAKE_CURRENT_LIST_DIR}/${EXTERNAL_PROJECT_NAME}/${fileToCopy}" DESTINATION "${THIRDPARTY_PREFIX}/${dstDirectory}/")
  endforeach()

  FILE(WRITE ${INSTALLED_CANARY} 1)
  add_custom_target(${EXTERNAL_PROJECT_NAME} COMMAND /bin/true)
endfunction(ExternalProjectFiletree)

