//
// Copyright (C) 2013 - present by OpenGamma Inc. and the OpenGamma group of companies
//
// Please see distribution for license.
//

#include <unistd.h>
#include <stddef.h>

#ifndef PYTHON_EXECUTABLE
#error "Need to set python executable with -DPYTHON_EXECUTABLE"
#else
#define Q(x) #x
#define QUOTE(x) Q(x)
#define PYTHON QUOTE(PYTHON_EXECUTABLE)
#endif

int main(int argc, char *argv[])
{
  char* python_argv[6] = { PYTHON, "lapack_testing.py", "-s", "-d", "TESTING", NULL };
  execv(PYTHON, python_argv);
}
