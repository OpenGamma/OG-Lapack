#
# Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
#
# Please see distribution for license.
#

# Inclusion of this module sets the targets supported by the machine on which
# CMake is running. SUPPORT_${TARGET} is set to TRUE or FALSE for each target in
# dbg, std, sse41, sse42, avx1 and avx2. std and sbg require no special CPU
# support and are always set.

# this module caches the fact it has run by setting CPUID_CACHED = TRUE

macro( CheckCPUID )
  if(NOT (CPUID_CACHED EQUAL TRUE))
    set(VARIABLE CPUID_CACHED CACHE INTERNAL TRUE)
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
  endif()
endmacro()