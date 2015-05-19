set(CMAKE_CXX_COMPILER /usr/local/bin/g++-4.8.2)

# Appends the cmake/modules path inside the MAKE_MODULE_PATH variable which stores the
# directories of additional CMake modules (eg MacroOutOfSourceBuild.cmake):
set(CMAKE_MODULE_PATH $ENV{HOME}/code/cmake/modules ${CMAKE_MODULE_PATH})

SET(BUILD_OUTPUT_DIR "." CACHE STRING "The output directory of the build")
SET(PROJECT_BRANCH "master" CACHE STRING "The output directory of the build")

# The macro below forces the build directory to be different from source directory:
include(MacroOutOfSourceBuild)
macro_ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build.")

# Deduces the build type from the build directory name
#GET_FILENAME_COMPONENT(CURRENT_DIR ${CMAKE_BINARY_DIR} NAME)
#STRING(TOLOWER ${CURRENT_DIR} CURRENT_DIR)
#if(${CURRENT_DIR} STREQUAL "debug")
#  set(CMAKE_BUILD_TYPE "Debug")
#elseif(${CURRENT_DIR} STREQUAL "release")
#  set(CMAKE_BUILD_TYPE "Release")
#else()
#  message(FATAL_ERROR "Don't know how do a ${CURRENT_DIR} build")
#endif()

message(STATUS "Generating \"${CMAKE_BUILD_TYPE}\" Makefile")

# 
if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDEBUG")
else (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DSPEEDY")
endif(${CMAKE_BUILD_TYPE} STREQUAL "Debug")

# Compiler options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -MMD -MP -DVPL_PLATFORM_LINUX") #-Wall -Wextra -Werror")

# Make lists with the files to use for building
file(GLOB_RECURSE ${PROJECT_NAME}_HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.h)
file(GLOB_RECURSE ${PROJECT_NAME}_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.cpp)

# Include src by default
include_directories(BEFORE src)

# 
link_directories(/usr/local/lib)

# Install options
set(CMAKE_BINARY_DIR $ENV{HOME}/deploy/${PROJECT_BRANCH}/${CMAKE_BUILD_TYPE}/bin)
set(CMAKE_LIBRARY_DIR $ENV{HOME}/deploy/${PROJECT_BRANCH}/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_HEADERS_DIR $ENV{HOME}/deploy/${PROJECT_BRANCH}/${CMAKE_BUILD_TYPE}/include)

# Do not hard-code RPATH in binary upon installing
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
