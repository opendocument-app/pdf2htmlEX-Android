# EPTarball.cmake
#
# pdf2htmlEX-Android (https://github.com/ViliusSutkus89/pdf2htmlEX-Android)
# Android port of pdf2htmlEX - Convert PDF to HTML without losing text or format.
#
# Copyright (c) 2019 - 2021 Vilius Sutkus <ViliusSutkus89@gmail.com>
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

function(ExternalProjectTarball EXTERNAL_PROJECT_NAME)
  ExternalProjectHeaderBoilerplate(${ARGN})

  ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    ${EP_DEPENDS}

    URL ${EP_URL}
    URL_HASH ${EP_URL_HASH}

    BUILD_IN_SOURCE 1

    CONFIGURE_COMMAND /bin/true
    BUILD_COMMAND /bin/true
    INSTALL_COMMAND /bin/true

    ${EP_PATCH_SOURCE_COMMAND}
    ${EP_PATCH_INSTALL_COMMAND}

    LOG_DOWNLOAD 1
    LOG_INSTALL 1
  )
endfunction(ExternalProjectTarball)

