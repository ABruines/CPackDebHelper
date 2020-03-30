# CPackDebHelper - Use debhelper with the CPack DEB generator.
# Written by Alexander Bruines <alexander.bruines _at_ gmail.com>

# The BSD-3-clause licence
#
# Copyright (c) 2020 Alexander Bruines
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Locate required programs
find_program(FAKEROOT fakeroot)
if(NOT FAKEROOT)
  message("WARNING: fakeroot not found, please install fakeroot")
endif()
find_program(DH_PREP dh_prep)
if(NOT DH_PREP)
  message("WARNING: dh_prep not found, please install debhelper (>= 11)")
endif()
if(NOT FAKEROOT OR NOT DH_PREP)
  if(CPACK_DEBHELPER_FATALITY)
    message(FATAL_ERROR "Unable to create DEB package(s) with CPackDebHelper.")
  else()
    message("WARNING: Unable to create DEB package(s) with CPackDebHelper.")
    # Signal the fatality instead
    set(CPACK_DEBHELPER_FATALITY TRUE)
  endif()
else()

# Its okey to run debhelper
set(CPACK_DEBHELPER_FATALITY FALSE)

# Make sure that CPACK_DEBIAN_PACKAGE_NAME has a value.
if(NOT CPACK_PACKAGE_NAME)
  set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
  message(STATUS "Using default CPACK_PACKAGE_NAME (${CPACK_PACKAGE_NAME})")
endif()

# Make sure that CPACK_DEBIAN_PACKAGE_NAME has a value.
if(NOT CPACK_DEBIAN_PACKAGE_NAME)
  string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_DEBIAN_PACKAGE_NAME)
endif()

# Make sure that the CPACK_PACKAGE_DIRECTORY is set (to its default location)
if(NOT CPACK_PACKAGE_DIRECTORY)
  set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

# Make sure that the compatability level has been set.
if(NOT CPACK_DEBHELPER_COMPAT)
  set(CPACK_DEBHELPER_COMPAT "12")
endif()

# Set a default list of debhelpers to run if CPACK_DEBHELPER_RUN is empty.
if(NOT CPACK_DEBHELPER_RUN)
  set(CPACK_DEBHELPER_RUN
    dh_install dh_installdirs dh_installcron dh_installchangelogs
    dh_installdocs dh_installinfo dh_installinit dh_installman dh_installmenu
    dh_installmodules dh_installsystemd dh_installudev
    dh_usrlocal dh_dwz dh_compress dh_fixperms)
endif()

# Set the default for dh_makeshlibs CPACK_DEBHELPER_MAKESHLIBS (OFF)
if(NOT DEFINED CPACK_DEBHELPER_MAKESHLIBS)
  set(CPACK_DEBHELPER_MAKESHLIBS OFF)
endif()

# Set the default for CPACK_DEBHELPER_SHLIBDEPS (ON)
if(NOT CPACK_DEBHELPER_SHLIBDEPS)
  if(NOT DEFINED CPACK_DEBIAN_PACKAGE_SHLIBDEPS)
    set(CPACK_DEBHELPER_SHLIBDEPS ON)
  else()
    set(CPACK_DEBHELPER_SHLIBDEPS ${CPACK_DEBIAN_PACKAGE_SHLIBDEPS})
  endif()
endif()

# Set the default for CPACK_DEBHELPER_GENCONTROL
if(NOT CPACK_DEBHELPER_GENCONTROL)
  set(CPACK_DEBHELPER_GENCONTROL ON)
endif()

# Generate required files (note the extra newline after 'Source:' !)
message(STATUS "Generating debian/compat")
file(WRITE ${CPACK_PACKAGE_DIRECTORY}/debian/compat ${CPACK_DEBHELPER_COMPAT})
# The control file may be overridden from CPACK_DEBHELPER_INPUT
file(WRITE ${CPACK_PACKAGE_DIRECTORY}/debian/control "\
Maintainer: ${CPACK_DEBIAN_PACKAGE_MAINTAINER}
Source: ${CPACK_DEBIAN_PACKAGE_NAME}\n
Package: ${CPACK_DEBIAN_PACKAGE_NAME}
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Pre-Depends: \${misc:Pre-Depends}
Description: ${CPACK_DEBIAN_PACKAGE_DESCRIPTION}
")

# Generate the debhelper input from the .in files in CPACK_DEBHELPER_INPUT.
foreach(dh_input_file ${CPACK_DEBHELPER_INPUT})
  string(REGEX REPLACE ".in$" "" dh_output_file ${dh_input_file})
  message(STATUS "Generating debian/${dh_output_file}")
  configure_file(
    ${CPACK_DEBHELPER_INPUT_DIR}/${dh_input_file}
    ${CPACK_PACKAGE_DIRECTORY}/debian/${dh_output_file} @ONLY)
endforeach() 

# Set the configuration script to run when CPack is executed.
set(CPACK_PROJECT_CONFIG_FILE
  ${CMAKE_CURRENT_LIST_DIR}/CPackDebHelperConfig.cmake)

# Set the install script to run when the DEB generator is executed.
# (CPACK_INSTALL_SCRIPT is set to this value in CPackDebHelperConfig.)
set(CPACK_DEBIAN_INSTALL_SCRIPT
  ${CMAKE_CURRENT_LIST_DIR}/CPackDebHelperInstall.cmake)

endif()

# Enable the DEB generator.
set(CPACK_GENERATOR ${CPACK_GENERATOR} "DEB")

