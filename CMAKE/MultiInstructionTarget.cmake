#
# Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
#
# Please see distribution for license.
#

include(CMakeParseArguments)

include( CheckCPUID )
CheckCPUID()

# Create a library for multiple target instruction sets. Note that this is
# specialised to its use in Nyqwk2 and does not fully provide all of the
# functionality that can be provided by add_library and set_target_properties.
# One instance of the library is created for each of the TARGETS.

function(add_multitarget_library _TARGET_NAME)
  cmake_parse_arguments(MTLIB
                        ""
                        "VERSION;SOVERSION"
                        "SOURCES;TARGETS;LINK_MULTILIBRARIES;LINK_LIBRARIES;COMPILE_DEFINITIONS;MULTI_DEPENDS"
                        ${ARGN})
  foreach(TARGET ${MTLIB_TARGETS})
    set(LIBNAME ${_TARGET_NAME}_${TARGET})
    add_library(${LIBNAME} SHARED ${MTLIB_SOURCES})
    set_target_properties(${LIBNAME} PROPERTIES
                          VERSION ${MTLIB_VERSION}
                          SOVERSION ${MTLIB_SOVERSION}
                          COMPILE_FLAGS ${OPT_FLAGS_${TARGET}})
    foreach(LINK_LIB ${MTLIB_LINK_MULTILIBRARIES})
      target_link_libraries(${LIBNAME} ${LINK_LIB}_${TARGET})
    endforeach()
    foreach(LINK_LIB ${MTLIB_LINK_LIBRARIES})
      target_link_libraries(${LIBNAME} ${LINK_LIB})
    endforeach()
    foreach(COMPILE_DEFINITION ${MTLIB_COMPILE_DEFINITIONS})
      set_target_properties(${LIBNAME} PROPERTIES COMPILE_DEFINITIONS ${COMPILE_DEFINITION})
    endforeach()
    foreach(DEPENDENCY ${MTLIB_MULTI_DEPENDS})
      add_dependencies(${LIBNAME} ${DEPENDENCY}_${TARGET})
    endforeach()   
  endforeach()
endfunction()

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
    add_executable(${BINNAME} ${MTBIN_SOURCES})
    set_target_properties(${BINNAME} PROPERTIES
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

