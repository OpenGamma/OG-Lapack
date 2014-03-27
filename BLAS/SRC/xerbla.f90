! -----------------------------------------------------------------------------
! This distribution of LAPACK contains a modified version of xerbla.f
! Copyright (c) 2014 - present OpenGamma, Inc. and the OpenGamma group of
! companies.
! It is present in a file called xerbla.f90 located within the source
! at ${ROOT}/BLAS/SRC/xerbla.f90
!
! Internally, we refer to this function as "OG xerbla", however, due to the
! number of references to this routine throughout LAPACK, we have not modified
! the name of the routine in this distribution.
!
! The modifications we made to the XERBLA() subroutine in xerbla.f90 include:
!  - The use of a XERBLA_HANDLE module (see file xerbla_handle.f90) to allow a
! global state for deciding whether subroutine XERBLA() should call "STOP"
! or not. See local modification note in the source below.
!  - The source now compiles under (though does not comply with) Fortran 90
! standards.
! -----------------------------------------------------------------------------

!> \brief \b XERBLA
!
!  =========== DOCUMENTATION ===========
!
! Online html documentation available at 
!            http://www.netlib.org/lapack/explore-html/ 
!
!  Definition:
!  ===========
!
!       SUBROUTINE XERBLA( SRNAME, INFO )
! 
!       .. Scalar Arguments ..
!       CHARACTER*(*)      SRNAME
!       INTEGER            INFO
!       ..
!  
!
!> \par Purpose:
!  =============
!>
!> \verbatim
!>
!> XERBLA  is an error handler for the LAPACK routines.
!> It is called by an LAPACK routine if an input parameter has an
!> invalid value.  A message is printed and execution stops.
!>
!> Installers may consider modifying the STOP statement in order to
!> call system-specific exception-handling facilities.
!> \endverbatim
!
!  Arguments:
!  ==========
!
!> \param[in] SRNAME
!> \verbatim
!>          SRNAME is CHARACTER*(*)
!>          The name of the routine which called XERBLA.
!> \endverbatim
!>
!> \param[in] INFO
!> \verbatim
!>          INFO is INTEGER
!>          The position of the invalid parameter in the parameter list
!>          of the calling routine.
!> \endverbatim
!
!  Authors:
!  ========
!
!> \author Univ. of Tennessee 
!> \author Univ. of California Berkeley 
!> \author Univ. of Colorado Denver 
!> \author NAG Ltd. 
!
!> \date November 2011
!
!> \ingroup aux_blas
!
!  =====================================================================
      SUBROUTINE XERBLA( SRNAME, INFO )
      USE XERBLA_HANDLE, ONLY: GET_XERBLA_DEATH_SWITCH, SET_XERBLA_DEATH_SWITCH
!
!  -- Reference BLAS level1 routine (version 3.4.0) --
!  -- Reference BLAS is a software package provided by Univ. of Tennessee,    --
!  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
!     November 2011
!
!     .. Scalar Arguments ..
      CHARACTER*(*)      SRNAME
      INTEGER            INFO
!     ..
!
! =====================================================================
!
!     .. Intrinsic Functions ..
      INTRINSIC          LEN_TRIM
!     ..
!     .. Executable Statements ..
!
      print*,"IN XERBLA FROM SRC/LAPACK"
      WRITE( *, FMT = 9999 )SRNAME( 1:LEN_TRIM( SRNAME ) ), INFO
!
! Local modification, stop is only called if xerbla death switch is non-zero
!
! Copyright (C) 2014 - present by OpenGamma Inc. and the OpenGamma group of companies
!
! Please see distribution for licence.
!
      IF(GET_XERBLA_DEATH_SWITCH()/=0)THEN
        STOP
      ENDIF
! End local modification.

!
 9999 FORMAT( ' ** On entry to ', A, ' parameter number ', I2, ' had ',&
           'an illegal value' )
!
!     End of XERBLA
!
      END
