unit LZ4Lib;

(*
 *  LZ4 - Fast LZ compression algorithm
 *  Header File
 *  Copyright (C) 2011-2017, Yann Collet.

   BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

       * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer
   in the documentation and/or other materials provided with the
   distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   You can contact the author at :
    - LZ4 homepage : http://www.lz4.org
    - LZ4 source repository : https://github.com/lz4/lz4
*)

(**
  Introduction

  LZ4 is lossless compression algorithm, providing compression speed at 500 MB/s per core,
  scalable with multi-cores CPU. It features an extremely fast decoder, with speed in
  multiple GB/s per core, typically reaching RAM speed limits on multi-core systems.

  The LZ4 compression library provides in-memory compression and decompression functions.
  Compression can be done in:
    - a single step (described as Simple Functions)
    - a single step, reusing a context (described in Advanced Functions)
    - unbounded multiple steps (described as Streaming compression)

  lz4.h provides block compression functions. It gives full buffer control to user.
  Decompressing an lz4-compressed block also requires metadata (such as compressed size).
  Each application is free to encode such metadata in whichever way it wants.

  An additional format, called LZ4 frame specification (doc/lz4_Frame_format.md),
  take care of encoding standard metadata alongside LZ4-compressed blocks.
  Frame format is required for interoperability.
  It is delivered through a companion API, declared in lz4frame.h.
*)

{ $DEFINE STATIC_LINKING}

interface

uses
  Windows, SysUtils;

{$Z4}

{$IFDEF STATIC_LINKING}
const
  LZ4DllName = 'liblz4.dll';
{$ELSE}
var
  LZ4DllName: UnicodeString;
{$ENDIF}

const
  sLZ4_versionNumber = 'LZ4_versionNumber';
  sLZ4_versionString = 'LZ4_versionString';
  sLZ4_compress_default = 'LZ4_compress_default';
  sLZ4_decompress_safe = 'LZ4_decompress_safe';

  sLZ4_compressBound = 'LZ4_compressBound';
  sLZ4_compress_fast = 'LZ4_compress_fast';
  sLZ4_sizeofState = 'LZ4_sizeofState';
  sLZ4_compress_fast_extState = 'LZ4_compress_fast_extState';
  sLZ4_compress_destSize = 'LZ4_compress_destSize';
  sLZ4_decompress_fast = 'LZ4_decompress_fast';
  sLZ4_decompress_safe_partial = 'LZ4_decompress_safe_partial';
  sLZ4_createStream = 'LZ4_createStream';
  sLZ4_freeStream = 'LZ4_freeStream';
  sLZ4_resetStream = 'LZ4_resetStream';
  sLZ4_loadDict = 'LZ4_loadDict';
  sLZ4_compress_fast_continue = 'LZ4_compress_fast_continue';
  sLZ4_saveDict = 'LZ4_saveDict';
  sLZ4_createStreamDecode = 'LZ4_createStreamDecode';
  sLZ4_freeStreamDecode = 'LZ4_freeStreamDecode';
  sLZ4_setStreamDecode = 'LZ4_setStreamDecode';
  sLZ4_decoderRingBufferSize = 'LZ4_decoderRingBufferSize';
  sLZ4_decompress_safe_continue = 'LZ4_decompress_safe_continue';
  sLZ4_decompress_fast_continue = 'LZ4_decompress_fast_continue';
  sLZ4_decompress_safe_usingDict = 'LZ4_decompress_safe_usingDict';
  sLZ4_decompress_fast_usingDict = 'LZ4_decompress_fast_usingDict';

  sLZ4_compress_HC = 'LZ4_compress_HC';
  sLZ4_sizeofStateHC = 'LZ4_sizeofStateHC';
  sLZ4_compress_HC_extStateHC = 'LZ4_compress_HC_extStateHC';
  sLZ4_createStreamHC = 'LZ4_createStreamHC';
  sLZ4_freeStreamHC = 'LZ4_freeStreamHC';
  sLZ4_resetStreamHC = 'LZ4_resetStreamHC';
  sLZ4_loadDictHC = 'LZ4_loadDictHC';
  sLZ4_compress_HC_continue = 'LZ4_compress_HC_continue';
  sLZ4_saveDictHC = 'LZ4_saveDictHC';

  sLZ4F_isError = 'LZ4F_isError';
  sLZ4F_getErrorName = 'LZ4F_getErrorName';
  sLZ4F_compressionLevel_max = 'LZ4F_compressionLevel_max';
  sLZ4F_compressFrameBound = 'LZ4F_compressFrameBound';
  sLZ4F_compressFrame = 'LZ4F_compressFrame';
  sLZ4F_getVersion = 'LZ4F_getVersion';
  sLZ4F_createCompressionContext = 'LZ4F_createCompressionContext';
  sLZ4F_freeCompressionContext = 'LZ4F_freeCompressionContext';
  sLZ4F_compressBegin = 'LZ4F_compressBegin';
  sLZ4F_compressBound = 'LZ4F_compressBound';
  sLZ4F_compressUpdate = 'LZ4F_compressUpdate';
  sLZ4F_flush = 'LZ4F_flush';
  sLZ4F_compressEnd = 'LZ4F_compressEnd';
  sLZ4F_createDecompressionContext = 'LZ4F_createDecompressionContext';
  sLZ4F_freeDecompressionContext = 'LZ4F_freeDecompressionContext';
  sLZ4F_getFrameInfo = 'LZ4F_getFrameInfo';
  sLZ4F_decompress = 'LZ4F_decompress';
  sLZ4F_resetDecompressionContext = 'LZ4F_resetDecompressionContext';

type
  unsigned = DWORD;
  int = Integer;

(**< library version number; useful to check dll version *)
function LZ4_versionNumber: int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_versionNumber;{$ENDIF}
(**< library version string; unseful to check dll version *)
function LZ4_versionString: PAnsiChar; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_versionString;{$ENDIF}

(*-************************************
*  Tuning parameter
**************************************)
(*!
 * LZ4_MEMORY_USAGE :
 * Memory usage formula : N->2^N Bytes (examples : 10 -> 1KB; 12 -> 4KB ; 16 -> 64KB; 20 -> 1MB; etc.)
 * Increasing memory usage improves compression ratio
 * Reduced memory usage may improve speed, thanks to cache effect
 * Default value is 14, for 16KB, which nicely fits into Intel x86 L1 cache
 *)

const
  LZ4_MEMORY_USAGE = 14;

(*-************************************
*  Simple Functions
**************************************)

(*! LZ4_compress_default() :
    Compresses 'srcSize' bytes from buffer 'src'
    into already allocated 'dst' buffer of size 'dstCapacity'.
    Compression is guaranteed to succeed if 'dstCapacity' >= LZ4_compressBound(srcSize).
    It also runs faster, so it's a recommended setting.
    If the function cannot compress 'src' into a more limited 'dst' budget,
    compression stops *immediately*, and the function result is zero.
    Note : as a consequence, 'dst' content is not valid.
    Note 2 : This function is protected against buffer overflow scenarios (never writes outside 'dst' buffer, nor read outside 'source' buffer).
        srcSize : max supported value is LZ4_MAX_INPUT_SIZE.
        dstCapacity : size of buffer 'dst' (which must be already allocated)
        return  : the number of bytes written into buffer 'dst' (necessarily <= dstCapacity)
                  or 0 if compression fails *)
