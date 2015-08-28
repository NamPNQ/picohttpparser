#
#  Copyright (c) 2009-2014 Kazuho Oku, Tokuhiro Matsuno, Daisuke Murase,
#                          Shigeo Mitsunari
# 
#  The software is licensed under either the MIT License (below) or the Perl
#  license.
# 
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to
#  deal in the Software without restriction, including without limitation the
#  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#  sell copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
# 
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
#  IN THE SOFTWARE.
# 

when defined(_MSC_VER): 
  const 
    ssize_t* = intptr_t
# $Id$ 

# contains name and value of a header (name == NULL if is a continuing line
#  of a multiline header 

type 
  phr_header* = object 
    name*: cstring
    name_len*: csize
    value*: cstring
    value_len*: csize


# returns number of bytes consumed if successful, -2 if request is partial,
#  -1 if failed 

proc phr_parse_request*(buf: cstring; len: csize; `method`: cstringArray; 
                        method_len: ptr csize; path: cstringArray; 
                        path_len: ptr csize; minor_version: ptr cint; 
                        headers: ptr phr_header; num_headers: ptr csize; 
                        last_len: csize): cint
# ditto 

proc phr_parse_response*(_buf: cstring; len: csize; minor_version: ptr cint; 
                         status: ptr cint; msg: cstringArray; 
                         msg_len: ptr csize; headers: ptr phr_header; 
                         num_headers: ptr csize; last_len: csize): cint
# ditto 

proc phr_parse_headers*(buf: cstring; len: csize; headers: ptr phr_header; 
                        num_headers: ptr csize; last_len: csize): cint
# should be zero-filled before start 

type 
  phr_chunked_decoder* = object 
    bytes_left_in_chunk*: csize # number of bytes left in current chunk 
    consume_trailer*: char    # if trailing headers should be consumed 
    _hex_count*: char
    _state*: char


# the function rewrites the buffer given as (buf, bufsz) removing the chunked-
#  encoding headers.  When the function returns without an error, bufsz is
#  updated to the length of the decoded data available.  Applications should
#  repeatedly call the function while it returns -2 (incomplete) every time
#  supplying newly arrived data.  If the end of the chunked-encoded data is
#  found, the function returns a non-negative number indicating the number of
#  octets left undecoded at the tail of the supplied buffer.  Returns -1 on
#  error.
# 

proc phr_decode_chunked*(decoder: ptr phr_chunked_decoder; buf: cstring; 
                         bufsz: ptr csize): ssize_t