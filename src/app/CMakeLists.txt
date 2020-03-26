# Example CMake project that uses CPackDebHelper.
# Written by Alexander Bruines <alexander.bruines _at_ gmail.com>
# This file is public domain.

add_executable(myapp test.cpp)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/myapp DESTINATION bin)

