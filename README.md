Welcome to OpenGamma Lapack
=========

This is the OpenGamma-customised version of the industry-standard linear algebra
package version 3.4.2. OG-Lapack is a dependency of
[OG-Maths](https://github.com/OpenGamma/OG-Maths), and is included in
the builds that it produces.

Standard builds of OG-Lapack include versions compiled
for debug, x86_64, SSE4.1 and AVX instruction sets.

For the original LAPACK README, the see README file.

Using OG-Lapack
===============

OG-Lapack is only intended for use as part of the OG-Maths library. For further
information on the OG-Maths library, see [The OG-Maths
homepage](https://github.com/OpenGamma/OG-Maths).

For information on building OG-Lapack from source, see the INSTALL.md file.

## License

The OG-Lapack library is open source software using the New BSD license. The
company behind OG-Maths ([OpenGamma](http://www.opengamma.com)) also offers
support and some additional commercial components. (The commercial components
typically have dependencies with restrictive licensing incompatible with open
source.) This README only refers to the open source components.

-------------------------------------------------------------------------------

This distribution of LAPACK contains a modified version of xerbla.f
Copyright (c) 2014 - present OpenGamma, Inc. and the OpenGamma group of
companies.
It is present in a file called xerbla.f90 located within the source
at ${ROOT}/BLAS/SRC/xerbla.f90

Internally, we refer to this function as "OG xerbla", however, due to the
number of references to this routine throughout LAPACK, we have not modified 
the name of the routine in this distribution.

The modifications we made to the XERBLA() subroutine in xerbla.f90 include:
 - The use of a XERBLA_HANDLE module (see file xerbla_handle.f90) to allow a
global state for deciding whether subroutine XERBLA() should call "STOP"
or not. See local modification note in the source.
 - The source now compiles under (though does not comply with) Fortran 90
standards.

-------------------------------------------------------------------------------

**NOTE: All commits prior to SHA XXXX are missing one or more license notations,
details of the licenses which apply to these prior versions can be found in the
most current version of [LICENSE.txt](LICENSE.txt).**

Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of
companies.
