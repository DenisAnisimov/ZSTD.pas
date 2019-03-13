unit LZ4;

interface

uses
  Windows, Classes, LZ4Lib;

procedure LZ4CompressStream(ASource, ADest: TStream; ALevel: Integer; ACount: Int64 = 0);
procedure LZ4DecompressStream(ASource, ADest: TStream; ACount: Int64 = 0);

type
  TLZ4CompressStream = class(TStream)
  public
    class function MaxLevel: Integer;
    constructor Create(ADest: TStream; ALevel: Integer; ABlockSize: Integer; AIndependentBlocks,
      AContentChecksums, ABlockChecksums: Boolean); overload; // ALevel in range 1-MaxLevel
    constructor Create(ADest: TStream; ALevel: Integer); overload; // ALevel in range 1-MaxLevel
    destructor Destroy; override;
    function Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;
    function Read(var ABuffer; ACount: Longint): Longint; override;
    function Write(const ABuffer; ACount: Longint): Longint; override;
  private
    FDest: TStream;
    FLevel: Integer;
    FPreferences: LZ4F_preferences_t;
    FStreamOutBufferSize: size_t;
    FStreamOutBuffer: Pointer;
    FContext: LZ4F_cctx;
  end;

  TLZ4DecompressStream = class(TStream)
  public
    constructor Create(ASource: TStream);
    destructor Destroy; override;
    function Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;
    function Read(var ABuffer; ACount: Longint): Longint; override;
    function Write(const ABuffer; ACount: Longint): Longint; override;
  private
    FSource: TStream;
    FPosition: Int64;
    FStreamInBufferSize: size_t;
    FStreamInBuffer: PByte;
    FStreamInBufferAvailableSize: size_t;
    FStreamInBufferPos: PByte;
    FStreamOutBufferSize: size_t;
    FStreamOutBuffer: PByte;
    FStreamOutBufferAvailableSize: size_t;
    FStreamOutBufferPos: PByte;
    FContext: LZ4F_dctx;
    FSeekBuffer: Pointer;
  end;

implementation

uses
  SysUtils;

const
  CopyBufferSize = 65536;

procedure LZ4CompressStream(ASource, ADest: TStream; ALevel: Integer; ACount: Int64 = 0);
const
  CopyBufferSize = 6553;
var
  Buffer: Pointer;
  CompressStream: TStream;
  FullStream: Boolean;
  Read: Integer;
begin
  GetMem(Buffer, CopyBufferSize);
  try
    CompressStream := TLZ4CompressStream.Create(ADest, ALevel);
    try
      FullStream := ACount = 0;
      while True do
        begin
          if FullStream then
            begin
              Read := ASource.Read(Buffer^, CopyBufferSize);
              if Read = 0 then Break;
              CompressStream.WriteBuffer(Buffer^, Read);
            end
          else
            begin
              if ACount > CopyBufferSize then Read := CopyBufferSize
                                         else Read := ACount;
              ASource.ReadBuffer(Buffer^, Read);
              CompressStream.WriteBuffer(Buffer^, Read);
              Dec(ACount, Read);
              if ACount = 0 then Break;
            end;
        end;
    finally
      CompressStream.Free;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure LZ4DecompressStream(ASource, ADest: TStream; ACount: Int64 = 0);
const
  CopyBufferSize = 6553;
var
  Buffer: Pointer;
  DecompressStream: TStream;
  FullStream: Boolean;
  Read: Integer;
begin
  GetMem(Buffer, CopyBufferSize);
  try
    DecompressStream := TLZ4DecompressStream.Create(ASource);
    try
      FullStream := ACount = 0;
      while True do
        begin
          if FullStream then
            begin
              Read := DecompressStream.Read(Buffer^, CopyBufferSize);
              if Read = 0 then Break;
              ADest.WriteBuffer(Buffer^, Read);
            end
          else
            begin
              if ACount > CopyBufferSize then Read := CopyBufferSize
                                         else Read := ACount;
              DecompressStream.ReadBuffer(Buffer^, Read);
              ADest.WriteBuffer(Buffer^, Read);
              Dec(ACount, Read);
              if ACount = 0 then Break;
            end;
        end;
    finally
      DecompressStream.Free;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

//**************************************************************************************************
// TLZ4CompressStream
//**************************************************************************************************

class function TLZ4CompressStream.MaxLevel: Integer;
begin
  Result := LZ4F_compressionLevel_max;
end;

const
  LZ4DefaultBlockSize4MB   = 4 * 1024 * 1024;
  LZ4DefaultBlockSize1MB   = 1 * 1024 * 1024;
  LZ4DefaultBlockSize256KB = 256 * 1024;
  LZ4DefaultBlockSize64KB  = 64 * 1024;

