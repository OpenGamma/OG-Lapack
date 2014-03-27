#
# Portions Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
#
# Please see distribution for license.
#

add_subdirectory(SRC)
if(BUILD_TESTING)
add_subdirectory(TESTING)
endif(BUILD_TESTING)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/blas.pc.in ${CMAKE_CURRENT_BINARY_DIR}/blas.pc)
