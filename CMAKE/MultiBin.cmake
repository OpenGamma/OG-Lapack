#
# Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
#
# Please see distribution for license.
#

# Inclusion of this module sets the targets supported by the machine on which
# CMake is running. SUPPORT_${TARGET} is set to TRUE or FALSE for each target in
# dbg, std, sse41, sse42, avx1 and avx2. std and sbg require no special CPU
# support and are always set.

include(CMakeParseArguments)

# Create a binary for multiple target instruction sets. Note that this is
# specialised to its use in Nyqwk2 and does not fully provide all of the
# functionality that can be provided by add_library and set_target_properties.
# One instance of the library is created for each of the TARGETS.

function(add_multitarget_binary _TARGET_NAME)
  cmake_parse_arguments(MTBIN
                        ""
                        "VERSION;SOVERSION"
                        "SOURCES;TARGETS;LINK_MULTILIBRARIES;LINK_LIBRARIES;COMPILE_DEFINITIONS;MULTI_DEPENDS"
                        ${ARGN})
  foreach(TARGET ${MTBIN_TARGETS})
    set(BINNAME ${_TARGET_NAME}_${TARGET})
    add_library(${BINNAME} SHARED ${MTBIN_SOURCES})
    set_target_properties(${BINNAME} PROPERTIES
                          VERSION ${MTBIN_VERSION}
                          SOVERSION ${MTBIN_SOVERSION}
                          COMPILE_FLAGS ${OPT_FLAGS_${TARGET}})
    foreach(LINK_LIB ${MTBIN_LINK_MULTILIBRARIES})
      target_link_libraries(${BINNAME} ${LINK_LIB}_${TARGET})
    endforeach()
    foreach(LINK_LIB ${MTBIN_LINK_LIBRARIES})
      target_link_libraries(${BINNAME} ${LINK_LIB})
    endforeach()
    foreach(COMPILE_DEFINITION ${MTBIN_COMPILE_DEFINITIONS})
      set_target_properties(${BINNAME} PROPERTIES COMPILE_DEFINITIONS ${COMPILE_DEFINITION})
    endforeach()
    foreach(DEPENDENCY ${MTBIN_MULTI_DEPENDS})
      add_dependencies(${BINNAME} ${DEPENDENCY}_${TARGET})
    endforeach()   
  endforeach()
endfunction()

try_run(CPUID_FLAG CPUID_COMPILE_RESULT
        ${CMAKE_BINARY_DIR}
        ${CMAKE_SOURCE_DIR}/CMAKE/cmcpuid.c)

set(SUPPORT_dbg TRUE)
set(SUPPORT_std TRUE)

# NOTE: These flags must match the numbers in cmcpuid.c
if(${CPUID_FLAG} GREATER 1)
  set(SUPPORT_sse41 TRUE)
  message(STATUS "CPU supports SSE4.1")
else()
  message(STATUS "CPU does not support SSE4.1")
endif()
if(${CPUID_FLAG} GREATER 2)
  set(SUPPORT_sse42 TRUE)
  message(STATUS "CPU supports SSE4.2")
else()
  message(STATUS "CPU does not support SSE4.2")
endif()
if(${CPUID_FLAG} GREATER 3)
  set(SUPPORT_avx1 TRUE)
  message(STATUS "CPU supports AVX1")
else()
  message(STATUS "CPU does not support AVX1")
endif()
if(${CPUID_FLAG} GREATER 4)
  set(SUPPORT_avx2 TRUE)
  message(STATUS "CPU supports AVX2")
else()
  message(STATUS "CPU does not support AVX2")
endif()

