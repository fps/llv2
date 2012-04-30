
%module llilv

%{
#include <lilv.h>
%}

%apply unsigned int { uint32_t }
%apply unsigned long long { uint64_t }
%include <lilv.h>