function LZ4_compress_default(src, dst: Pointer; srcSize, dstCapacity: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_default;{$ENDIF}

(*! LZ4_decompress_safe() :
    compressedSize : is the exact complete size of the compressed block.
    dstCapacity : is the size of destination buffer, which must be already allocated.
    return : the number of bytes decompressed into destination buffer (necessarily <= dstCapacity)
             If destination buffer is not large enough, decoding will stop and output an error code (negative value).
             If the source stream is detected malformed, the function will stop decoding and return a negative result.
             This function is protected against malicious data packets.
*)
function LZ4_decompress_safe(src, dst: Pointer; compressedSize, dstCapacity: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_safe;{$ENDIF}

(*-************************************
*  Advanced Functions
**************************************)

const
  LZ4_MAX_INPUT_SIZE = $7E000000;   (* 2 113 929 216 bytes *)

// LZ4_COMPRESSBOUND(isize)  ((unsigned)(isize) > (unsigned)LZ4_MAX_INPUT_SIZE ? 0 : (isize) + ((isize)/255) + 16)

(*!
LZ4_compressBound() :
    Provides the maximum size that LZ4 compression may output in a "worst case" scenario (input data not compressible)
    This function is primarily useful for memory allocation purposes (destination buffer size).
    Macro LZ4_COMPRESSBOUND() is also provided for compilation-time evaluation (stack memory allocation for example).
    Note that LZ4_compress_default() compresses faster when dstCapacity is >= LZ4_compressBound(srcSize)
        inputSize  : max supported value is LZ4_MAX_INPUT_SIZE
        return : maximum output size in a "worst case" scenario
              or 0, if input size is incorrect (too large or negative)
*)
function LZ4_compressBound(inputSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compressBound;{$ENDIF}

(*!
LZ4_compress_fast() :
    Same as LZ4_compress_default(), but allows selection of "acceleration" factor.
    The larger the acceleration value, the faster the algorithm, but also the lesser the compression.
    It's a trade-off. It can be fine tuned, with each successive value providing roughly +~3% to speed.
    An acceleration value of "1" is the same as regular LZ4_compress_default()
    Values <= 0 will be replaced by ACCELERATION_DEFAULT (currently == 1, see lz4.c).
*)
function LZ4_compress_fast(src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_fast;{$ENDIF}

(*!
LZ4_compress_fast_extState() :
    Same compression function, just using an externally allocated memory space to store compression state.
    Use LZ4_sizeofState() to know how much memory must be allocated,
    and allocate it on 8-bytes boundaries (using malloc() typically).
    Then, provide this buffer as 'void* state' to compression function.
*)
function LZ4_sizeofState: int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_sizeofState;{$ENDIF}
function LZ4_compress_fast_extState(state, src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_fast_extState;{$ENDIF}

(*! LZ4_compress_destSize() :
 *  Reverse the logic : compresses as much data as possible from 'src' buffer
 *  into already allocated buffer 'dst', of size >= 'targetDestSize'.
 *  This function either compresses the entire 'src' content into 'dst' if it's large enough,
 *  or fill 'dst' buffer completely with as much data as possible from 'src'.
 *  note: acceleration parameter is fixed to "default".
 *
 * *srcSizePtr : will be modified to indicate how many bytes where read from 'src' to fill 'dst'.
 *               New value is necessarily <= input value.
 * @return : Nb bytes written into 'dst' (necessarily <= targetDestSize)
 *           or 0 if compression fails.
*)
function LZ4_compress_destSize(src, dst: Pointer; var srcSizePtr: int; targetDstSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_destSize;{$ENDIF}

(*! LZ4_decompress_fast() : **unsafe!**
 *  This function used to be a bit faster than LZ4_decompress_safe(),
 *  though situation has changed in recent versions,
 *  and now `LZ4_decompress_safe()` can be as fast and sometimes faster than `LZ4_decompress_fast()`.
 *  Moreover, LZ4_decompress_fast() is not protected vs malformed input, as it doesn't perform full validation of compressed data.
 *  As a consequence, this function is no longer recommended, and may be deprecated in future versions.
 *  It's only remaining specificity is that it can decompress data without knowing its compressed size.
 *
 *  originalSize : is the uncompressed size to regenerate.
 *                 `dst` must be already allocated, its size must be >= 'originalSize' bytes.
 * @return : number of bytes read from source buffer (== compressed size).
 *           If the source stream is detected malformed, the function stops decoding and returns a negative result.
 *  note : This function requires uncompressed originalSize to be known in advance.
 *         The function never writes past the output buffer.
 *         However, since it doesn't know its 'src' size, it may read past the intended input.
 *         Also, because match offsets are not validated during decoding,
 *         reads from 'src' may underflow.
 *         Use this function in trusted environment **only**.
 *)
function LZ4_decompress_fast(src, dst: Pointer; originalSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_fast;{$ENDIF}

(*! LZ4_decompress_safe_partial() :
 *  Decompress an LZ4 compressed block, of size 'srcSize' at position 'src',
 *  into destination buffer 'dst' of size 'dstCapacity'.
 *  Up to 'targetOutputSize' bytes will be decoded.
 *  The function stops decoding on reaching this objective,
 *  which can boost performance when only the beginning of a block is required.
 *
 * @return : the number of bytes decoded in `dst` (necessarily <= dstCapacity)
 *           If source stream is detected malformed, function returns a negative result.
 *
 *  Note : @return can be < targetOutputSize, if compressed block contains less data.
 *
 *  Note 2 : this function features 2 parameters, targetOutputSize and dstCapacity,
 *           and expects targetOutputSize <= dstCapacity.
 *           It effectively stops decoding on reaching targetOutputSize,
 *           so dstCapacity is kind of redundant.
 *           This is because in a previous version of this function,
 *           decoding operation would not "break" a sequence in the middle.
 *           As a consequence, there was no guarantee that decoding would stop at exactly targetOutputSize,
 *           it could write more bytes, though only up to dstCapacity.
 *           Some "margin" used to be required for this operation to work properly.
 *           This is no longer necessary.
 *           The function nonetheless keeps its signature, in an effort to not break API.
 *)
function LZ4_decompress_safe_partial(src, dst: Pointer; srcSize, targetOutputSize, dstCapacity: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_safe_partial;{$ENDIF}

(*-*********************************************
*  Streaming Compression Functions
***********************************************)

type
  LZ4_stream_t = type Pointer;
  LZ4_stream_u = type Pointer;

(*! LZ4_createStream() and LZ4_freeStream() :
 *  LZ4_createStream() will allocate and initialize an `LZ4_stream_t` structure.
 *  LZ4_freeStream() releases its memory.
 *)
function LZ4_createStream: LZ4_stream_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_createStream;{$ENDIF}
function LZ4_freeStream(streamPtr: LZ4_stream_t): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_freeStream;{$ENDIF}

(*! LZ4_resetStream() :
 *  An LZ4_stream_t structure can be allocated once and re-used multiple times.
 *  Use this function to start compressing a new stream.
 *)
procedure LZ4_resetStream(streamPtr: LZ4_stream_t); {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_resetStream;{$ENDIF}

(*! LZ4_loadDict() :
 *  Use this function to load a static dictionary into LZ4_stream_t.
 *  Any previous data will be forgotten, only 'dictionary' will remain in memory.
 *  Loading a size of 0 is allowed, and is the same as reset.
 * @return : dictionary size, in bytes (necessarily <= 64 KB)
 *)
function LZ4_loadDict(streamPtr: LZ4_stream_t; dictionary: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_loadDict;{$ENDIF}

(*! LZ4_compress_fast_continue() :
 *  Compress 'src' content using data from previously compressed blocks, for better compression ratio.
 *  'dst' buffer must be already allocated.
 *  If dstCapacity >= LZ4_compressBound(srcSize), compression is guaranteed to succeed, and runs faster.
 *
 * @return : size of compressed block
 *           or 0 if there is an error (typically, cannot fit into 'dst').
 *
 *  Note 1 : Each invocation to LZ4_compress_fast_continue() generates a new block.
 *           Each block has precise boundaries.
 *           It's not possible to append blocks together and expect a single invocation of LZ4_decompress_*() to decompress them together.
 *           Each block must be decompressed separately, calling LZ4_decompress_*() with associated metadata.
 *
 *  Note 2 : The previous 64KB of source data is __assumed__ to remain present, unmodified, at same address in memory!
 *
 *  Note 3 : When input is structured as a double-buffer, each buffer can have any size, including < 64 KB.
 *           Make sure that buffers are separated, by at least one byte.
 *           This construction ensures that each block only depends on previous block.
 *
 *  Note 4 : If input buffer is a ring-buffer, it can have any size, including < 64 KB.
 *
 *  Note 5 : After an error, the stream status is invalid, it can only be reset or freed.
 *)
function LZ4_compress_fast_continue(streamPtr: LZ4_stream_t; src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_fast_continue;{$ENDIF}

(*! LZ4_saveDict() :
 *  If last 64KB data cannot be guaranteed to remain available at its current memory location,
 *  save it into a safer place (char* safeBuffer).
 *  This is schematically equivalent to a memcpy() followed by LZ4_loadDict(),
 *  but is much faster, because LZ4_saveDict() doesn't need to rebuild tables.
 * @return : saved dictionary size in bytes (necessarily <= maxDictSize), or 0 if error.
 *)
function LZ4_saveDict(streamPtr: LZ4_stream_t; safeBuffer: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_saveDict;{$ENDIF}

(*-**********************************************
*  Streaming Decompression Functions
*  Bufferless synchronous API
************************************************)

type
  LZ4_streamDecode_u = type Pointer;
  LZ4_streamDecode_t = type Pointer;

(*! LZ4_createStreamDecode() and LZ4_freeStreamDecode() :
 *  creation / destruction of streaming decompression tracking context.
 *  A tracking context can be re-used multiple times.
 *)
function LZ4_createStreamDecode: LZ4_streamDecode_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_createStreamDecode;{$ENDIF}
function LZ4_freeStreamDecode(LZ4_stream: LZ4_streamDecode_t): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_freeStreamDecode;{$ENDIF}

(*! LZ4_setStreamDecode() :
 *  An LZ4_streamDecode_t context can be allocated once and re-used multiple times.
 *  Use this function to start decompression of a new stream of blocks.
 *  A dictionary can optionally be set. Use NULL or size 0 for a reset order.
 *  Dictionary is presumed stable : it must remain accessible and unmodified during next decompression.
 * @return : 1 if OK, 0 if error
 *)
function LZ4_setStreamDecode(LZ4_streamDecode: LZ4_streamDecode_t; dictionary: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_setStreamDecode;{$ENDIF}

(*! LZ4_decoderRingBufferSize() : v1.8.2
 *  Note : in a ring buffer scenario (optional),
 *  blocks are presumed decompressed next to each other
 *  up to the moment there is not enough remaining space for next block (remainingSize < maxBlockSize),
 *  at which stage it resumes from beginning of ring buffer.
 *  When setting such a ring buffer for streaming decompression,
 *  provides the minimum size of this ring buffer
 *  to be compatible with any source respecting maxBlockSize condition.
 * @return : minimum ring buffer size,
 *           or 0 if there is an error (invalid maxBlockSize).
 *)
function LZ4_decoderRingBufferSize(maxBlockSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decoderRingBufferSize;{$ENDIF}

function LZ4_DECODER_RING_BUFFER_SIZE(mbs: unsigned): unsigned; inline; (* for static allocation; mbs presumed valid *)
//#define LZ4_DECODER_RING_BUFFER_SIZE(mbs) (65536 + 14 + (mbs))  /* for static allocation; mbs presumed valid */

(*! LZ4_decompress_*_continue() :
 *  These decoding functions allow decompression of consecutive blocks in "streaming" mode.
 *  A block is an unsplittable entity, it must be presented entirely to a decompression function.
 *  Decompression functions only accepts one block at a time.
 *  The last 64KB of previously decoded data *must* remain available and unmodified at the memory position where they were decoded.
 *  If less than 64KB of data has been decoded, all the data must be present.
 *
 *  Special : if decompression side sets a ring buffer, it must respect one of the following conditions :
 *  - Decompression buffer size is _at least_ LZ4_decoderRingBufferSize(maxBlockSize).
 *    maxBlockSize is the maximum size of any single block. It can have any value > 16 bytes.
 *    In which case, encoding and decoding buffers do not need to be synchronized.
 *    Actually, data can be produced by any source compliant with LZ4 format specification, and respecting maxBlockSize.
 *  - Synchronized mode :
 *    Decompression buffer size is _exactly_ the same as compression buffer size,
 *    and follows exactly same update rule (block boundaries at same positions),
 *    and decoding function is provided with exact decompressed size of each block (exception for last block of the stream),
 *    _then_ decoding & encoding ring buffer can have any size, including small ones ( < 64 KB).
 *  - Decompression buffer is larger than encoding buffer, by a minimum of maxBlockSize more bytes.
 *    In which case, encoding and decoding buffers do not need to be synchronized,
 *    and encoding ring buffer can have any size, including small ones ( < 64 KB).
 *
 *  Whenever these conditions are not possible,
 *  save the last 64KB of decoded data into a safe buffer where it can't be modified during decompression,
 *  then indicate where this data is saved using LZ4_setStreamDecode(), before decompressing next block.
*)
function LZ4_decompress_safe_continue(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; srcSize, dstCapacity: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_safe_continue;{$ENDIF}
function LZ4_decompress_fast_continue(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; originalSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_fast_continue;{$ENDIF}

(*! LZ4_decompress_*_usingDict() :
 *  These decoding functions work the same as
 *  a combination of LZ4_setStreamDecode() followed by LZ4_decompress_*_continue()
 *  They are stand-alone, and don't need an LZ4_streamDecode_t structure.
 *  Dictionary is presumed stable : it must remain accessible and unmodified during next decompression.
 *)
function LZ4_decompress_safe_usingDict(src, dst: Pointer; srcSize, dstCapcity: int; dictStart: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_safe_usingDict;{$ENDIF}
function LZ4_decompress_fast_usingDict(src, dst: Pointer; originalSize: int; dictStart: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_decompress_fast_usingDict;{$ENDIF}

(*
    LZ4 HC - High Compression Mode of LZ4
    Copyright (C) 2011-2017, Yann Collet.

    BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are
    met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
    copyright notice, this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    You can contact the author at :
       - LZ4 source repository : https://github.com/lz4/lz4
       - LZ4 public forum : https://groups.google.com/forum/#!forum/lz4c
*)

const
  LZ4HC_CLEVEL_MIN     = 3;
  LZ4HC_CLEVEL_DEFAULT = 9;
  LZ4HC_CLEVEL_OPT_MIN = 10;
  LZ4HC_CLEVEL_MAX     = 12;

(*-************************************
 *  Block Compression
 **************************************)
(*! LZ4_compress_HC() :
 *  Compress data from `src` into `dst`, using the more powerful but slower "HC" algorithm.
 * `dst` must be already allocated.
 *  Compression is guaranteed to succeed if `dstCapacity >= LZ4_compressBound(srcSize)` (see "lz4.h")
 *  Max supported `srcSize` value is LZ4_MAX_INPUT_SIZE (see "lz4.h")
 * `compressionLevel` : any value between 1 and LZ4HC_CLEVEL_MAX will work.
 *                      Values > LZ4HC_CLEVEL_MAX behave the same as LZ4HC_CLEVEL_MAX.
 * @return : the number of bytes written into 'dst'
 *           or 0 if compression fails.
 *)
function LZ4_compress_HC(src, dst: Pointer; srcSize, dstCapacity, compressionLevel: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_HC;{$ENDIF}

(* Note :
 *   Decompression functions are provided within "lz4.h" (BSD license)
 *)


(*! LZ4_compress_HC_extStateHC() :
 *  Same as LZ4_compress_HC(), but using an externally allocated memory segment for `state`.
 * `state` size is provided by LZ4_sizeofStateHC().
 *  Memory segment must be aligned on 8-bytes boundaries (which a normal malloc() should do properly).
 *)
function LZ4_sizeofStateHC: int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_sizeofStateHC;{$ENDIF}
function LZ4_compress_HC_extStateHC(state, src, dst: Pointer; srcSize, maxDstSize, compressionLevel: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_HC_extStateHC;{$ENDIF}

(*-************************************
 *  Streaming Compression
 *  Bufferless synchronous API
 **************************************)

type
  LZ4_streamHC_u = type Pointer;
  LZ4_streamHC_t = type Pointer;

(*! LZ4_createStreamHC() and LZ4_freeStreamHC() :
 *  These functions create and release memory for LZ4 HC streaming state.
 *  Newly created states are automatically initialized.
 *  Existing states can be re-used several times, using LZ4_resetStreamHC().
 *  These methods are API and ABI stable, they can be used in combination with a DLL.
 *)
function LZ4_createStreamHC: LZ4_streamHC_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_createStreamHC;{$ENDIF}
function LZ4_freeStreamHC(streamHCPtr: LZ4_streamHC_t): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_freeStreamHC;{$ENDIF}

procedure LZ4_resetStreamHC(streamHCPtr: LZ4_streamHC_t; compressionLevel: int); {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_resetStreamHC;{$ENDIF}
function LZ4_loadDictHC(streamHCPtr: LZ4_streamHC_t; dictionary: Pointer; dictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_loadDictHC;{$ENDIF}

function LZ4_compress_HC_continue(streamHCPtr: LZ4_streamHC_t; src, dst: Pointer; srcSize, maxDstSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_compress_HC_continue;{$ENDIF}

function LZ4_saveDictHC(streamHCPtr: LZ4_streamHC_t; safeBuffer: Pointer; maxDictSize: int): int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4_saveDictHC;{$ENDIF}

(*
  These functions compress data in successive blocks of any size, using previous blocks as dictionary.
  One key assumption is that previous blocks (up to 64 KB) remain read-accessible while compressing next blocks.
  There is an exception for ring buffers, which can be smaller than 64 KB.
  Ring buffers scenario is automatically detected and handled by LZ4_compress_HC_continue().

  Before starting compression, state must be properly initialized, using LZ4_resetStreamHC().
  A first "fictional block" can then be designated as initial dictionary, using LZ4_loadDictHC() (Optional).

  Then, use LZ4_compress_HC_continue() to compress each successive block.
  Previous memory blocks (including initial dictionary when present) must remain accessible and unmodified during compression.
  'dst' buffer should be sized to handle worst case scenarios (see LZ4_compressBound()), to ensure operation success.
  Because in case of failure, the API does not guarantee context recovery, and context will have to be reset.
  If `dst` buffer budget cannot be >= LZ4_compressBound(), consider using LZ4_compress_HC_continue_destSize() instead.

  If, for any reason, previous data block can't be preserved unmodified in memory for next compression block,
  you can save it to a more stable memory space, using LZ4_saveDictHC().
  Return value of LZ4_saveDictHC() is the size of dictionary effectively saved into 'safeBuffer'.
*)

(*-************************************
*  Deprecated Functions
**************************************)

(*
LZ4_DEPRECATED("use LZ4_compress_HC() instead") LZ4LIB_API int LZ4_compressHC               (const char* source, char* dest, int inputSize);
LZ4_DEPRECATED("use LZ4_compress_HC() instead") LZ4LIB_API int LZ4_compressHC_limitedOutput (const char* source, char* dest, int inputSize, int maxOutputSize);
LZ4_DEPRECATED("use LZ4_compress_HC() instead") LZ4LIB_API int LZ4_compressHC2 (const char* source, char* dest, int inputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_compress_HC() instead") LZ4LIB_API int LZ4_compressHC2_limitedOutput (const char* source, char* dest, int inputSize, int maxOutputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_compress_HC_extStateHC() instead") LZ4LIB_API int LZ4_compressHC_withStateHC               (void* state, const char* source, char* dest, int inputSize);
LZ4_DEPRECATED("use LZ4_compress_HC_extStateHC() instead") LZ4LIB_API int LZ4_compressHC_limitedOutput_withStateHC (void* state, const char* source, char* dest, int inputSize, int maxOutputSize);
LZ4_DEPRECATED("use LZ4_compress_HC_extStateHC() instead") LZ4LIB_API int LZ4_compressHC2_withStateHC (void* state, const char* source, char* dest, int inputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_compress_HC_extStateHC() instead") LZ4LIB_API int LZ4_compressHC2_limitedOutput_withStateHC(void* state, const char* source, char* dest, int inputSize, int maxOutputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_compress_HC_continue() instead") LZ4LIB_API int LZ4_compressHC_continue               (LZ4_streamHC_t* LZ4_streamHCPtr, const char* source, char* dest, int inputSize);
LZ4_DEPRECATED("use LZ4_compress_HC_continue() instead") LZ4LIB_API int LZ4_compressHC_limitedOutput_continue (LZ4_streamHC_t* LZ4_streamHCPtr, const char* source, char* dest, int inputSize, int maxOutputSize);
*)

(* Obsolete streaming functions; degraded functionality; do not use!
 *
 * In order to perform streaming compression, these functions depended on data
 * that is no longer tracked in the state. They have been preserved as well as
 * possible: using them will still produce a correct output. However, use of
 * LZ4_slideInputBufferHC() will truncate the history of the stream, rather
 * than preserve a window-sized chunk of history.
 *)
(*
LZ4_DEPRECATED("use LZ4_createStreamHC() instead") LZ4LIB_API void* LZ4_createHC (const char* inputBuffer);
LZ4_DEPRECATED("use LZ4_saveDictHC() instead") LZ4LIB_API     char* LZ4_slideInputBufferHC (void* LZ4HC_Data);
LZ4_DEPRECATED("use LZ4_freeStreamHC() instead") LZ4LIB_API   int   LZ4_freeHC (void* LZ4HC_Data);
LZ4_DEPRECATED("use LZ4_compress_HC_continue() instead") LZ4LIB_API int LZ4_compressHC2_continue (void* LZ4HC_Data, const char* source, char* dest, int inputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_compress_HC_continue() instead") LZ4LIB_API int LZ4_compressHC2_limitedOutput_continue (void* LZ4HC_Data, const char* source, char* dest, int inputSize, int maxOutputSize, int compressionLevel);
LZ4_DEPRECATED("use LZ4_createStreamHC() instead") LZ4LIB_API int   LZ4_sizeofStreamStateHC(void);
LZ4_DEPRECATED("use LZ4_resetStreamHC() instead") LZ4LIB_API  int   LZ4_resetStreamStateHC(void* state, char* inputBuffer);
*)

(*
   LZ4 auto-framing library
   Header File
   Copyright (C) 2011-2017, Yann Collet.
   BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

       * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer
   in the documentation and/or other materials provided with the
   distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   You can contact the author at :
   - LZ4 source repository : https://github.com/lz4/lz4
   - LZ4 public forum : https://groups.google.com/forum/#!forum/lz4c
*)

(* LZ4F is a stand-alone API to create LZ4-compressed frames
 * conformant with specification v1.6.1.
 * It also offers streaming capabilities.
 * lz4.h is not required when using lz4frame.h,
 * except to get constant such as LZ4_VERSION_NUMBER.
 * *)

(**
  Introduction

  lz4frame.h implements LZ4 frame specification (doc/lz4_Frame_format.md).
  lz4frame.h provides frame compression functions that take care
  of encoding standard metadata alongside LZ4-compressed blocks.
*)

(*-************************************
 *  Error management
 **************************************)
type
  LZ4F_errorCode_t = type size_t;

procedure LZ4FError(const AFunctionName: string; ACode: LZ4F_errorCode_t);
function LZ4FCheck(const AFunctionName: string; ACode: size_t): size_t;

(**< tells when a function result is an error code *)
function LZ4F_isError(code: LZ4F_errorCode_t): unsigned; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_isError;{$ENDIF}
(**< return error code string; for debugging *)
function LZ4F_getErrorName(code: LZ4F_errorCode_t): PAnsiChar; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_getErrorName;{$ENDIF}

(*-************************************
 *  Frame compression types
 **************************************)

(* The larger the block size, the (slightly) better the compression ratio,
 * though there are diminishing returns.
 * Larger blocks also increase memory usage on both compression and decompression sides. *)
type
  LZ4F_blockSizeID_t = (
    LZ4F_default  = 0,
    LZ4F_max64KB  = 4,
    LZ4F_max256KB = 5,
    LZ4F_max1MB   = 6,
    LZ4F_max4MB   = 7
    {LZ4F_OBSOLETE_ENUM(max64KB)
    LZ4F_OBSOLETE_ENUM(max256KB)
    LZ4F_OBSOLETE_ENUM(max1MB)
    LZ4F_OBSOLETE_ENUM(max4MB)}
  );

(* Linked blocks sharply reduce inefficiencies when using small blocks,
 * they compress better.
 * However, some LZ4 decoders are only compatible with independent blocks *)
  LZ4F_blockMode_t = (
    LZ4F_blockLinked = 0,
    LZ4F_blockIndependent
    //LZ4F_OBSOLETE_ENUM(blockLinked)
    //LZ4F_OBSOLETE_ENUM(blockIndependent)
  );

  LZ4F_contentChecksum_t = (
    LZ4F_noContentChecksum = 0,
    LZ4F_contentChecksumEnabled
    //LZ4F_OBSOLETE_ENUM(noContentChecksum)
    //LZ4F_OBSOLETE_ENUM(contentChecksumEnabled)
  );

  LZ4F_blockChecksum_t = (
    LZ4F_noBlockChecksum = 0,
    LZ4F_blockChecksumEnabled
  );

  LZ4F_frameType_t = (
    LZ4F_frame = 0,
    LZ4F_skippableFrame
    //LZ4F_OBSOLETE_ENUM(skippableFrame)
  );

(*
typedef LZ4F_blockSizeID_t blockSizeID_t;
typedef LZ4F_blockMode_t blockMode_t;
typedef LZ4F_frameType_t frameType_t;
typedef LZ4F_contentChecksum_t contentChecksum_t;
*)

(*! LZ4F_frameInfo_t :
 *  makes it possible to set or read frame parameters.
 *  Structure must be first init to 0, using memset() or LZ4F_INIT_FRAMEINFO,
 *  setting all parameters to default.
 *  It's then possible to update selectively some parameters *)
  LZ4F_frameInfo_t = record
    blockSizeID: LZ4F_blockSizeID_t;             (* max64KB, max256KB, max1MB, max4MB ; 0 == default *)
    blockMode: LZ4F_blockMode_t;                 (* LZ4F_blockLinked, LZ4F_blockIndependent ; 0 == default *)
    contentChecksumFlag: LZ4F_contentChecksum_t; (* if enabled, frame is terminated with a 32-bits checksum of decompressed data ; 0 == disabled (default)  *)
    frameType: LZ4F_frameType_t;                 (* read-only field : LZ4F_frame or LZ4F_skippableFrame *)
    contentSize: UInt64;                         (* Size of uncompressed content ; 0 == unknown *)
    dictID: unsigned;                            (* Dictionary ID, sent by the compressor to help decoder select the correct dictionary; 0 == no dictID provided *)
    blockChecksumFlag: LZ4F_blockChecksum_t;     (* if enabled, each block is followed by a checksum of block's compressed data ; 0 == disabled (default)  *)
  end;

//#define LZ4F_INIT_FRAMEINFO   { 0, 0, 0, 0, 0, 0, 0 }    /* v1.8.3+ */

(*! LZ4F_preferences_t :
 *  makes it possible to supply advanced compression instructions to streaming interface.
 *  Structure must be first init to 0, using memset() or LZ4F_INIT_PREFERENCES,
 *  setting all parameters to default.
 *  All reserved fields must be set to zero. *)
  LZ4F_preferences_t = record
    frameInfo: LZ4F_frameInfo_t;
    compressionLevel: int;       (* 0: default (fast mode); values > LZ4HC_CLEVEL_MAX count as LZ4HC_CLEVEL_MAX; values < 0 trigger "fast acceleration" *)
    autoFlush: unsigned;         (* 1: always flush; reduces usage of internal buffers *)
    favorDecSpeed: unsigned;     (* 1: parser favors decompression speed vs compression ratio. Only works for high compression modes (>= LZ4HC_CLEVEL_OPT_MIN) *)  (* v1.8.2+ *)
    reserved: packed array[0..2] of unsigned; (* must be zero for forward compatibility *)
  end;
  PLZ4F_preferences_t = ^LZ4F_preferences_t;

//#define LZ4F_INIT_PREFERENCES   { LZ4F_INIT_FRAMEINFO, 0, 0, 0, { 0, 0, 0 } }    /* v1.8.3+ */

(*-*********************************
*  Simple compression function
***********************************)

function LZ4F_compressionLevel_max: int; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressionLevel_max;{$ENDIF}

(*! LZ4F_compressFrameBound() :
 *  Returns the maximum possible compressed size with LZ4F_compressFrame() given srcSize and preferences.
 * `preferencesPtr` is optional. It can be replaced by NULL, in which case, the function will assume default preferences.
 *  Note : this result is only usable with LZ4F_compressFrame().
 *         It may also be used with LZ4F_compressUpdate() _if no flush() operation_ is performed.
 *)
function LZ4F_compressFrameBound(srcSize: size_t; preferencesPtr: PLZ4F_preferences_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressFrameBound;{$ENDIF}

(*! LZ4F_compressFrame() :
 *  Compress an entire srcBuffer into a valid LZ4 frame.
 *  dstCapacity MUST be >= LZ4F_compressFrameBound(srcSize, preferencesPtr).
 *  The LZ4F_preferences_t structure is optional : you can provide NULL as argument. All preferences will be set to default.
 * @return : number of bytes written into dstBuffer.
 *           or an error code if it fails (can be tested using LZ4F_isError())
 *)
function LZ4F_compressFrame(dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; const preferencesPtr: LZ4F_preferences_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressFrame;{$ENDIF}

(*-***********************************
*  Advanced compression functions
*************************************)

type
  LZ4F_cctx = type Pointer;

  LZ4F_compressOptions_t = record
    stableSrc: unsigned;    (* 1 == src content will remain present on future calls to LZ4F_compress(); skip copying src content within tmp buffer *)
    reserved: packed array[0..2] of unsigned;
  end;
  PLZ4F_compressOptions_t = ^LZ4F_compressOptions_t;

(*---   Resource Management   ---*)

const
  LZ4F_VERSION = 100;    (* This number can be used to check for an incompatible API breaking change *)

function LZ4F_getVersion: unsigned; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_getVersion;{$ENDIF}

(*! LZ4F_createCompressionContext() :
 * The first thing to do is to create a compressionContext object, which will be used in all compression operations.
 * This is achieved using LZ4F_createCompressionContext(), which takes as argument a version.
 * The version provided MUST be LZ4F_VERSION. It is intended to track potential version mismatch, notably when using DLL.
 * The function will provide a pointer to a fully allocated LZ4F_cctx object.
 * If @return != zero, there was an error during context creation.
 * Object can release its memory using LZ4F_freeCompressionContext();
 *)
function LZ4F_createCompressionContext(out cctxPtr: LZ4F_cctx; version: unsigned): LZ4F_errorCode_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_createCompressionContext;{$ENDIF}
function LZ4F_freeCompressionContext(cctx: LZ4F_cctx): LZ4F_errorCode_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_freeCompressionContext;{$ENDIF}

(*----    Compression    ----*)

const
  LZ4F_HEADER_SIZE_MAX = 19;   (* LZ4 Frame header size can vary from 7 to 19 bytes *)

(*! LZ4F_compressBegin() :
 *  will write the frame header into dstBuffer.
 *  dstCapacity must be >= LZ4F_HEADER_SIZE_MAX bytes.
 * `prefsPtr` is optional : you can provide NULL as argument, all preferences will then be set to default.
 * @return : number of bytes written into dstBuffer for the header
 *           or an error code (which can be tested using LZ4F_isError())
 *)
function LZ4F_compressBegin(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; prefsPtr: PLZ4F_preferences_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressBegin;{$ENDIF}

(*! LZ4F_compressBound() :
 *  Provides minimum dstCapacity required to guarantee compression success
 *  given a srcSize and preferences, covering worst case scenario.
 *  prefsPtr is optional : when NULL is provided, preferences will be set to cover worst case scenario.
 *  Estimation is valid for either LZ4F_compressUpdate(), LZ4F_flush() or LZ4F_compressEnd(),
 *  Estimation includes the possibility that internal buffer might already be filled by up to (blockSize-1) bytes.
 *  It also includes frame footer (ending + checksum), which would have to be generated by LZ4F_compressEnd().
 *  Estimation doesn't include frame header, as it was already generated by LZ4F_compressBegin().
 *  Result is always the same for a srcSize and prefsPtr, so it can be trusted to size reusable buffers.
 *  When srcSize==0, LZ4F_compressBound() provides an upper bound for LZ4F_flush() and LZ4F_compressEnd() operations.
 *)
function LZ4F_compressBound(srcSize: size_t; prefsPtr: PLZ4F_preferences_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressBound;{$ENDIF}

(*! LZ4F_compressUpdate() :
 *  LZ4F_compressUpdate() can be called repetitively to compress as much data as necessary.
 *  Important rule: dstCapacity MUST be large enough to ensure operation success even in worst case situations.
 *  This value is provided by LZ4F_compressBound().
 *  If this condition is not respected, LZ4F_compress() will fail (result is an errorCode).
 *  LZ4F_compressUpdate() doesn't guarantee error recovery.
 *  When an error occurs, compression context must be freed or resized.
 * `cOptPtr` is optional : NULL can be provided, in which case all options are set to default.
 * @return : number of bytes written into `dstBuffer` (it can be zero, meaning input data was just buffered).
 *           or an error code if it fails (which can be tested using LZ4F_isError())
 *)
function LZ4F_compressUpdate(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressUpdate;{$ENDIF}

(*! LZ4F_flush() :
 *  When data must be generated and sent immediately, without waiting for a block to be completely filled,
 *  it's possible to call LZ4_flush(). It will immediately compress any data buffered within cctx.
 * `dstCapacity` must be large enough to ensure the operation will be successful.
 * `cOptPtr` is optional : it's possible to provide NULL, all options will be set to default.
 * @return : nb of bytes written into dstBuffer (can be zero, when there is no data stored within cctx)
 *           or an error code if it fails (which can be tested using LZ4F_isError())
 *)
function LZ4F_flush(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_flush;{$ENDIF}

(*! LZ4F_compressEnd() :
 *  To properly finish an LZ4 frame, invoke LZ4F_compressEnd().
 *  It will flush whatever data remained within `cctx` (like LZ4_flush())
 *  and properly finalize the frame, with an endMark and a checksum.
 * `cOptPtr` is optional : NULL can be provided, in which case all options will be set to default.
 * @return : nb of bytes written into dstBuffer, necessarily >= 4 (endMark),
 *           or an error code if it fails (which can be tested using LZ4F_isError())
 *  A successful call to LZ4F_compressEnd() makes `cctx` available again for another compression task.
 *)
function LZ4F_compressEnd(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_compressEnd;{$ENDIF}

(*-*********************************
*  Decompression functions
***********************************)

type
  LZ4F_dctx = type Pointer;

  LZ4F_decompressOptions_t = record
    stableDst: unsigned;  (* pledges that last 64KB decompressed data will remain available unmodified. This optimization skips storage operations in tmp buffers. *)
    reserved: packed array[0..2] of unsigned;  (* must be set to zero for forward compatibility *)
  end;
  PLZ4F_decompressOptions_t = ^LZ4F_decompressOptions_t;

(* Resource management *)

(*! LZ4F_createDecompressionContext() :
 *  Create an LZ4F_dctx object, to track all decompression operations.
 *  The version provided MUST be LZ4F_VERSION.
 *  The function provides a pointer to an allocated and initialized LZ4F_dctx object.
 *  The result is an errorCode, which can be tested using LZ4F_isError().
 *  dctx memory can be released using LZ4F_freeDecompressionContext();
 *  Result of LZ4F_freeDecompressionContext() indicates current state of decompressionContext when being released.
 *  That is, it should be == 0 if decompression has been completed fully and correctly.
 *)
function LZ4F_createDecompressionContext(out dctxPtr: LZ4F_dctx; version: unsigned): LZ4F_errorCode_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_createDecompressionContext;{$ENDIF}
function LZ4F_freeDecompressionContext(dctx: LZ4F_dctx): LZ4F_errorCode_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_freeDecompressionContext;{$ENDIF}

(*-***********************************
*  Streaming decompression functions
*************************************)

(*! LZ4F_getFrameInfo() :
 *  This function extracts frame parameters (max blockSize, dictID, etc.).
 *  Its usage is optional.
 *  Extracted information is typically useful for allocation and dictionary.
 *  This function works in 2 situations :
 *   - At the beginning of a new frame, in which case
 *     it will decode information from `srcBuffer`, starting the decoding process.
 *     Input size must be large enough to successfully decode the entire frame header.
 *     Frame header size is variable, but is guaranteed to be <= LZ4F_HEADER_SIZE_MAX bytes.
 *     It's allowed to provide more input data than this minimum.
 *   - After decoding has been started.
 *     In which case, no input is read, frame parameters are extracted from dctx.
 *   - If decoding has barely started, but not yet extracted information from header,
 *     LZ4F_getFrameInfo() will fail.
 *  The number of bytes consumed from srcBuffer will be updated within *srcSizePtr (necessarily <= original value).
 *  Decompression must resume from (srcBuffer + *srcSizePtr).
 * @return : an hint about how many srcSize bytes LZ4F_decompress() expects for next call,
 *           or an error code which can be tested using LZ4F_isError().
 *  note 1 : in case of error, dctx is not modified. Decoding operation can resume from beginning safely.
 *  note 2 : frame parameters are *copied into* an already allocated LZ4F_frameInfo_t structure.
 *)
function LZ4F_getFrameInfo(dctx: LZ4F_dctx; out frameInfoPtr: LZ4F_frameInfo_t; srcBuffer: Pointer; out srcSizePtr: size_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_getFrameInfo;{$ENDIF}

(*! LZ4F_decompress() :
 *  Call this function repetitively to regenerate compressed data from `srcBuffer`.
 *  The function will read up to *srcSizePtr bytes from srcBuffer,
 *  and decompress data into dstBuffer, of capacity *dstSizePtr.
 *
 *  The nb of bytes consumed from srcBuffer will be written into *srcSizePtr (necessarily <= original value).
 *  The nb of bytes decompressed into dstBuffer will be written into *dstSizePtr (necessarily <= original value).
 *
 *  The function does not necessarily read all input bytes, so always check value in *srcSizePtr.
 *  Unconsumed source data must be presented again in subsequent invocations.
 *
 * `dstBuffer` can freely change between each consecutive function invocation.
 * `dstBuffer` content will be overwritten.
 *
 * @return : an hint of how many `srcSize` bytes LZ4F_decompress() expects for next call.
 *  Schematically, it's the size of the current (or remaining) compressed block + header of next block.
 *  Respecting the hint provides some small speed benefit, because it skips intermediate buffers.
 *  This is just a hint though, it's always possible to provide any srcSize.
 *
 *  When a frame is fully decoded, @return will be 0 (no more data expected).
 *  When provided with more bytes than necessary to decode a frame,
 *  LZ4F_decompress() will stop reading exactly at end of current frame, and @return 0.
 *
 *  If decompression failed, @return is an error code, which can be tested using LZ4F_isError().
 *  After a decompression error, the `dctx` context is not resumable.
 *  Use LZ4F_resetDecompressionContext() to return to clean state.
 *
 *  After a frame is fully decoded, dctx can be used again to decompress another frame.
 *)
function LZ4F_decompress(dctx: LZ4F_dctx; dstBuffer: Pointer; var dstSizePtr: size_t; srcBuffer: Pointer; var srcSizePtr: size_t; dOptPtr: PLZ4F_decompressOptions_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_decompress;{$ENDIF}


(*! LZ4F_resetDecompressionContext() : added in v1.8.0
 *  In case of an error, the context is left in "undefined" state.
 *  In which case, it's necessary to reset it, before re-using it.
 *  This method can also be used to abruptly stop any unfinished decompression,
 *  and start a new one using same context resources. *)
procedure LZ4F_resetDecompressionContext(dctx: LZ4F_dctx); (* always successful *) {$IFDEF STATIC_LINKING}cdecl; external LZ4DllName name sLZ4F_resetDecompressionContext;{$ENDIF}

implementation

type
  ELZ4FException = class(Exception)
  public
    constructor Create(const AFunctionName: string; ACode: LZ4F_errorCode_t);
  private
    FCode: LZ4F_errorCode_t;
  end;

function GetExceptionMessage(const AFunctionName: string; ACode: LZ4F_errorCode_t): string;
begin
  Result := AFunctionName + ' failed with error ' + IntToStr(ssize_t(ACode)) + ': ' + string(LZ4F_getErrorName(ACode));
end;

constructor ELZ4FException.Create(const AFunctionName: string; ACode: LZ4F_errorCode_t);
begin
  FCode := ACode;
  inherited Create(GetExceptionMessage(AFunctionName, ACode));
end;

const
  LZ4F_OK_NoError                         = 0;
  LZ4F_ERROR_GENERIC                      = 1;
  LZ4F_ERROR_maxBlockSize_invalid         = 2;
  LZ4F_ERROR_blockMode_invalid            = 3;
  LZ4F_ERROR_contentChecksumFlag_invalid  = 4;
  LZ4F_ERROR_compressionLevel_invalid     = 5;
  LZ4F_ERROR_headerVersion_wrong          = 6;
  LZ4F_ERROR_blockChecksum_invalid        = 7;
  LZ4F_ERROR_reservedFlag_set             = 8;
  LZ4F_ERROR_allocation_failed            = 9;
  LZ4F_ERROR_srcSize_tooLarge             = 10;
  LZ4F_ERROR_dstMaxSize_tooSmall          = 11;
  LZ4F_ERROR_frameHeader_incomplete       = 12;
  LZ4F_ERROR_frameType_unknown            = 13;
  LZ4F_ERROR_frameSize_wrong              = 14;
  LZ4F_ERROR_srcPtr_wrong                 = 15;
  LZ4F_ERROR_decompressionFailed          = 16;
  LZ4F_ERROR_headerChecksum_invalid       = 17;
  LZ4F_ERROR_contentChecksum_invalid      = 18;
  LZ4F_ERROR_frameDecoding_alreadyStarted = 19;
  LZ4F_ERROR_maxCode                      = 20;

procedure LZ4FError(const AFunctionName: string; ACode: LZ4F_errorCode_t);
begin
  case -ACode of
    LZ4F_ERROR_allocation_failed:
      raise EOutOfMemory.Create(GetExceptionMessage(AFunctionName, ACode));
  else
    raise ELZ4FException.Create(AFunctionName, ACode);
  end;
end;

function LZ4FCheck(const AFunctionName: string; ACode: size_t): size_t;
begin
  Result := ACode;
  if LZ4F_isError(ACode) <> 0 then
    LZ4FError(AFunctionName, ACode);
end;

function LZ4_DECODER_RING_BUFFER_SIZE(mbs: unsigned): unsigned;
begin
  Result := 65536 + 14 + mbs;
end;

{$IFNDEF STATIC_LINKING}
type
  TLZ4_versionNumber = function: int; cdecl;
  TLZ4_versionString = function: PAnsiChar; cdecl;
  TLZ4_compress_default = function(src, dst: Pointer; srcSize, dstCapacity: int): int; cdecl;
  TLZ4_decompress_safe = function(src, dst: Pointer; compressedSize, dstCapacity: int): int; cdecl;
  TLZ4_compressBound = function(inputSize: int): int; cdecl;
  TLZ4_compress_fast = function(src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; cdecl;
  TLZ4_sizeofState = function: int; cdecl;
  TLZ4_compress_fast_extState = function(state, src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; cdecl;
  TLZ4_compress_destSize = function(src, dst: Pointer; var srcSizePtr: int; targetDstSize: int): int; cdecl;
  TLZ4_decompress_fast = function(src, dst: Pointer; originalSize: int): int; cdecl;
  TLZ4_decompress_safe_partial = function(src, dst: Pointer; srcSize, targetOutputSize, dstCapacity: int): int; cdecl;
  TLZ4_createStream = function: LZ4_stream_t; cdecl;
  TLZ4_freeStream = function(streamPtr: LZ4_stream_t): int; cdecl;
  TLZ4_resetStream = procedure(streamPtr: LZ4_stream_t); cdecl;
  TLZ4_loadDict = function(streamPtr: LZ4_stream_t; dictionary: Pointer; dictSize: int): int; cdecl;
  TLZ4_compress_fast_continue = function(streamPtr: LZ4_stream_t; src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int; cdecl;
  TLZ4_saveDict = function(streamPtr: LZ4_stream_t; safeBuffer: Pointer; dictSize: int): int; cdecl;
  TLZ4_createStreamDecode = function: LZ4_streamDecode_t; cdecl;
  TLZ4_freeStreamDecode = function(LZ4_stream: LZ4_streamDecode_t): int; cdecl;
  TLZ4_setStreamDecode = function(LZ4_streamDecode: LZ4_streamDecode_t; dictionary: Pointer; dictSize: int): int; cdecl;
  TLZ4_decoderRingBufferSize = function (maxBlockSize: int): int; cdecl;
  TLZ4_decompress_safe_continue = function(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; srcSize, dstCapacity: int): int; cdecl;
  TLZ4_decompress_fast_continue = function(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; originalSize: int): int; cdecl;
  TLZ4_decompress_safe_usingDict = function(src, dst: Pointer; srcSize, dstCapcity: int; dictStart: Pointer; dictSize: int): int; cdecl;
  TLZ4_decompress_fast_usingDict = function: unsigned; cdecl;

  TLZ4_compress_HC = function(src, dst: Pointer; srcSize, dstCapacity, compressionLevel: int): int; cdecl;
  TLZ4_sizeofStateHC = function: int; cdecl;
  TLZ4_compress_HC_extStateHC = function(state, src, dst: Pointer; srcSize, maxDstSize, compressionLevel: int): int; cdecl;
  TLZ4_createStreamHC = function: LZ4_streamHC_t; cdecl;
  TLZ4_freeStreamHC = function(streamHCPtr: LZ4_streamHC_t): int; cdecl;
  TLZ4_resetStreamHC = procedure(streamHCPtr: LZ4_streamHC_t; compressionLevel: int); cdecl;
  TLZ4_loadDictHC = function(streamHCPtr: LZ4_streamHC_t; dictionary: Pointer; dictSize: int): int; cdecl;
  TLZ4_compress_HC_continue = function(streamHCPtr: LZ4_streamHC_t; src, dst: Pointer; srcSize, maxDstSize: int): int; cdecl;
  TLZ4_saveDictHC = function(streamHCPtr: LZ4_streamHC_t; safeBuffer: Pointer; maxDictSize: int): int; cdecl;

  TLZ4F_isError = function(code: LZ4F_errorCode_t): unsigned; cdecl;
  TLZ4F_getErrorName = function(code: LZ4F_errorCode_t): PAnsiChar; cdecl;
  TLZ4F_compressionLevel_max = function: int; cdecl;
  TLZ4F_compressFrameBound = function(srcSize: size_t; preferencesPtr: PLZ4F_preferences_t): size_t; cdecl;
  TLZ4F_compressFrame = function(dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; const preferencesPtr: LZ4F_preferences_t): size_t; cdecl;
  TLZ4F_getVersion = function: unsigned; cdecl;
  TLZ4F_createCompressionContext = function(out cctxPtr: LZ4F_cctx; version: unsigned): LZ4F_errorCode_t; cdecl;
  TLZ4F_freeCompressionContext = function(cctx: LZ4F_cctx): LZ4F_errorCode_t; cdecl;
  TLZ4F_compressBegin = function(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; prefsPtr: PLZ4F_preferences_t): size_t; cdecl;
  TLZ4F_compressBound = function(srcSize: size_t; prefsPtr: PLZ4F_preferences_t): size_t; cdecl;
  TLZ4F_compressUpdate = function(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; cdecl;
  TLZ4F_flush = function(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; cdecl;
  TLZ4F_compressEnd = function(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t; cdecl;
  TLZ4F_createDecompressionContext = function(out dctxPtr: LZ4F_dctx; version: unsigned): LZ4F_errorCode_t; cdecl;
  TLZ4F_freeDecompressionContext = function(dctx: LZ4F_dctx): LZ4F_errorCode_t; cdecl;
  TLZ4F_getFrameInfo = function(dctx: LZ4F_dctx; out frameInfoPtr: LZ4F_frameInfo_t; srcBuffer: Pointer; out srcSizePtr: size_t): size_t; cdecl;
  TLZ4F_decompress = function(dctx: LZ4F_dctx; dstBuffer: Pointer; var dstSizePtr: size_t; srcBuffer: Pointer; var srcSizePtr: size_t; const dOptPtr: PLZ4F_decompressOptions_t): size_t; cdecl;
  TLZ4F_resetDecompressionContext = procedure(dctx: LZ4F_dctx); cdecl;

var
  LZ4Lock: TRTLCriticalSection;
  LZ4: HMODULE;

  _LZ4_versionNumber: TLZ4_versionNumber;
  _LZ4_versionString: TLZ4_versionString;
  _LZ4_compress_default: TLZ4_compress_default;
  _LZ4_decompress_safe: TLZ4_decompress_safe;
  _LZ4_compressBound: TLZ4_compressBound;
  _LZ4_compress_fast: TLZ4_compress_fast;
  _LZ4_sizeofState: TLZ4_sizeofState;
  _LZ4_compress_fast_extState: TLZ4_compress_fast_extState;
  _LZ4_compress_destSize: TLZ4_compress_destSize;
  _LZ4_decompress_fast: TLZ4_decompress_fast;
  _LZ4_decompress_safe_partial: TLZ4_decompress_safe_partial;
  _LZ4_createStream: TLZ4_createStream;
  _LZ4_freeStream: TLZ4_freeStream;
  _LZ4_resetStream: TLZ4_resetStream;
  _LZ4_loadDict: TLZ4_loadDict;
  _LZ4_compress_fast_continue: TLZ4_compress_fast_continue;
  _LZ4_saveDict: TLZ4_saveDict;
  _LZ4_createStreamDecode: TLZ4_createStreamDecode;
  _LZ4_freeStreamDecode: TLZ4_freeStreamDecode;
  _LZ4_setStreamDecode: TLZ4_setStreamDecode;
  _LZ4_decoderRingBufferSize: TLZ4_decoderRingBufferSize;
  _LZ4_decompress_safe_continue: TLZ4_decompress_safe_continue;
  _LZ4_decompress_fast_continue: TLZ4_decompress_fast_continue;
  _LZ4_decompress_safe_usingDict: TLZ4_decompress_safe_usingDict;
  _LZ4_decompress_fast_usingDict: TLZ4_decompress_fast_usingDict;
  _LZ4_compress_HC: TLZ4_compress_HC;
  _LZ4_sizeofStateHC: TLZ4_sizeofStateHC;
  _LZ4_compress_HC_extStateHC: TLZ4_compress_HC_extStateHC;
  _LZ4_createStreamHC: TLZ4_createStreamHC;
  _LZ4_freeStreamHC: TLZ4_freeStreamHC;
  _LZ4_resetStreamHC: TLZ4_resetStreamHC;
  _LZ4_loadDictHC: TLZ4_loadDictHC;
  _LZ4_compress_HC_continue: TLZ4_compress_HC_continue;
  _LZ4_saveDictHC: TLZ4_saveDictHC;

  _LZ4F_isError: TLZ4F_isError;
  _LZ4F_getErrorName: TLZ4F_getErrorName;
  _LZ4F_compressionLevel_max: TLZ4F_compressionLevel_max;
  _LZ4F_compressFrameBound: TLZ4F_compressFrameBound;
  _LZ4F_compressFrame: TLZ4F_compressFrame;
  _LZ4F_getVersion: TLZ4F_getVersion;
  _LZ4F_createCompressionContext: TLZ4F_createCompressionContext;
  _LZ4F_freeCompressionContext: TLZ4F_freeCompressionContext;
  _LZ4F_compressBegin: TLZ4F_compressBegin;
  _LZ4F_compressBound: TLZ4F_compressBound;
  _LZ4F_compressUpdate: TLZ4F_compressUpdate;
  _LZ4F_flush: TLZ4F_flush;
  _LZ4F_compressEnd: TLZ4F_compressEnd;
  _LZ4F_createDecompressionContext: TLZ4F_createDecompressionContext;
  _LZ4F_freeDecompressionContext: TLZ4F_freeDecompressionContext;
  _LZ4F_getFrameInfo: TLZ4F_getFrameInfo;
  _LZ4F_decompress: TLZ4F_decompress;
  _LZ4F_resetDecompressionContext: TLZ4F_resetDecompressionContext;

procedure InitLZ4;
begin
  EnterCriticalSection(LZ4Lock);
  try
    if LZ4 <> 0 then Exit;
    LZ4 := LoadLibraryW(PWideChar(LZ4DllName));
    if LZ4 = 0 then Exit;

    @_LZ4_versionNumber := GetProcAddress(LZ4, sLZ4_versionNumber);
    @_LZ4_versionString := GetProcAddress(LZ4, sLZ4_versionString);
    @_LZ4_compress_default := GetProcAddress(LZ4, sLZ4_compress_default);
    @_LZ4_decompress_safe := GetProcAddress(LZ4, sLZ4_decompress_safe);
    @_LZ4_compressBound := GetProcAddress(LZ4, sLZ4_compressBound);
    @_LZ4_compress_fast := GetProcAddress(LZ4, sLZ4_compress_fast);
    @_LZ4_sizeofState := GetProcAddress(LZ4, sLZ4_sizeofState);
    @_LZ4_compress_fast_extState := GetProcAddress(LZ4, sLZ4_compress_fast_extState);
    @_LZ4_compress_destSize := GetProcAddress(LZ4, sLZ4_compress_destSize);
    @_LZ4_decompress_fast := GetProcAddress(LZ4, sLZ4_decompress_fast);
    @_LZ4_decompress_safe_partial := GetProcAddress(LZ4, sLZ4_decompress_safe_partial);
    @_LZ4_createStream := GetProcAddress(LZ4, sLZ4_createStream);
    @_LZ4_resetStream := GetProcAddress(LZ4, sLZ4_resetStream);
    @_LZ4_loadDict := GetProcAddress(LZ4, sLZ4_loadDict);
    @_LZ4_compress_fast_continue := GetProcAddress(LZ4, sLZ4_compress_fast_continue);
    @_LZ4_saveDict := GetProcAddress(LZ4, sLZ4_saveDict);
    @_LZ4_createStreamDecode := GetProcAddress(LZ4, sLZ4_createStreamDecode);
    @_LZ4_freeStreamDecode := GetProcAddress(LZ4, sLZ4_freeStreamDecode);
    @_LZ4_setStreamDecode := GetProcAddress(LZ4, sLZ4_setStreamDecode);
    @_LZ4_decoderRingBufferSize := GetProcAddress(LZ4, sLZ4_decoderRingBufferSize);
    @_LZ4_decompress_safe_continue := GetProcAddress(LZ4, sLZ4_decompress_safe_continue);
    @_LZ4_decompress_fast_continue := GetProcAddress(LZ4, sLZ4_decompress_fast_continue);
    @_LZ4_decompress_safe_usingDict := GetProcAddress(LZ4, sLZ4_decompress_safe_usingDict);

    @_LZ4_compress_HC := GetProcAddress(LZ4, sLZ4_compress_HC);
    @_LZ4_sizeofStateHC := GetProcAddress(LZ4, sLZ4_sizeofStateHC);
    @_LZ4_compress_HC_extStateHC := GetProcAddress(LZ4, sLZ4_compress_HC_extStateHC);
    @_LZ4_createStreamHC := GetProcAddress(LZ4, sLZ4_createStreamHC);
    @_LZ4_freeStreamHC := GetProcAddress(LZ4, sLZ4_freeStreamHC);
    @_LZ4_resetStreamHC := GetProcAddress(LZ4, sLZ4_resetStreamHC);
    @_LZ4_loadDictHC := GetProcAddress(LZ4, sLZ4_loadDictHC);
    @_LZ4_compress_HC_continue := GetProcAddress(LZ4, sLZ4_compress_HC_continue);
    @_LZ4_saveDictHC := GetProcAddress(LZ4, sLZ4_saveDictHC);

    @_LZ4F_isError := GetProcAddress(LZ4, sLZ4F_isError);
    @_LZ4F_getErrorName := GetProcAddress(LZ4, sLZ4F_getErrorName);
    @_LZ4F_compressionLevel_max := GetProcAddress(LZ4, sLZ4F_compressionLevel_max);
    @_LZ4F_compressFrameBound := GetProcAddress(LZ4, sLZ4F_compressFrameBound);
    @_LZ4F_compressFrame := GetProcAddress(LZ4, sLZ4F_compressFrame);
    @_LZ4F_getVersion := GetProcAddress(LZ4, sLZ4F_getVersion);
    @_LZ4F_createCompressionContext := GetProcAddress(LZ4, sLZ4F_createCompressionContext);
    @_LZ4F_freeCompressionContext := GetProcAddress(LZ4, sLZ4F_freeCompressionContext);
    @_LZ4F_compressBegin := GetProcAddress(LZ4, sLZ4F_compressBegin);
    @_LZ4F_compressBound := GetProcAddress(LZ4, sLZ4F_compressBound);
    @_LZ4F_compressUpdate := GetProcAddress(LZ4, sLZ4F_compressUpdate);
    @_LZ4F_flush := GetProcAddress(LZ4, sLZ4F_flush);
    @_LZ4F_compressEnd := GetProcAddress(LZ4, sLZ4F_compressEnd);
    @_LZ4F_createDecompressionContext := GetProcAddress(LZ4, sLZ4F_createDecompressionContext);
    @_LZ4F_freeDecompressionContext := GetProcAddress(LZ4, sLZ4F_freeDecompressionContext);
    @_LZ4F_getFrameInfo := GetProcAddress(LZ4, sLZ4F_getFrameInfo);
    @_LZ4F_decompress := GetProcAddress(LZ4, sLZ4F_decompress);
    @_LZ4F_resetDecompressionContext := GetProcAddress(LZ4, sLZ4F_resetDecompressionContext);
  finally
    LeaveCriticalSection(LZ4Lock);
  end;
end;

procedure DoneLZ4;
begin
  if LZ4 <> 0 then FreeLibrary(LZ4);
end;

function LZ4_versionNumber: int;
begin
  InitLZ4;
  if Assigned(@_LZ4_versionNumber) then
    Result := _LZ4_versionNumber
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_versionString: PAnsiChar;
begin
  InitLZ4;
  if Assigned(@_LZ4_versionString) then
    Result := _LZ4_versionString
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_default(src, dst: Pointer; srcSize, dstCapacity: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_default) then
    Result := _LZ4_compress_default(src, dst, srcSize, dstCapacity)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_safe(src, dst: Pointer; compressedSize, dstCapacity: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_safe) then
    Result := _LZ4_decompress_safe(src, dst, compressedSize, dstCapacity)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compressBound(inputSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compressBound) then
    Result := _LZ4_compressBound(inputSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_fast(src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_fast) then
    Result := _LZ4_compress_fast(src, dst, srcSize, dstCapacity, acceleration)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_sizeofState: int;
begin
  InitLZ4;
  if Assigned(@_LZ4_sizeofState) then
    Result := _LZ4_sizeofState
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_fast_extState(state, src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_fast_extState) then
    Result := _LZ4_compress_fast_extState(state, src, dst, srcSize, dstCapacity, acceleration)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_destSize(src, dst: Pointer; var srcSizePtr: int; targetDstSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_destSize) then
    Result := _LZ4_compress_destSize(src, dst, srcSizePtr, targetDstSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_fast(src, dst: Pointer; originalSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_fast) then
    Result := _LZ4_decompress_fast(src, dst, originalSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_safe_partial(src, dst: Pointer; srcSize, targetOutputSize, dstCapacity: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_safe_partial) then
    Result := _LZ4_decompress_safe_partial(src, dst, srcSize, targetOutputSize, dstCapacity)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_createStream: LZ4_stream_t;
begin
  InitLZ4;
  if Assigned(@_LZ4_createStream) then
    Result := _LZ4_createStream
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_freeStream(streamPtr: LZ4_stream_t): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_freeStream) then
    Result := _LZ4_freeStream(streamPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

procedure LZ4_resetStream(streamPtr: LZ4_stream_t);
begin
  InitLZ4;
  if Assigned(@_LZ4_resetStream) then
    _LZ4_resetStream(streamPtr)
  else
    begin RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_loadDict(streamPtr: LZ4_stream_t; dictionary: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_loadDict) then
    Result := _LZ4_loadDict(streamPtr, dictionary, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_fast_continue(streamPtr: LZ4_stream_t; src, dst: Pointer; srcSize, dstCapacity, acceleration: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_fast_continue) then
    Result := _LZ4_compress_fast_continue(streamPtr, src, dst, srcSize, dstCapacity, acceleration)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_saveDict(streamPtr: LZ4_stream_t; safeBuffer: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_saveDict) then
    Result := _LZ4_saveDict(streamPtr, safeBuffer, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_createStreamDecode: LZ4_streamDecode_t;
begin
  InitLZ4;
  if Assigned(@_LZ4_createStreamDecode) then
    Result := _LZ4_createStreamDecode
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_freeStreamDecode(LZ4_stream: LZ4_streamDecode_t): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_freeStreamDecode) then
    Result := _LZ4_freeStreamDecode(LZ4_stream)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_setStreamDecode(LZ4_streamDecode: LZ4_streamDecode_t; dictionary: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_setStreamDecode) then
    Result := _LZ4_setStreamDecode(LZ4_streamDecode, dictionary, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decoderRingBufferSize(maxBlockSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decoderRingBufferSize) then
    Result := _LZ4_decoderRingBufferSize(maxBlockSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_safe_continue(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; srcSize, dstCapacity: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_safe_continue) then
    Result := _LZ4_decompress_safe_continue(LZ4_streamDecode, src, dst, srcSize, dstCapacity)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_fast_continue(LZ4_streamDecode: LZ4_streamDecode_t; src, dst: Pointer; originalSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_fast_continue) then
    Result := _LZ4_decompress_fast_continue(LZ4_streamDecode, src, dst, originalSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_safe_usingDict(src, dst: Pointer; srcSize, dstCapcity: int; dictStart: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_safe_usingDict) then
    Result := _LZ4_decompress_safe_usingDict(src, dst, srcSize, dstCapcity, dictStart, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_decompress_fast_usingDict(src, dst: Pointer; originalSize: int; dictStart: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_decompress_fast_usingDict) then
    Result := _LZ4_decompress_fast_usingDict
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_HC(src, dst: Pointer; srcSize, dstCapacity, compressionLevel: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_HC) then
    Result := _LZ4_compress_HC(src, dst, srcSize, dstCapacity, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_sizeofStateHC: int;
begin
  InitLZ4;
  if Assigned(@_LZ4_sizeofStateHC) then
    Result := _LZ4_sizeofStateHC
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_HC_extStateHC(state, src, dst: Pointer; srcSize, maxDstSize, compressionLevel: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_HC_extStateHC) then
    Result := _LZ4_compress_HC_extStateHC(state, src, dst, srcSize, maxDstSize, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_createStreamHC: LZ4_streamHC_t;
begin
  InitLZ4;
  if Assigned(@_LZ4_createStreamHC) then
    Result := _LZ4_createStreamHC
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_freeStreamHC(streamHCPtr: LZ4_streamHC_t): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_freeStreamHC) then
    Result := _LZ4_freeStreamHC(streamHCPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

procedure LZ4_resetStreamHC(streamHCPtr: LZ4_streamHC_t; compressionLevel: int);
begin
  InitLZ4;
  if Assigned(@_LZ4_resetStreamHC) then
    _LZ4_resetStreamHC(streamHCPtr, compressionLevel)
  else
    begin RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_loadDictHC(streamHCPtr: LZ4_streamHC_t; dictionary: Pointer; dictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_loadDictHC) then
    Result := _LZ4_loadDictHC(streamHCPtr, dictionary, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_compress_HC_continue(streamHCPtr: LZ4_streamHC_t; src, dst: Pointer; srcSize, maxDstSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_compress_HC_continue) then
    Result := _LZ4_compress_HC_continue(streamHCPtr, src, dst, srcSize, maxDstSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4_saveDictHC(streamHCPtr: LZ4_streamHC_t; safeBuffer: Pointer; maxDictSize: int): int;
begin
  InitLZ4;
  if Assigned(@_LZ4_saveDictHC) then
    Result := _LZ4_saveDictHC(streamHCPtr, safeBuffer, maxDictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_isError(code: LZ4F_errorCode_t): unsigned;
begin
  InitLZ4;
  if Assigned(@_LZ4F_isError) then
    Result := _LZ4F_isError(code)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_getErrorName(code: LZ4F_errorCode_t): PAnsiChar;
begin
  InitLZ4;
  if Assigned(@_LZ4F_getErrorName) then
    Result := _LZ4F_getErrorName(code)
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressionLevel_max: int;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressionLevel_max) then
    Result := _LZ4F_compressionLevel_max
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressFrameBound(srcSize: size_t; preferencesPtr: PLZ4F_preferences_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressFrameBound) then
    Result := _LZ4F_compressFrameBound(srcSize, preferencesPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressFrame(dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; const preferencesPtr: LZ4F_preferences_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressFrame) then
    Result := _LZ4F_compressFrame(dstBuffer, dstCapacity, srcBuffer, srcSize, preferencesPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_getVersion: unsigned;
begin
  InitLZ4;
  if Assigned(@_LZ4F_getVersion) then
    Result := _LZ4F_getVersion
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_createCompressionContext(out cctxPtr: LZ4F_cctx; version: unsigned): LZ4F_errorCode_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_createCompressionContext) then
    Result := _LZ4F_createCompressionContext(cctxPtr, version)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_freeCompressionContext(cctx: LZ4F_cctx): LZ4F_errorCode_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_freeCompressionContext) then
    Result := _LZ4F_freeCompressionContext(cctx)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressBegin(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; prefsPtr: PLZ4F_preferences_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressBegin) then
    Result := _LZ4F_compressBegin(cctx, dstBuffer, dstCapacity, prefsPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressBound(srcSize: size_t; prefsPtr: PLZ4F_preferences_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressBound) then
    Result := _LZ4F_compressBound(srcSize, prefsPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressUpdate(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; srcBuffer: Pointer; srcSize: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressUpdate) then
    Result := _LZ4F_compressUpdate(cctx, dstBuffer, dstCapacity, srcBuffer, srcSize, cOptPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_flush(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_flush) then
    Result := _LZ4F_flush(cctx, dstBuffer, dstCapacity, cOptPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_compressEnd(cctx: LZ4F_cctx; dstBuffer: Pointer; dstCapacity: size_t; cOptPtr: PLZ4F_compressOptions_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_compressEnd) then
    Result := _LZ4F_compressEnd(cctx, dstBuffer, dstCapacity, cOptPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_createDecompressionContext(out dctxPtr: LZ4F_dctx; version: unsigned): LZ4F_errorCode_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_createDecompressionContext) then
    Result := _LZ4F_createDecompressionContext(dctxPtr, version)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_freeDecompressionContext(dctx: LZ4F_dctx): LZ4F_errorCode_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_freeDecompressionContext) then
    Result := _LZ4F_freeDecompressionContext(dctx)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_getFrameInfo(dctx: LZ4F_dctx; out frameInfoPtr: LZ4F_frameInfo_t; srcBuffer: Pointer; out srcSizePtr: size_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_getFrameInfo) then
    Result := _LZ4F_getFrameInfo(dctx, frameInfoPtr, srcBuffer, srcSizePtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function LZ4F_decompress(dctx: LZ4F_dctx; dstBuffer: Pointer; var dstSizePtr: size_t; srcBuffer: Pointer; var srcSizePtr: size_t; dOptPtr: PLZ4F_decompressOptions_t): size_t;
begin
  InitLZ4;
  if Assigned(@_LZ4F_decompress) then
    Result := _LZ4F_decompress(dctx, dstBuffer, dstSizePtr, srcBuffer, srcSizePtr, dOptPtr)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

procedure LZ4F_resetDecompressionContext(dctx: LZ4F_dctx);
begin
  InitLZ4;
  if Assigned(@_LZ4F_resetDecompressionContext) then
    _LZ4F_resetDecompressionContext(dctx)
  else
    begin RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

initialization
  InitializeCriticalSection(LZ4Lock);
  LZ4 := 0;

finalization
  DoneLZ4;
  DeleteCriticalSection(LZ4Lock);
{$ENDIF}

end.
