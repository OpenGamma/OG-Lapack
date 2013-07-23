cmake_minimum_required(VERSION 2.8)
project(LAPACK Fortran)

enable_language(C)

if(APPLE)
  set(CMAKE_Fortran_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
  set(CMAKE_Fortran_OSX_CURRENT_VERSION_FLAG "-current_version ")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wl,-flat_namespace")
endif(APPLE)

set(LAPACK_VERSION_MAJOR 3)
set(LAPACK_VERSION_MINOR 4)
set(LAPACK_VERSION_PATCH 2)
set(LAPACK_VERSION ${LAPACK_VERSION_MAJOR}.${LAPACK_VERSION_MINOR}.${LAPACK_VERSION_PATCH})

# Add the CMake directory for custon CMake modules
set(CMAKE_MODULE_PATH "${LAPACK_SOURCE_DIR}/CMAKE" ${CMAKE_MODULE_PATH})

if (UNIX)
   if ( "${CMAKE_Fortran_COMPILER}" MATCHES "ifort" )
  set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fltconsistency -fp_port" )
   endif ()
   if ( "${CMAKE_Fortran_COMPILER}" MATCHES "xlf" )
  set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qnosave -qstrict=none" )
   endif ()
# Delete libmtsk in linking sequence for Sun/Oracle Fortran Compiler.
# This library is not present in the Sun package SolarisStudio12.3-linux-x86-bin
   STRING(REPLACE \;mtsk\; \; CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES "${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES}")
endif ()

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--rpath -Wl,\$ORIGIN")
endif()

# Get Python
find_package(PythonInterp)
message(STATUS "Looking for Python found - ${PYTHONINTERP_FOUND}")
if (PYTHONINTERP_FOUND)
   message(STATUS "Using Python version ${PYTHON_VERSION_STRING}")
endif()
# --------------------------------------------------

# Configure the warning and code coverage suppression file
configure_file(
  "${LAPACK_SOURCE_DIR}/CTestCustom.cmake.in"
  "${LAPACK_BINARY_DIR}/CTestCustom.cmake"
  @ONLY
)

# On Windows-GNU builds try to provide MS import libraries too.
include(GNUtoMS)

if(GNUtoMS)
  set(LAPACK_GNUtoMS_IMPORT ${LAPACK_SOURCE_DIR}/CMAKE/lapack-GNUtoMS.cmake)
  set(LAPACK_GNUtoMS_INSTALL "include(\${_SELF_DIR}/lapack-GNUtoMS.cmake)")
  set(LAPACK_GNUtoMS_BUILD "include(\"${LAPACK_GNUtoMS_IMPORT}\")")
endif()

macro(lapack_install_library lib)
  install(TARGETS ${lib} EXPORT lapack-targets
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    RUNTIME DESTINATION bin
  )
  if(GNUtoMS)
    install(FILES ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/lib${lib}.lib DESTINATION lib)
  endif()
endmacro()

# --------------------------------------------------
# Testing

enable_testing()
include(CTest)
enable_testing()
# --------------------------------------------------

# Organize output files.  On Windows this also keeps .dll files next
# to the .exe files that need them, making tests easy to run.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LAPACK_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LAPACK_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LAPACK_BINARY_DIR}/lib)

# --------------------------------------------------
# Check for any necessary platform specific compiler flags
include( CheckLAPACKCompilerFlags )
CheckLAPACKCompilerFlags()

# --------------------------------------------------
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
set(prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})
set(PKG_CONFIG_DIR lib/pkgconfig)

message(STATUS "Using supplied NETLIB BLAS implementation")
add_subdirectory(BLAS)
set( BLAS_LIBRARIES ogblas )

message(STATUS "Using supplied NETLIB LAPACK implementation")
set( LAPACK_LIBRARIES oglapack )
set(BUILD_SINGLE    TRUE)
set(BUILD_DOUBLE    TRUE)
set(BUILD_COMPLEX   TRUE)
set(BUILD_COMPLEX16 TRUE)
add_subdirectory(SRC)

add_subdirectory(TESTING)

# --------------------------------------------------
# CPACK Packaging 

SET(CPACK_GENERATOR "TGZ" "DEB" "RPM" "NSIS" "PackageMaker")
SET(CPACK_PACKAGE_NAME "OG-Lapack")
SET(CPACK_PACKAGE_VENDOR "OpenGamma")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "LAPACK - Linear Algebra Package")
set(CPACK_PACKAGE_VERSION_MAJOR ${LAPACK_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${LAPACK_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${LAPACK_VERSION_PATCH})
set(CPACK_PACKAGE_CONTACT "Graham Markall <graham@opengamma.com>")

set(CPACK_DEBIAN_PACKAGE_NAME "og-lapack")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.3)")

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")

# There is a bug in NSI that does not handle full unix paths properly. Make
# sure there is at least one set of four (4) backlasshes.
SET(CPACK_NSIS_CONTACT "lapack@eecs.utk.edu")
SET(CPACK_NSIS_MODIFY_PATH ON)
SET(CPACK_NSIS_DISPLAY_NAME "LAPACK-${LAPACK_VERSION}")

INCLUDE(CPack)

set(ALL_TARGETS ${ALL_TARGETS} ogblas)
set(ALL_TARGETS ${ALL_TARGETS} oglapack)
set(ALL_TARGETS ${ALL_TARGETS} ogtmglib)
export(TARGETS ${ALL_TARGETS} FILE lapack-targets.cmake)

configure_file(${LAPACK_SOURCE_DIR}/CMAKE/lapack-config-version.cmake.in
  ${LAPACK_BINARY_DIR}/lapack-config-version.cmake @ONLY)
configure_file(${LAPACK_SOURCE_DIR}/CMAKE/lapack-config-build.cmake.in
  ${LAPACK_BINARY_DIR}/lapack-config.cmake @ONLY)


configure_file(${CMAKE_CURRENT_SOURCE_DIR}/lapack.pc.in ${CMAKE_CURRENT_BINARY_DIR}/lapack.pc)
  install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/lapack.pc
  DESTINATION ${PKG_CONFIG_DIR}
   )

configure_file(${LAPACK_SOURCE_DIR}/CMAKE/lapack-config-install.cmake.in
  ${LAPACK_BINARY_DIR}/CMakeFiles/lapack-config.cmake @ONLY)
install(FILES
  ${LAPACK_GNUtoMS_IMPORT}
  ${LAPACK_BINARY_DIR}/CMakeFiles/lapack-config.cmake
  ${LAPACK_BINARY_DIR}/lapack-config-version.cmake
  DESTINATION lib/cmake/lapack-${LAPACK_VERSION}
  )

install(EXPORT lapack-targets
  DESTINATION lib/cmake/lapack-${LAPACK_VERSION})
