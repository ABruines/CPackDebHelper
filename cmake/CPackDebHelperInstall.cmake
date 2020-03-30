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

# Verbose mode?

unset(dh_verbose)
if(CPACK_DEBHELPER_VERBOSE)
  set(dh_verbose "-v")
endif()

# Copy extra files

foreach(file ${CPACK_DEBHELPER_INPUT_EXTRA})
  file(COPY ${file} DESTINATION ${CPACK_OUTPUT_FILE_PREFIX}/debian)
endforeach()

# Always run dh_prep
message("CPackDebHelper: Running dh_prep")
execute_process(
  COMMAND fakeroot dh_prep ${dh_verbose}
  WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})

# Run the debhelpers in CPACK_DEBHELPER_RUN
foreach(debhelper ${CPACK_DEBHELPER_RUN})
  message("CPackDebHelper: Running ${debhelper}")
  execute_process(
    COMMAND fakeroot ${debhelper} ${dh_verbose}
    WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})
endforeach()

if(CPACK_DEBHELPER_MAKESHLIBS)
  message("CPackDebHelper: Running dh_makeshlibs")
  execute_process(
    COMMAND fakeroot dh_makeshlibs -P${CPACK_OUTPUT_FILE_PREFIX} ${dh_verbose}
    WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})
endif()

if(CPACK_DEBHELPER_SHLIBDEPS)
  message("CPackDebHelper: Running dh_shlibdeps")
  execute_process(
    COMMAND fakeroot dh_shlibdeps -P${CPACK_OUTPUT_FILE_PREFIX} -X${CPACK_OUTPUT_FILE_PREFIX}/CMakeFiles ${dh_verbose}
    WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})
endif()

if(CPACK_DEBHELPER_GENCONTROL)
  message("CPackDebHelper: Running dh_gencontrol")
  execute_process(
    COMMAND fakeroot dh_gencontrol ${dh_verbose}
    WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})
endif()

message("CPackDebHelper: Running dh_installdeb")
execute_process(
  COMMAND fakeroot dh_installdeb ${dh_verbose}
  WORKING_DIRECTORY ${CPACK_OUTPUT_FILE_PREFIX})

# Add the debhelper output to CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA

file(GLOB dh_output_files
  ${CPACK_OUTPUT_FILE_PREFIX}/debian/${CPACK_DEBIAN_PACKAGE_NAME}/DEBIAN/*)

set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
  ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}
  ${dh_output_files})

# Copy all other generated files installed onto the target filesystem to where
# the packaging will happen (excluding the DEBIAN directory).

file(COPY "${CPACK_OUTPUT_FILE_PREFIX}/debian/${CPACK_DEBIAN_PACKAGE_NAME}/"
  DESTINATION "${CMAKE_CURRENT_BINARY_DIR}" 
  PATTERN DEBIAN EXCLUDE)

