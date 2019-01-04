unit ZSTDLib;

{ $DEFINE STATIC_LINKING}

interface

uses
  Windows, SysUtils;

{$Z4}

{$IFDEF STATIC_LINKING}
const
  ZSTDDllName = 'libzstd.dll';
{$ELSE}
var
  ZSTDDllName: UnicodeString;
{$ENDIF}

const
  sZSTD_versionNumber                       = 'ZSTD_versionNumber';
  sZSTD_versionString                       = 'ZSTD_versionString';
  sZSTD_compress                            = 'ZSTD_compress';
  sZSTD_decompress                          = 'ZSTD_decompress';
  sZSTD_getFrameContentSize                 = 'ZSTD_getFrameContentSize';
  sZSTD_getDecompressedSize                 = 'ZSTD_getDecompressedSize';
  sZSTD_compressBound                       = 'ZSTD_compressBound';
  sZSTD_isError                             = 'ZSTD_isError';
  sZSTD_getErrorName                        = 'ZSTD_getErrorName';
  sZSTD_maxCLevel                           = 'ZSTD_maxCLevel';
  sZSTD_createCCtx                          = 'ZSTD_createCCtx';
  sZSTD_freeCCtx                            = 'ZSTD_freeCCtx';
  sZSTD_compressCCtx                        = 'ZSTD_compressCCtx';
  sZSTD_createDCtx                          = 'ZSTD_createDCtx';
  sZSTD_freeDCtx                            = 'ZSTD_freeDCtx';
  sZSTD_decompressDCtx                      = 'ZSTD_decompressDCtx';
  sZSTD_compress_usingDict                  = 'ZSTD_compress_usingDict';
  sZSTD_decompress_usingDict                = 'ZSTD_decompress_usingDict';
  sZSTD_createCDict                         = 'ZSTD_createCDict';
  sZSTD_freeCDict                           = 'ZSTD_freeCDict';
  sZSTD_compress_usingCDict                 = 'ZSTD_compress_usingCDict';
  sZSTD_createDDict                         = 'ZSTD_createDDict';
  sZSTD_freeDDict                           = 'ZSTD_freeDDict';
  sZSTD_decompress_usingDDict               = 'ZSTD_decompress_usingDDict';
  sZSTD_createCStream                       = 'ZSTD_createCStream';
  sZSTD_freeCStream                         = 'ZSTD_freeCStream';
  sZSTD_initCStream                         = 'ZSTD_initCStream';
  sZSTD_compressStream                      = 'ZSTD_compressStream';
  sZSTD_flushStream                         = 'ZSTD_flushStream';
  sZSTD_endStream                           = 'ZSTD_endStream';
  sZSTD_CStreamInSize                       = 'ZSTD_CStreamInSize';
  sZSTD_CStreamOutSize                      = 'ZSTD_CStreamOutSize';
  sZSTD_createDStream                       = 'ZSTD_createDStream';
  sZSTD_freeDStream                         = 'ZSTD_freeDStream';
  sZSTD_initDStream                         = 'ZSTD_initDStream';
  sZSTD_decompressStream                    = 'ZSTD_decompressStream';
  sZSTD_DStreamInSize                       = 'ZSTD_DStreamInSize';
  sZSTD_DStreamOutSize                      = 'ZSTD_DStreamOutSize';

type
  EZSTDException = class(Exception)
  public
    constructor Create(const AFunctionName: string; ACode: ssize_t);
  private
    FCode: SSIZE_T
  end;

procedure ZSTDError(const AFunctionName: string; ACode: size_t);
function ZSTDCheck(const AFunctionName: string; ACode: size_t): size_t;

type
  unsigned = DWORD;
  int = Integer;

function ZSTD_versionNumber: unsigned; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_versionNumber;{$ENDIF}
function ZSTD_versionString: PAnsiChar; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_versionString;{$ENDIF}

(***************************************
*  Default constant
***************************************)

const
  ZSTD_CLEVEL_DEFAULT = 3;


(***************************************
*  Simple API
***************************************)

