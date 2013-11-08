#
# Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
#
# Please see distribution for license.
#

cmake_minimum_required (VERSION 2.8.6)

include(CMakeForceCompiler)

if(APPLE OR WIN32)
  # On Apple, we don't want to use Clang.
  # On Windows, we don't want to end up building with Visual Studio.
  CMAKE_FORCE_C_COMPILER(gcc GNU)
endif(APPLE OR WIN32)

project (LAPACK)

set(LAPACK_VERSION_MAJOR 3)
set(LAPACK_VERSION_MINOR 4)
set(LAPACK_VERSION_PATCH 2)
set(LAPACK_VERSION ${LAPACK_VERSION_MAJOR}.${LAPACK_VERSION_MINOR}.${LAPACK_VERSION_PATCH})

# Append local module folder to module path
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMAKE ${CMAKE_MODULE_PATH})

# languages
enable_language(Fortran)
enable_language(C)

# use flat namespace
if(APPLE)
  set(CMAKE_Fortran_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
  set(CMAKE_Fortran_OSX_CURRENT_VERSION_FLAG "-current_version ")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wl,-flat_namespace")
endif(APPLE)

# Get Python
find_package(PythonInterp)
message(STATUS "Looking for Python found - ${PYTHONINTERP_FOUND}")
if (PYTHONINTERP_FOUND)
   message(STATUS "Using Python version ${PYTHON_VERSION_STRING}")
endif()

if(WIN32)
  set(CMAKE_THREAD_LIBS_INIT -mthreads)
else()
  # we force -pthread in preference to -lpthread because it sets -D_REENTRANT
  set(THREADS_HAVE_PTHREAD_ARG "THREADS_HAVE_PTHREAD_ARG")
  find_package(Threads)
endif()

# Add thread libs
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_THREAD_LIBS_INIT}")
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_THREAD_LIBS_INIT}")

# Use the native assembler on Apple in order to be able to generate AVX instructions.
if(APPLE)
  set(CMAKE_C_FLAGS "-Wa,-q ${CMAKE_C_FLAGS}")
  set(CMAKE_Fortran_FLAGS "-Wa,-q ${CMAKE_C_FLAGS}")
endif()

# fix rpath
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--rpath -Wl,\$ORIGIN")
endif()


# Place executables and libraries in bin on Windows so that its linker can find them.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LAPACK_BINARY_DIR}/bin)

enable_testing()

# Check for any necessary platform specific compiler flags
# this is from the original LAPACK cmake build, in our case makes sure 
# FPE traps aren't on by accident or intent!
include( CheckLAPACKCompilerFlags )
CheckLAPACKCompilerFlags()

# Multi-target libraries need to be built
include(MultiLib)
# Multi-target binaries need to be built
include(MultiBin)
set(TARGET_TYPES dbg std sse41 avx1)


set(OPT_FLAGS_dbg "-DDEBUG ${CMAKE_C_FLAGS_DEBUG}")
set(OPT_FLAGS_std "-O2 -funroll-loops -DNDEBUG")
set(OPT_FLAGS_sse41 "${OPT_FLAGS_std} -march=core2 -msse4.1")
set(OPT_FLAGS_avx1 "${OPT_FLAGS_std}  -march=corei7-avx -mavx256-split-unaligned-load -mavx256-split-unaligned-store")

# make calls to existing cmake to pickup BLAS
message(STATUS "Using NETLIB BLAS implementation")
add_subdirectory(BLAS)
set( BLAS_LIBRARIES ogblas )

# make calls to existing cmake to pick build support config
message(STATUS "Using NETLIB LAPACK implementation")
set( LAPACK_LIBRARIES oglapack )
set(BUILD_SINGLE    TRUE)
set(BUILD_DOUBLE    TRUE)
set(BUILD_COMPLEX   TRUE)
set(BUILD_COMPLEX16 TRUE)
add_subdirectory(SRC)


# Check second function
include(CheckTimeFunction)
set(TIME_FUNC NONE ${TIME_FUNC})
CHECK_TIME_FUNCTION(NONE TIME_FUNC)
CHECK_TIME_FUNCTION(INT_CPU_TIME TIME_FUNC)
CHECK_TIME_FUNCTION(EXT_ETIME TIME_FUNC)
CHECK_TIME_FUNCTION(EXT_ETIME_ TIME_FUNC)
CHECK_TIME_FUNCTION(INT_ETIME TIME_FUNC)
message(STATUS "--> Will use second_${TIME_FUNC}.f and dsecnd_${TIME_FUNC}.f as timing function.")

set(SECOND_SRC  ${LAPACK_SOURCE_DIR}/INSTALL/second_${TIME_FUNC}.f)
set(DSECOND_SRC  ${LAPACK_SOURCE_DIR}/INSTALL/dsecnd_${TIME_FUNC}.f)

add_subdirectory(TESTING)

# done
message("
  Package " ${CMAKE_PROJECT_NAME} " version " ${LAPACK_VERSION} "
  Prefix.....................: " ${CMAKE_INSTALL_PREFIX} "
  C Compiler.................: " ${CMAKE_C_COMPILER} "
  C Flags....................: " ${CMAKE_C_FLAGS} "
  Fortran Compiler...........: " ${CMAKE_Fortran_COMPILER} "
  Fortran Compiler...........: " ${CMAKE_Fortran_FLAGS} "
  Threads flag..............:: " ${CMAKE_THREAD_LIBS_INIT} "
  Python executable..........: " ${PYTHON_EXECUTABLE} "
  ")