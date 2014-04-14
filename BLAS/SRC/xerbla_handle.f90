!
! Copyright (C) 2014 - present by OpenGamma Inc. and the OpenGamma group of companies
!
! Please see distribution for licence.
!

! This module is for use in the specification of the behaviour of XERBLA.
MODULE XERBLA_HANDLE
USE ISO_C_BINDING
IMPLICIT NONE

! This module global int is used to specify and determine the behaviour of XERBLA
! if it is set to 0 XERBLA will not call STOP
! if it is set to anything other than 0 STOP will be called by XERBLA
! Default value is 1. i.e. to call STOP.
INTEGER (c_int):: LAPACK__XERBLA__DEATH_SWITCH = 1

CONTAINS

! SET_XERBLA_DEATH_SWITCH sets the value of the XERBLA death variable
! @param NEWVALUE the value the XERBLA death switch variable will be set to
SUBROUTINE SET_XERBLA_DEATH_SWITCH(NEWVALUE) BIND(C, name="set_xerbla_death_switch")
  IMPLICIT NONE
  INTEGER(c_int), INTENT(IN):: NEWVALUE
  LAPACK__XERBLA__DEATH_SWITCH = NEWVALUE
END SUBROUTINE

! GET_XERBLA_DEATH_SWITCH gets the value of the XERBLA death variable
! @return the value the XERBLA death switch variable
FUNCTION GET_XERBLA_DEATH_SWITCH() BIND(C, name="get_xerbla_death_switch")
  IMPLICIT NONE
  INTEGER(c_int):: GET_XERBLA_DEATH_SWITCH
  GET_XERBLA_DEATH_SWITCH = LAPACK__XERBLA__DEATH_SWITCH
  RETURN
END FUNCTION

END MODULE XERBLA_HANDLE