(*! ZSTD_compress() :
 *  Compresses `src` content as a single zstd compressed frame into already allocated `dst`.
 *  Hint : compression runs faster if `dstCapacity` >=  `ZSTD_compressBound(srcSize)`.
 *  @return : compressed size written into `dst` (<= `dstCapacity),
 *            or an error code if it fails (which can be tested using ZSTD_isError()). *)
function ZSTD_compress(dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compress;{$ENDIF}

(*! ZSTD_decompress() :
 *  `compressedSize` : must be the _exact_ size of some number of compressed and/or skippable frames.
 *  `dstCapacity` is an upper bound of originalSize to regenerate.
 *  If user cannot imply a maximum upper bound, it's better to use streaming mode to decompress data.
 *  @return : the number of bytes decompressed into `dst` (<= `dstCapacity`),
 *            or an errorCode if it fails (which can be tested using ZSTD_isError()). *)
function ZSTD_decompress(dst: Pointer; dstCapacity: size_t; src: Pointer; compressedSize: size_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_decompress;{$ENDIF}

(*! ZSTD_getFrameContentSize() : requires v1.3.0+
 *  `src` should point to the start of a ZSTD encoded frame.
 *  `srcSize` must be at least as large as the frame header.
 *            hint : any size >= `ZSTD_frameHeaderSize_max` is large enough.
 *  @return : - decompressed size of `src` frame content, if known
 *            - ZSTD_CONTENTSIZE_UNKNOWN if the size cannot be determined
 *            - ZSTD_CONTENTSIZE_ERROR if an error occurred (e.g. invalid magic number, srcSize too small)
 *   note 1 : a 0 return value means the frame is valid but "empty".
 *   note 2 : decompressed size is an optional field, it may not be present, typically in streaming mode.
 *            When `return==ZSTD_CONTENTSIZE_UNKNOWN`, data to decompress could be any size.
 *            In which case, it's necessary to use streaming mode to decompress data.
 *            Optionally, application can rely on some implicit limit,
 *            as ZSTD_decompress() only needs an upper bound of decompressed size.
 *            (For example, data could be necessarily cut into blocks <= 16 KB).
 *   note 3 : decompressed size is always present when compression is completed using single-pass functions,
 *            such as ZSTD_compress(), ZSTD_compressCCtx() ZSTD_compress_usingDict() or ZSTD_compress_usingCDict().
 *   note 4 : decompressed size can be very large (64-bits value),
 *            potentially larger than what local system can handle as a single memory segment.
 *            In which case, it's necessary to use streaming mode to decompress data.
 *   note 5 : If source is untrusted, decompressed size could be wrong or intentionally modified.
 *            Always ensure return value fits within application's authorized limits.
 *            Each application can set its own limits.
 *   note 6 : This function replaces ZSTD_getDecompressedSize() *)

const
  ZSTD_CONTENTSIZE_UNKNOWN = -1;
  ZSTD_CONTENTSIZE_ERROR   = -2;

function ZSTD_getFrameContentSize(src: Pointer; srcSize: size_t): Int64; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_getFrameContentSize;{$ENDIF}

(*! ZSTD_getDecompressedSize() :
 *  NOTE: This function is now obsolete, in favor of ZSTD_getFrameContentSize().
 *  Both functions work the same way, but ZSTD_getDecompressedSize() blends
 *  "empty", "unknown" and "error" results to the same return value (0),
 *  while ZSTD_getFrameContentSize() gives them separate return values.
 * @return : decompressed size of `src` frame content _if known and not empty_, 0 otherwise. *)
function ZSTD_getDecompressedSize(src: Pointer; srcSize: size_t): Int64; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_getDecompressedSize;{$ENDIF}

(*======  Helper functions  ======*)

function ZSTD_compressBound(srcSize: size_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compressBound;{$ENDIF}(*!< maximum compressed size in worst case single-pass scenario *)
function ZSTD_isError(code: size_t): unsigned; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_isError;{$ENDIF}       (*!< tells if a `size_t` function result is an error code *)
function ZSTD_getErrorName(code: size_t): PAnsiChar; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_getErrorName;{$ENDIF} (*!< provides readable string from an error code *)
function ZSTD_maxCLevel: int; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_maxCLevel;{$ENDIF}

(***************************************
*  Explicit context
***************************************)

(*= Compression context
 *  When compressing many times,
 *  it is recommended to allocate a context just once, and re-use it for each successive compression operation.
 *  This will make workload friendlier for system's memory.
 *  Use one context per thread for parallel execution in multi-threaded environments. *)

type
  ZSTD_CCtx = type Pointer;

function ZSTD_createCCtx: ZSTD_CCtx; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createCCtx;{$ENDIF}
function ZSTD_freeCCtx(cctx: ZSTD_CCtx): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeCCtx;{$ENDIF}

(*! ZSTD_compressCCtx() :
 *  Same as ZSTD_compress(), using an explicit ZSTD_CCtx
 *  The function will compress at requested compression level,
 *  ignoring any other parameter *)
function ZSTD_compressCCtx(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compressCCtx;{$ENDIF}

(*= Decompression context
 *  When decompressing many times,
 *  it is recommended to allocate a context only once,
 *  and re-use it for each successive compression operation.
 *  This will make workload friendlier for system's memory.
 *  Use one context per thread for parallel execution. *)

type
  ZSTD_DCtx = type Pointer;

function ZSTD_createDCtx: ZSTD_DCtx; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createDCtx;{$ENDIF}
function ZSTD_freeDCtx(dctx: ZSTD_DCtx): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeDCtx;{$ENDIF}

(*! ZSTD_decompressDCtx() :
 *  Same as ZSTD_decompress(),
 *  requires an allocated ZSTD_DCtx.
 *  Compatible with sticky parameters.
 *)
function ZSTD_decompressDCtx(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_decompressDCtx;{$ENDIF}

(**************************
*  Simple dictionary API
***************************)

(*! ZSTD_compress_usingDict() :
 *  Compression at an explicit compression level using a Dictionary.
 *  A dictionary can be any arbitrary data segment (also called a prefix),
 *  or a buffer with specified information (see dictBuilder/zdict.h).
 *  Note : This function loads the dictionary, resulting in significant startup delay.
 *         It's intended for a dictionary used only once.
 *  Note 2 : When `dict == NULL || dictSize < 8` no dictionary is used. *)
function ZSTD_compress_usingDict(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t; compressionLevel: int): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compress_usingDict;{$ENDIF}

(*! ZSTD_decompress_usingDict() :
 *  Decompression using a known Dictionary.
 *  Dictionary must be identical to the one used during compression.
 *  Note : This function loads the dictionary, resulting in significant startup delay.
 *         It's intended for a dictionary used only once.
 *  Note : When `dict == NULL || dictSize < 8` no dictionary is used. *)
function ZSTD_decompress_usingDict(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_decompress_usingDict;{$ENDIF}

(**********************************
 *  Bulk processing dictionary API
 *********************************)

type
  ZSTD_CDict = type Pointer;

(*! ZSTD_createCDict() :
 *  When compressing multiple messages / blocks using the same dictionary, it's recommended to load it only once.
 *  ZSTD_createCDict() will create a digested dictionary, ready to start future compression operations without startup cost.
 *  ZSTD_CDict can be created once and shared by multiple threads concurrently, since its usage is read-only.
 * `dictBuffer` can be released after ZSTD_CDict creation, because its content is copied within CDict.
 *  Consider experimental function `ZSTD_createCDict_byReference()` if you prefer to not duplicate `dictBuffer` content.
 *  Note : A ZSTD_CDict can be created from an empty dictBuffer, but it is inefficient when used to compress small data. *)
function ZSTD_createCDict(dictBuffer: Pointer; dictSize: size_t; compressionLevel: int): ZSTD_CDict; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createCDict;{$ENDIF}

(*! ZSTD_freeCDict() :
 *  Function frees memory allocated by ZSTD_createCDict(). *)
function ZSTD_freeCDict(CDict: ZSTD_CDict): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeCDict;{$ENDIF}

(*! ZSTD_compress_usingCDict() :
 *  Compression using a digested Dictionary.
 *  Recommended when same dictionary is used multiple times.
 *  Note : compression level is _decided at dictionary creation time_,
 *     and frame parameters are hardcoded (dictID=yes, contentSize=yes, checksum=no) *)
function ZSTD_compress_usingCDict(cctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; cdict: ZSTD_CDict): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compress_usingCDict;{$ENDIF}

type
  ZSTD_DDict = type Pointer;

(*! ZSTD_createDDict() :
 *  Create a digested dictionary, ready to start decompression operation without startup delay.
 *  dictBuffer can be released after DDict creation, as its content is copied inside DDict. *)
function ZSTD_createDDict(dictBuffer: Pointer; dictSize: size_t): ZSTD_DDict; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createDDict;{$ENDIF}

(*! ZSTD_freeDDict() :
 *  Function frees memory allocated with ZSTD_createDDict() *)
function ZSTD_freeDDict(ddict: ZSTD_DDict): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeDDict;{$ENDIF}

(*! ZSTD_decompress_usingDDict() :
 *  Decompression using a digested Dictionary.
 *  Recommended when same dictionary is used multiple times. *)
function ZSTD_decompress_usingDDict(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; ddict: ZSTD_DDict): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_decompress_usingDDict;{$ENDIF}

(****************************
*  Streaming
****************************)

type
  ZSTD_inBuffer = record
    src: Pointer;    (**< start of input buffer *)
    size: size_t;    (**< size of input buffer *)
    pos: size_t;     (**< position where reading stopped. Will be updated. Necessarily 0 <= pos <= size *)
  end;

  ZSTD_outBuffer = record
    dst: Pointer;    (**< start of output buffer *)
    size: size_t;    (**< size of output buffer *)
    pos: size_t;     (**< position where writing stopped. Will be updated. Necessarily 0 <= pos <= size *)
  end;

(*-***********************************************************************
*  Streaming compression - HowTo
*
*  A ZSTD_CStream object is required to track streaming operation.
*  Use ZSTD_createCStream() and ZSTD_freeCStream() to create/release resources.
*  ZSTD_CStream objects can be reused multiple times on consecutive compression operations.
*  It is recommended to re-use ZSTD_CStream since it will play nicer with system's memory, by re-using already allocated memory.
*
*  For parallel execution, use one separate ZSTD_CStream per thread.
*
*  note : since v1.3.0, ZSTD_CStream and ZSTD_CCtx are the same thing.
*
*  Parameters are sticky : when starting a new compression on the same context,
*  it will re-use the same sticky parameters as previous compression session.
*  When in doubt, it's recommended to fully initialize the context before usage.
*  Use ZSTD_initCStream() to set the parameter to a selected compression level.
*  Use advanced API (ZSTD_CCtx_setParameter(), etc.) to set more specific parameters.
*
*  Use ZSTD_compressStream() as many times as necessary to consume input stream.
*  The function will automatically update both `pos` fields within `input` and `output`.
*  Note that the function may not consume the entire input,
*  for example, because the output buffer is already full,
*  in which case `input.pos < input.size`.
*  The caller must check if input has been entirely consumed.
*  If not, the caller must make some room to receive more compressed data,
*  and then present again remaining input data.
* @return : a size hint, preferred nb of bytes to use as input for next function call
*           or an error code, which can be tested using ZSTD_isError().
*           Note 1 : it's just a hint, to help latency a little, any value will work fine.
*           Note 2 : size hint is guaranteed to be <= ZSTD_CStreamInSize()
*
*  At any moment, it's possible to flush whatever data might remain stuck within internal buffer,
*  using ZSTD_flushStream(). `output->pos` will be updated.
*  Note that, if `output->size` is too small, a single invocation of ZSTD_flushStream() might not be enough (return code > 0).
*  In which case, make some room to receive more compressed data, and call again ZSTD_flushStream().
*  @return : 0 if internal buffers are entirely flushed,
*            >0 if some data still present within internal buffer (the value is minimal estimation of remaining size),
*            or an error code, which can be tested using ZSTD_isError().
*
*  ZSTD_endStream() instructs to finish a frame.
*  It will perform a flush and write frame epilogue.
*  The epilogue is required for decoders to consider a frame completed.
*  flush() operation is the same, and follows same rules as ZSTD_flushStream().
*  @return : 0 if frame fully completed and fully flushed,
*            >0 if some data still present within internal buffer (the value is minimal estimation of remaining size),
*            or an error code, which can be tested using ZSTD_isError().
*
* *******************************************************************)

type
  ZSTD_CStream = type ZSTD_CCtx;

(*===== ZSTD_CStream management functions =====*)
function ZSTD_createCStream: ZSTD_CStream; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createCStream;{$ENDIF}
function ZSTD_freeCStream(zcs: ZSTD_CStream): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeCStream;{$ENDIF}

(*===== Streaming compression functions =====*)
function ZSTD_initCStream(zcs: ZSTD_CStream; compressionLevel: int): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_initCStream;{$ENDIF}
function ZSTD_compressStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_compressStream;{$ENDIF}
function ZSTD_flushStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_flushStream;{$ENDIF}
function ZSTD_endStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_endStream;{$ENDIF}

function ZSTD_CStreamInSize: size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_CStreamInSize;{$ENDIF} (**< recommended size for input buffer *)
function ZSTD_CStreamOutSize: size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_CStreamOutSize;{$ENDIF} (**< recommended size for output buffer. Guarantee to successfully flush at least one complete compressed block in all circumstances. *)

(*-***************************************************************************
*  Streaming decompression - HowTo
*
*  A ZSTD_DStream object is required to track streaming operations.
*  Use ZSTD_createDStream() and ZSTD_freeDStream() to create/release resources.
*  ZSTD_DStream objects can be re-used multiple times.
*
*  Use ZSTD_initDStream() to start a new decompression operation.
* @return : recommended first input size
*  Alternatively, use advanced API to set specific properties.
*
*  Use ZSTD_decompressStream() repetitively to consume your input.
*  The function will update both `pos` fields.
*  If `input.pos < input.size`, some input has not been consumed.
*  It's up to the caller to present again remaining data.
*  The function tries to flush all data decoded immediately, respecting output buffer size.
*  If `output.pos < output.size`, decoder has flushed everything it could.
*  But if `output.pos == output.size`, there might be some data left within internal buffers.,
*  In which case, call ZSTD_decompressStream() again to flush whatever remains in the buffer.
*  Note : with no additional input provided, amount of data flushed is necessarily <= ZSTD_BLOCKSIZE_MAX.
* @return : 0 when a frame is completely decoded and fully flushed,
*        or an error code, which can be tested using ZSTD_isError(),
*        or any other value > 0, which means there is still some decoding or flushing to do to complete current frame :
*                                the return value is a suggested next input size (just a hint for better latency)
*                                that will never request more than the remaining frame size.
* *******************************************************************************)

type
  ZSTD_DStream = type ZSTD_DCtx;

(*===== ZSTD_DStream management functions =====*)
function ZSTD_createDStream: ZSTD_DStream; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_createDStream;{$ENDIF}
function ZSTD_freeDStream(zds: ZSTD_DStream): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_freeDStream;{$ENDIF}

(*===== Streaming decompression functions =====*)
function ZSTD_initDStream(zds: ZSTD_DStream): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_initDStream;{$ENDIF}
function ZSTD_decompressStream(zds: ZSTD_DStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_decompressStream;{$ENDIF}

function ZSTD_DStreamInSize: size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_DStreamInSize;{$ENDIF} (*!< recommended size for input buffer *)
function ZSTD_DStreamOutSize: size_t; {$IFDEF STATIC_LINKING}cdecl; external ZSTDDllName name sZSTD_DStreamOutSize;{$ENDIF} (*!< recommended size for output buffer. Guarantee to successfully flush at least one complete block in all circumstances. *)

implementation

const
  ZSTD_error_no_error                      = 0;
  ZSTD_error_GENERIC                       = 1;
  ZSTD_error_prefix_unknown                = 10;
  ZSTD_error_version_unsupported           = 12;
  ZSTD_error_frameParameter_unsupported    = 14;
  ZSTD_error_frameParameter_windowTooLarge = 16;
  ZSTD_error_corruption_detected           = 20;
  ZSTD_error_checksum_wrong                = 22;
  ZSTD_error_dictionary_corrupted          = 30;
  ZSTD_error_dictionary_wrong              = 32;
  ZSTD_error_dictionaryCreation_failed     = 34;
  ZSTD_error_parameter_unsupported         = 40;
  ZSTD_error_parameter_outOfBound          = 42;
  ZSTD_error_tableLog_tooLarge             = 44;
  ZSTD_error_maxSymbolValue_tooLarge       = 46;
  ZSTD_error_maxSymbolValue_tooSmall       = 48;
  ZSTD_error_stage_wrong                   = 60;
  ZSTD_error_init_missing                  = 62;
  ZSTD_error_memory_allocation             = 64;
  ZSTD_error_workSpace_tooSmall            = 66;
  ZSTD_error_dstSize_tooSmall              = 70;
  ZSTD_error_srcSize_wrong                 = 72;
  ZSTD_error_dstBuffer_null                = 74;

function GetExceptionMessage(const AFunctionName: string; ACode: ssize_t): string;
begin
  Result := AFunctionName + ' failed with error ' + IntToStr(ACode) + ': ' + string(ZSTD_getErrorName(ACode));
end;

constructor EZSTDException.Create(const AFunctionName: string; ACode: ssize_t);
begin
  FCode := ACode;
  inherited Create(GetExceptionMessage(AFunctionName, ACode));
end;

procedure ZSTDError(const AFunctionName: string; ACode: size_t);
begin
  case -ACode of
    ZSTD_error_memory_allocation:
      raise EOutOfMemory.Create(GetExceptionMessage(AFunctionName, ACode));
  else
    raise EZSTDException.Create(AFunctionName, ACode);
  end;
end;

function ZSTDCheck(const AFunctionName: string; ACode: size_t): size_t;
begin
  Result := ACode;
  if ZSTD_isError(ACode) <> 0 then
    ZSTDError(AFunctionName, ACode);
end;

{$IFNDEF STATIC_LINKING}
type
  TZSTD_versionNumber = function: unsigned; cdecl;
  TZSTD_versionString = function: PAnsiChar; cdecl;
  TZSTD_compress = function(dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t; cdecl;
  TZSTD_decompress = function(dst: Pointer; dstCapacity: size_t; src: Pointer; compressedSize: size_t): size_t; cdecl;
  TZSTD_getFrameContentSize = function(src: Pointer; srcSize: size_t): Int64; cdecl;
  TZSTD_getDecompressedSize = function(src: Pointer; srcSize: size_t): Int64; cdecl;
  TZSTD_compressBound = function(srcSize: size_t): size_t; cdecl;
  TZSTD_isError = function(code: size_t): unsigned; cdecl;
  TZSTD_getErrorName = function(code: size_t): PAnsiChar; cdecl;
  TZSTD_maxCLevel = function: int; cdecl;
  TZSTD_createCCtx = function: ZSTD_CCtx; cdecl;
  TZSTD_freeCCtx = function(cctx: ZSTD_CCtx): size_t; cdecl;
  TZSTD_compressCCtx = function(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t; cdecl;
  TZSTD_createDCtx = function: ZSTD_DCtx; cdecl;
  TZSTD_freeDCtx = function(dctx: ZSTD_DCtx): size_t; cdecl;
  TZSTD_decompressDCtx = function(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t): size_t; cdecl;
  TZSTD_compress_usingDict = function(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t; compressionLevel: int): size_t; cdecl;
  TZSTD_decompress_usingDict = function(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t): size_t; cdecl;
  TZSTD_createCDict = function(dictBuffer: Pointer; dictSize: size_t; compressionLevel: int): ZSTD_CDict; cdecl;
  TZSTD_freeCDict = function(CDict: ZSTD_CDict): size_t; cdecl;
  TZSTD_compress_usingCDict = function(cctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; cdict: ZSTD_CDict): size_t; cdecl;
  TZSTD_createDDict = function(dictBuffer: Pointer; dictSize: size_t): ZSTD_DDict; cdecl;
  TZSTD_freeDDict = function(ddict: ZSTD_DDict): size_t; cdecl;
  TZSTD_decompress_usingDDict = function(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; ddict: ZSTD_DDict): size_t; cdecl;
  TZSTD_createCStream = function: ZSTD_CStream; cdecl;
  TZSTD_freeCStream = function(zcs: ZSTD_CStream): size_t; cdecl;
  TZSTD_initCStream = function(zcs: ZSTD_CStream; compressionLevel: int): size_t; cdecl;
  TZSTD_compressStream = function(zcs: ZSTD_CStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t; cdecl;
  TZSTD_flushStream = function(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t; cdecl;
  TZSTD_endStream = function(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t; cdecl;
  TZSTD_CStreamInSize = function: size_t; cdecl;
  TZSTD_CStreamOutSize = function: size_t; cdecl;
  TZSTD_createDStream = function: ZSTD_DStream; cdecl;
  TZSTD_freeDStream = function(zds: ZSTD_DStream): size_t; cdecl;
  TZSTD_initDStream = function(zds: ZSTD_DStream): size_t; cdecl;
  TZSTD_decompressStream = function(zds: ZSTD_DStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t; cdecl;
  TZSTD_DStreamInSize = function: size_t; cdecl;
  TZSTD_DStreamOutSize = function: size_t; cdecl;

var
  ZSTDLock: TRTLCriticalSection;
  ZSTD: HMODULE;

  _ZSTD_versionNumber: TZSTD_versionNumber;
  _ZSTD_versionString: TZSTD_versionString;
  _ZSTD_compress: TZSTD_compress;
  _ZSTD_decompress: TZSTD_decompress;
  _ZSTD_getFrameContentSize: TZSTD_getFrameContentSize;
  _ZSTD_getDecompressedSize: TZSTD_getDecompressedSize;
  _ZSTD_compressBound: TZSTD_compressBound;
  _ZSTD_isError: TZSTD_isError;
  _ZSTD_getErrorName: TZSTD_getErrorName;
  _ZSTD_maxCLevel: TZSTD_maxCLevel;
  _ZSTD_createCCtx: TZSTD_createCCtx;
  _ZSTD_freeCCtx: TZSTD_freeCCtx;
  _ZSTD_compressCCtx: TZSTD_compressCCtx;
  _ZSTD_createDCtx: TZSTD_createDCtx;
  _ZSTD_freeDCtx: TZSTD_freeDCtx;
  _ZSTD_decompressDCtx: TZSTD_decompressDCtx;
  _ZSTD_compress_usingDict: TZSTD_compress_usingDict;
  _ZSTD_decompress_usingDict: TZSTD_decompress_usingDict;
  _ZSTD_createCDict: TZSTD_createCDict;
  _ZSTD_freeCDict: TZSTD_freeCDict;
  _ZSTD_compress_usingCDict: TZSTD_compress_usingCDict;
  _ZSTD_createDDict: TZSTD_createDDict;
  _ZSTD_freeDDict: TZSTD_freeDDict;
  _ZSTD_decompress_usingDDict: TZSTD_decompress_usingDDict;
  _ZSTD_createCStream: TZSTD_createCStream;
  _ZSTD_freeCStream: TZSTD_freeCStream;
  _ZSTD_initCStream: TZSTD_initCStream;
  _ZSTD_compressStream: TZSTD_compressStream;
  _ZSTD_flushStream: TZSTD_flushStream;
  _ZSTD_endStream: TZSTD_endStream;
  _ZSTD_CStreamInSize: TZSTD_CStreamInSize;
  _ZSTD_CStreamOutSize: TZSTD_CStreamOutSize;
  _ZSTD_createDStream: TZSTD_createDStream;
  _ZSTD_freeDStream: TZSTD_freeDStream;
  _ZSTD_initDStream: TZSTD_initDStream;
  _ZSTD_decompressStream: TZSTD_decompressStream;
  _ZSTD_DStreamInSize: TZSTD_DStreamInSize;
  _ZSTD_DStreamOutSize: TZSTD_DStreamOutSize;

procedure InitZSTD;
begin
  EnterCriticalSection(ZSTDLock);
  try
    if ZSTD <> 0 then Exit;
    ZSTD := LoadLibraryW(PWideChar(ZSTDDllName));
    if ZSTD = 0 then Exit;

    @_ZSTD_versionNumber                       := GetProcAddress(ZSTD, sZSTD_versionNumber);
    @_ZSTD_versionString                       := GetProcAddress(ZSTD, sZSTD_versionString);
    @_ZSTD_compress                            := GetProcAddress(ZSTD, sZSTD_compress);
    @_ZSTD_decompress                          := GetProcAddress(ZSTD, sZSTD_decompress);
    @_ZSTD_getFrameContentSize                 := GetProcAddress(ZSTD, sZSTD_getFrameContentSize);
    @_ZSTD_getDecompressedSize                 := GetProcAddress(ZSTD, sZSTD_getDecompressedSize);
    @_ZSTD_compressBound                       := GetProcAddress(ZSTD, sZSTD_compressBound);
    @_ZSTD_isError                             := GetProcAddress(ZSTD, sZSTD_isError);
    @_ZSTD_getErrorName                        := GetProcAddress(ZSTD, sZSTD_getErrorName);
    @_ZSTD_maxCLevel                           := GetProcAddress(ZSTD, sZSTD_maxCLevel);
    @_ZSTD_createCCtx                          := GetProcAddress(ZSTD, sZSTD_createCCtx);
    @_ZSTD_freeCCtx                            := GetProcAddress(ZSTD, sZSTD_freeCCtx);
    @_ZSTD_compressCCtx                        := GetProcAddress(ZSTD, sZSTD_compressCCtx);
    @_ZSTD_createDCtx                          := GetProcAddress(ZSTD, sZSTD_createDCtx);
    @_ZSTD_freeDCtx                            := GetProcAddress(ZSTD, sZSTD_freeDCtx);
    @_ZSTD_decompressDCtx                      := GetProcAddress(ZSTD, sZSTD_decompressDCtx);
    @_ZSTD_compress_usingDict                  := GetProcAddress(ZSTD, sZSTD_compress_usingDict);
    @_ZSTD_decompress_usingDict                := GetProcAddress(ZSTD, sZSTD_decompress_usingDict);
    @_ZSTD_createCDict                         := GetProcAddress(ZSTD, sZSTD_createCDict);
    @_ZSTD_freeCDict                           := GetProcAddress(ZSTD, sZSTD_freeCDict);
    @_ZSTD_compress_usingCDict                 := GetProcAddress(ZSTD, sZSTD_compress_usingCDict);
    @_ZSTD_createDDict                         := GetProcAddress(ZSTD, sZSTD_createDDict);
    @_ZSTD_freeDDict                           := GetProcAddress(ZSTD, sZSTD_freeDDict);
    @_ZSTD_decompress_usingDDict               := GetProcAddress(ZSTD, sZSTD_decompress_usingDDict);
    @_ZSTD_createCStream                       := GetProcAddress(ZSTD, sZSTD_createCStream);
    @_ZSTD_freeCStream                         := GetProcAddress(ZSTD, sZSTD_freeCStream);
    @_ZSTD_initCStream                         := GetProcAddress(ZSTD, sZSTD_initCStream);
    @_ZSTD_compressStream                      := GetProcAddress(ZSTD, sZSTD_compressStream);
    @_ZSTD_flushStream                         := GetProcAddress(ZSTD, sZSTD_flushStream);
    @_ZSTD_endStream                           := GetProcAddress(ZSTD, sZSTD_endStream);
    @_ZSTD_CStreamInSize                       := GetProcAddress(ZSTD, sZSTD_CStreamInSize);
    @_ZSTD_CStreamOutSize                      := GetProcAddress(ZSTD, sZSTD_CStreamOutSize);
    @_ZSTD_createDStream                       := GetProcAddress(ZSTD, sZSTD_createDStream);
    @_ZSTD_freeDStream                         := GetProcAddress(ZSTD, sZSTD_freeDStream);
    @_ZSTD_initDStream                         := GetProcAddress(ZSTD, sZSTD_initDStream);
    @_ZSTD_decompressStream                    := GetProcAddress(ZSTD, sZSTD_decompressStream);
    @_ZSTD_DStreamInSize                       := GetProcAddress(ZSTD, sZSTD_DStreamInSize);
    @_ZSTD_DStreamOutSize                      := GetProcAddress(ZSTD, sZSTD_DStreamOutSize);
  finally
    LeaveCriticalSection(ZSTDLock);
  end;
end;

procedure DoneZSTD;
begin
  if ZSTD <> 0 then FreeLibrary(ZSTD);
end;

function ZSTD_versionNumber: unsigned;
begin
  InitZSTD;
  if Assigned(@_ZSTD_versionNumber) then
    Result := _ZSTD_versionNumber
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_versionString: PAnsiChar;
begin
  InitZSTD;
  if Assigned(@_ZSTD_versionString) then
    Result := _ZSTD_versionString
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compress(dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compress) then
    Result := _ZSTD_compress(dst, dstCapacity, src, srcSize, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_decompress(dst: Pointer; dstCapacity: size_t; src: Pointer; compressedSize: size_t): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_decompress) then
    Result := _ZSTD_decompress(dst, dstCapacity, src, compressedSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_getFrameContentSize(src: Pointer; srcSize: size_t): Int64;
begin
  InitZSTD;
  if Assigned(@_ZSTD_getFrameContentSize) then
    Result := _ZSTD_getFrameContentSize(src, srcSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_getDecompressedSize(src: Pointer; srcSize: size_t): Int64;
begin
  InitZSTD;
  if Assigned(@_ZSTD_getDecompressedSize) then
    Result := _ZSTD_getDecompressedSize(src, srcSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compressBound(srcSize: size_t): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compressBound) then
    Result := _ZSTD_compressBound(srcSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_isError(code: size_t): unsigned;
begin
  InitZSTD;
  if Assigned(@_ZSTD_isError) then
    Result := _ZSTD_isError(code)
  else
    Result := 1;
end;

function ZSTD_getErrorName(code: size_t): PAnsiChar;
begin
  InitZSTD;
  if Assigned(@_ZSTD_getErrorName) then
    Result := _ZSTD_getErrorName(code)
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_maxCLevel: int;
begin
  InitZSTD;
  if Assigned(@_ZSTD_maxCLevel) then
    Result := _ZSTD_maxCLevel
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createCCtx: ZSTD_CCtx;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createCCtx) then
    Result := _ZSTD_createCCtx
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeCCtx(cctx: ZSTD_CCtx): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeCCtx) then
    Result := _ZSTD_freeCCtx(cctx)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compressCCtx(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; compressionLevel: int): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compressCCtx) then
    Result := _ZSTD_compressCCtx(ctx, dst, dstCapacity, src, srcSize, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createDCtx: ZSTD_DCtx;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createDCtx) then
    Result := _ZSTD_createDCtx
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeDCtx(dctx: ZSTD_DCtx): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeDCtx) then
    Result := _ZSTD_freeDCtx(dctx)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_decompressDCtx(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_decompressDCtx) then
    Result := _ZSTD_decompressDCtx(dctx, dst, dstCapacity, src, srcSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compress_usingDict(ctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t; compressionLevel: int): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compress_usingDict) then
    Result := _ZSTD_compress_usingDict(ctx, dst, dstCapacity, src, srcSize, dict, dictSize, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_decompress_usingDict(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; dict: Pointer; dictSize: size_t): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_decompress_usingDict) then
    Result := _ZSTD_decompress_usingDict(dctx, dst, dstCapacity, src, srcSize, dict, dictSize)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createCDict(dictBuffer: Pointer; dictSize: size_t; compressionLevel: int): ZSTD_CDict;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createCDict) then
    Result := _ZSTD_createCDict(dictBuffer, dictSize, compressionLevel)
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeCDict(CDict: ZSTD_CDict): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeCDict) then
    Result := _ZSTD_freeCDict(CDict)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compress_usingCDict(cctx: ZSTD_CCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; cdict: ZSTD_CDict): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compress_usingCDict) then
    Result := _ZSTD_compress_usingCDict(cctx, dst, dstCapacity, src, srcSize, cdict)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createDDict(dictBuffer: Pointer; dictSize: size_t): ZSTD_DDict;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createDDict) then
    Result := _ZSTD_createDDict(dictBuffer, dictSize)
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeDDict(ddict: ZSTD_DDict): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeDDict) then
    Result := _ZSTD_freeDDict(ddict)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_decompress_usingDDict(dctx: ZSTD_DCtx; dst: Pointer; dstCapacity: size_t; src: Pointer; srcSize: size_t; ddict: ZSTD_DDict): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_decompress_usingDDict) then
    Result := _ZSTD_decompress_usingDDict(dctx, dst, dstCapacity, src, srcSize, ddict)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createCStream: ZSTD_CStream;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createCStream) then
    Result := _ZSTD_createCStream
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeCStream(zcs: ZSTD_CStream): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeCStream) then
    Result := _ZSTD_freeCStream(zcs)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_initCStream(zcs: ZSTD_CStream; compressionLevel: int): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_initCStream) then
    Result := _ZSTD_initCStream(zcs, compressionLevel)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_compressStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_compressStream) then
    Result := _ZSTD_compressStream(zcs, output, input)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_flushStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_flushStream) then
    Result := _ZSTD_flushStream(zcs, output)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_endStream(zcs: ZSTD_CStream; var output: ZSTD_outBuffer): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_endStream) then
    Result := _ZSTD_endStream(zcs, output)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_CStreamInSize: size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_CStreamInSize) then
    Result := _ZSTD_CStreamInSize
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_CStreamOutSize: size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_CStreamOutSize) then
    Result := _ZSTD_CStreamOutSize
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_createDStream: ZSTD_DStream;
begin
  InitZSTD;
  if Assigned(@_ZSTD_createDStream) then
    Result := _ZSTD_createDStream
  else
    begin Result := nil; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_freeDStream(zds: ZSTD_DStream): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_freeDStream) then
    Result := _ZSTD_freeDStream(zds)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_initDStream(zds: ZSTD_DStream): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_initDStream) then
    Result := _ZSTD_initDStream(zds)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_decompressStream(zds: ZSTD_DStream; var output: ZSTD_outBuffer; var input: ZSTD_inBuffer): size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_decompressStream) then
    Result := _ZSTD_decompressStream(zds, output, input)
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_DStreamInSize: size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_DStreamInSize) then
    Result := _ZSTD_DStreamInSize
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

function ZSTD_DStreamOutSize: size_t;
begin
  InitZSTD;
  if Assigned(@_ZSTD_DStreamOutSize) then
    Result := _ZSTD_DStreamOutSize
  else
    begin Result := 0; RaiseLastOSError(ERROR_PROC_NOT_FOUND); end;
end;

initialization
  InitializeCriticalSection(ZSTDLock);
  ZSTD := 0;

finalization
  DoneZSTD;
  DeleteCriticalSection(ZSTDLock);
{$ENDIF}

end.
