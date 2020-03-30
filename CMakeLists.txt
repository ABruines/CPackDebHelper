# Example CMake project that uses CPackDebHelper.
# Written by Alexander Bruines <alexander.bruines _at_ gmail.com>
# This file is public domain.

# Require at least CMake 3.13
# (Not actually confirmed, I have just set it to the CMake version in Debian Buster.)
cmake_minimum_required(VERSION 3.13)

# Prevent in-source builds
# (Not a requirement but its nice to keep the source-tree clean.)
if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR
    "\nIn-source builds are not allowed.\n"
    "Please make a new directory (called a build directory) and run CMake from there.\n"
    "You may want to remove ./CMakeCache.txt.\n")
endif()

# Set a name, version and description for the project.
project(
  CPackDebHelper
  VERSION 1.0
  DESCRIPTION "Example CMake project that uses CPackDebHelper."
  LANGUAGES CXX)

# Set a local module path.
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

#
# At this point the normal CMake build/install rules should be inserted.
#

add_subdirectory(src/app)

#
# The CPack configuration starts here:
#

# Example of CPack variables for the source-package-generator
set(CPACK_SOURCE_PACKAGE_FILE_NAME ${PROJECT_NAME}-${PROJECT_VERSION})
set(CPACK_SOURCE_GENERATOR TBZ2)
set(CPACK_SOURCE_IGNORE_FILES ${CMAKE_BINARY_DIR} .git .gitignore)

#
# Set CPack variables required for building a DEB package.
# These are the variables that must be set, you may want to set some other
# CPack variables to provide more information in your DEB package...
#
# See:
# https://cmake.org/cmake/help/v3.13/module/CPack.html#variables-common-to-all-cpack-generators
# https://cmake.org/cmake/help/v3.13/cpack_gen/deb.html#variables-specific-to-cpack-debian-deb-generator
#

# Required. Debian packages need a maintainer.
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "someone@out.there")

# Optional. Set to PROJECT_NAME by CPackDebHelper if left unset.
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})

# Optional. Set to lower-case CPACK_PACKAGE_NAME by CPackDebHelper if left unset.
string(TOLOWER ${CPACK_PACKAGE_NAME} CPACK_DEBIAN_PACKAGE_NAME)

# Optional. Set to CMAKE_BINARY_DIR by CPackDebHelper if left unset.
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR})

# Optional. The DEB package likes to know its target system architecture.
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)

# Optional. I just like this better than the CPack default
set(CPACK_DEBIAN_FILE_NAME
  ${PROJECT_NAME}-${PROJECT_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb)

# Optional. CPack produces a warning if CPACK_DEBIAN_PACKAGE_DEPENDS
# is also empty (ie. no dependencies are given at all).
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

#
# Set CPackDebHelper vars:
#

# Required. The directory that contains the files listed in CPACK_DEBHELPER_INPUT
set(CPACK_DEBHELPER_INPUT_DIR "${CMAKE_SOURCE_DIR}/src/debian")

# Required. List of input files that require processing by the debhelpers.
# All of these must have the '.in' extention because they are first processed
# by configure_file(). The package name must be lowercase here, if building a
# single DEB package the package name may be omitted.
set(CPACK_DEBHELPER_INPUT
  ${CPACK_DEBIAN_PACKAGE_NAME}.changelog.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.cron.d.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.init.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.postinst.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.postrm.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.service.in
  ${CPACK_DEBIAN_PACKAGE_NAME}.docs.in
)

# Optional. Extra files to copy into the debian directory before running debhelper
set(CPACK_DEBHELPER_INPUT_EXTRA
  ${CMAKE_SOURCE_DIR}/README.md
)

# Optional. Set the debhelper compatability level, if left unset CPackDebHelper
# sets this to 12.
unset(CPACK_DEBHELPER_COMPAT)

# Optional. List of debhelpers to run.
# If left unset the default list of debhelpers is executed.
#
# The default list (in order of execution):
#    dh_install dh_installdirs dh_installcron dh_installchangelogs
#    dh_installdocs dh_installinfo dh_installinit dh_installman dh_installmenu
#    dh_installmodules dh_installsystemd dh_installudev dh_makeshlibs
#    dh_usrlocal dh_dwz dh_compress dh_fixperms
#
# See their respective man pages on how to use each debhelper.
#
# Note: You must not list dh_prep or dh_installdeb here, they are always executed.
#
# Note: Running dh_shlibdeps has no effect here (use CPACK_DEBIAN_PACKAGE_SHLIBDEPS
#       instead). The same goes for dh_strip (use CPACK_STRIP_FILES instead).
#
unset(CPACK_DEBHELPER_RUN)

# Optional. Run the debhelpers in verbose mode? (BOOL)
# The default value is empty (no)
set(CPACK_DEBHELPER_VERBOSE OFF)

# Optional. Is not being able to run debhelper a fatality? (BOOL)
# The default value is empty (no), a warning will be printed but CMake
# will coninue.
set(CPACK_DEBHELPER_FATALITY OFF)

# Load the CPackDebHelper module, this will:
#
#   - Add "DEB" to the CPACK_GENERATOR variable.
#
#   - Parse the files in CPACK_DEBHELPER_INPUT with configure_file().
#
#   - Set the CPACK_DEBIAN_INSTALL_SCRIPT variable to
#     ${CMAKE_CURRENT_LIST_DIR}/CPackDebHelperInstall.cmake.
#
#   - Set CPACK_PROJECT_CONFIG_FILE variable to
#     ${CMAKE_CURRENT_LIST_DIR}/CPackDebHelperConfig.cmake.
#     (You may override this but if you do you must also set
#     CPACK_INSTALL_SCRIPT to CPACK_DEBIAN_INSTALL_SCRIPT
#     yourself when CPACK_PROJECT_CONFIG_FILE is executed.
#     This could be done by including CPackDebHelperConfig.cmake
#     from your CPACK_PROJECT_CONFIG_FILE script.)
#
# When the 'make package' command is executed CPackDebHelper will:
#
#   - Run the debhelpers specified in CPACK_DEBHELPER_RUN.
#
#   - Add the generated files in the 'debian' directory to
#     CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA.
#
#   - Copy all other files generated by debhelper to the packaging area.
#
include(CPackDebHelper)

# If CPACK_DEBHELPER_FATALITY is true at this point a DEB package
# may still be built but will not contain any debhelper generated files.

#[[
if(CPACK_DEBHELPER_FATALITY)
  message("Able to run debhelpers: no")
else()
  message("Able to run debhelpers: yes")
endif()
#]]

# Finally load the CPack module
include(CPack)

# Add a 'dist' alias for the package_source target for those who are
# more familiar with autotools.
add_custom_target(dist COMMAND +make package_source)

# Add another alias to build the DEB package, just for convenience.
add_custom_target(deb COMMAND +make package)