constructor TLZ4CompressStream.Create(ADest: TStream; ALevel: Integer; ABlockSize: Integer; AIndependentBlocks,
  AContentChecksums, ABlockChecksums: Boolean);
begin
  inherited Create;
  FDest := ADest;
  FLevel := ALevel;
  if FLevel < 0 then FLevel := 0;
  if FLevel > MaxLevel then FLevel := MaxLevel;

	FPreferences.compressionLevel := FLevel;

  if (ABlockSize = 0) or (ABlockSize > LZ4DefaultBlockSize1MB) then
    FPreferences.frameInfo.blockSizeID := LZ4F_max4MB
  else
  if ABlockSize > LZ4DefaultBlockSize256KB then
    FPreferences.frameInfo.blockSizeID := LZ4F_max1MB
  else
  if ABlockSize > LZ4DefaultBlockSize64KB then
    FPreferences.frameInfo.blockSizeID := LZ4F_max256KB
  else
    FPreferences.frameInfo.blockSizeID := LZ4F_max64KB;

  if AIndependentBlocks then
    FPreferences.frameInfo.blockMode := LZ4F_blockIndependent
  else
    FPreferences.frameInfo.blockMode := LZ4F_blockLinked;

  if AContentChecksums then
    FPreferences.frameInfo.contentChecksumFlag := LZ4F_contentChecksumEnabled
  else
    FPreferences.frameInfo.contentChecksumFlag := LZ4F_noContentChecksum;

  FPreferences.frameInfo.contentSize := 0;

  if ABlockChecksums then
    FPreferences.frameInfo.blockChecksumFlag := LZ4F_blockChecksumEnabled
  else
    FPreferences.frameInfo.blockChecksumFlag := LZ4F_noBlockChecksum;
end;

constructor TLZ4CompressStream.Create(ADest: TStream; ALevel: Integer);
begin
  Create(ADest, ALevel, 0, False, True, True);
end;

destructor TLZ4CompressStream.Destroy;
var
  R: size_t;
begin
  if Assigned(FContext) then
    begin
      R := LZ4FCheck(sLZ4F_flush, LZ4F_flush(FContext, FStreamOutBuffer, FStreamOutBufferSize, @FPreferences));
      if R > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, R);

      R := LZ4FCheck(sLZ4F_compressEnd, LZ4F_compressEnd(FContext, FStreamOutBuffer, FStreamOutBufferSize, @FPreferences));
      if R > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, R);

      LZ4FCheck(sLZ4F_freeCompressionContext, LZ4F_freeCompressionContext(FContext));
    end;
  if Assigned(FStreamOutBuffer) then
    FreeMem(FStreamOutBuffer);
  inherited Destroy;
end;

function TLZ4CompressStream.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

function TLZ4CompressStream.Read(var ABuffer; ACount: Longint): Longint;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

function TLZ4CompressStream.Write(const ABuffer; ACount: Longint): Longint;
var
  BufferIn: PByte;
  R: size_t;
  CopySize: Integer;
begin
  Result := 0;
  if ACount = 0 then Exit;

  if not Assigned(FStreamOutBuffer) then
    begin
      FStreamOutBufferSize := LZ4F_compressBound(CopyBufferSize, @FPreferences) + 30 {LZ4_HEADER_SIZE + LZ4_FOOTER_SIZE};
      GetMem(FStreamOutBuffer, FStreamOutBufferSize);
    end;

  if not Assigned(FContext) then
    begin
      LZ4FCheck(sLZ4F_createCompressionContext, LZ4F_createCompressionContext(FContext, LZ4F_getVersion));
      if not Assigned(FContext) then
        raise EOutOfMemory.Create('');
      R := LZ4FCheck(sLZ4F_compressBegin, LZ4F_compressBegin(FContext, FStreamOutBuffer, FStreamOutBufferSize, @FPreferences));
      if R > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, R);
    end;

  BufferIn := @ABuffer;
  while ACount > 0 do
    begin
      if ACount > CopyBufferSize then CopySize := CopyBufferSize
                                 else CopySize := ACount;
      R := LZ4FCheck(sLZ4F_compressUpdate, LZ4F_compressUpdate(FContext, FStreamOutBuffer, FStreamOutBufferSize, BufferIn, CopySize, @FPreferences));
      if R > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, R);
      Dec(ACount, CopySize);
      Inc(BufferIn, CopySize);
      Inc(Result, CopySize);
    end;
end;

//**************************************************************************************************
// TLZ4DecompressStream
//**************************************************************************************************

constructor TLZ4DecompressStream.Create(ASource: TStream);
begin
  inherited Create;
  FSource := ASource;
end;

