set(CMAKE_CXX_COMPILER g++)

# Appends the cmake/modules path inside the MAKE_MODULE_PATH variable which stores the
# directories of additional CMake modules (eg MacroOutOfSourceBuild.cmake):
set(CMAKE_MODULE_PATH $ENV{HOME}/code/cmake/modules ${CMAKE_MODULE_PATH})


# The macro below forces the build directory to be different from source directory:
include(MacroOutOfSourceBuild)
macro_ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build.")

# Deduces the build type from the build directory name
GET_FILENAME_COMPONENT(CURRENT_DIR ${CMAKE_BINARY_DIR} NAME)
STRING(TOLOWER ${CURRENT_DIR} CURRENT_DIR)
if(${CURRENT_DIR} STREQUAL "debug")
  set(CMAKE_BUILD_TYPE "Debug")
elseif(${CURRENT_DIR} STREQUAL "release")
  set(CMAKE_BUILD_TYPE "Release")
else()
  message(FATAL_ERROR "Don't know how do a ${CURRENT_DIR} build")
endif()

message(STATUS "Generating \"${CMAKE_BUILD_TYPE}\" Makefile")