destructor TLZ4DecompressStream.Destroy;
begin
  if Assigned(FContext) then
    LZ4F_freeDecompressionContext(FContext);
  if Assigned(FStreamInBuffer) then
    FreeMem(FStreamInBuffer);
  if Assigned(FStreamOutBuffer) then
    FreeMem(FStreamOutBuffer);
  if Assigned(FSeekBuffer) then
    FreeMem(FSeekBuffer);
  inherited Destroy;
end;

function TLZ4DecompressStream.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
const
  SeekBufferSize = 65536;
var
  SeekSizeTotal: Int64;
  SeekSize: Integer;
begin
  if (AOrigin <> soCurrent) or (AOffset < 0) then
    begin
      Result := 0; // Make compiler happy;
      RaiseLastOSError(ERROR_INVALID_FUNCTION);
    end
  else
    begin
      if AOffset > 0 then
        begin
          if not Assigned(FSeekBuffer) then
            GetMem(FSeekBuffer, SeekBufferSize);
          SeekSizeTotal := AOffset;
          while SeekSizeTotal > 0 do
            begin
              if SeekSizeTotal >= SeekBufferSize then SeekSize := SeekBufferSize
                                                 else SeekSize := SeekSizeTotal;
              SeekSize := Read(FSeekBuffer^, SeekSize);
              if SeekSize = 0 then
                Break;
              Dec(SeekSizeTotal, SeekSize);
            end;
        end;
      Result := FPosition;
    end;
end;

function TLZ4DecompressStream.Read(var ABuffer; ACount: Longint): Longint;
var
  AvailableOutSize: size_t;
  Read: size_t;
  BufferOut: PByte;
begin
  Result := 0;
  if ACount = 0 then Exit;

  if not Assigned(FContext) then
    LZ4FCheck(sLZ4F_createDecompressionContext, LZ4F_createDecompressionContext(FContext, LZ4F_getVersion));

  if not Assigned(FStreamInBuffer) then
    begin
      FStreamInBufferSize := CopyBufferSize;
      GetMem(FStreamInBuffer, FStreamInBufferSize);
    end;

  if not Assigned(FStreamOutBuffer) then
    begin
      FStreamOutBufferSize := CopyBufferSize;
      GetMem(FStreamOutBuffer, FStreamOutBufferSize);
    end;

  BufferOut := @ABuffer;
  while ACount > 0 do
    begin
      AvailableOutSize := FStreamOutBufferAvailableSize;
      if AvailableOutSize > size_t(ACount) then
        AvailableOutSize := ACount;
      if AvailableOutSize > 0 then
        begin
          CopyMemory(BufferOut, FStreamOutBufferPos, AvailableOutSize);
          Dec(FStreamOutBufferAvailableSize, AvailableOutSize);
          Inc(FStreamOutBufferPos, AvailableOutSize);
          Inc(BufferOut, AvailableOutSize);
          Dec(ACount, AvailableOutSize);
          Inc(Result, AvailableOutSize);
          Inc(FPosition, AvailableOutSize);
          if ACount = 0 then Break;
        end;

      if FStreamInBufferAvailableSize = 0 then
        begin
          FStreamInBufferAvailableSize := FSource.Read(FStreamInBuffer^, FStreamInBufferSize);
          FStreamInBufferPos := FStreamInBuffer;
        end;
      if FStreamInBufferAvailableSize = 0 then Break;

      Read := FStreamInBufferAvailableSize;
      AvailableOutSize := FStreamOutBufferSize - FStreamOutBufferAvailableSize;
      LZ4FCheck(sLZ4F_decompress, LZ4F_decompress(FContext, FStreamOutBuffer, AvailableOutSize, FStreamInBufferPos, Read, nil));
      Inc(FStreamInBufferPos, Read);
      FStreamInBufferAvailableSize := FStreamInBufferAvailableSize - Read;
      FStreamOutBufferPos := FStreamOutBuffer;
      FStreamOutBufferAvailableSize := AvailableOutSize;

      if FStreamOutBufferAvailableSize > 0 then
        begin
          AvailableOutSize := FStreamOutBufferAvailableSize;
          if AvailableOutSize > size_t(ACount) then
            AvailableOutSize := ACount;
          if AvailableOutSize > 0 then
            CopyMemory(BufferOut, FStreamOutBufferPos, AvailableOutSize);
          Dec(FStreamOutBufferAvailableSize, AvailableOutSize);
          Inc(FStreamOutBufferPos, AvailableOutSize);
          Inc(BufferOut, AvailableOutSize);
          Dec(ACount, AvailableOutSize);
          Inc(Result, AvailableOutSize);
          Inc(FPosition, AvailableOutSize);
        end;
    end;

end;

function TLZ4DecompressStream.Write(const ABuffer; ACount: Longint): Longint;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

end.

