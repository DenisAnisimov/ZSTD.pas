unit ZSTD;

interface

uses
  Windows, Classes, ZSTDLib;

procedure ZSTDCompressStream(ASource, ADest: TStream; ALevel: Integer; ACount: Int64 = 0);
procedure ZSTDDecompressStream(ASource, ADest: TStream; ACount: Int64 = 0);

type
  TZSTDCompressStream = class(TStream)
  public
    class function MaxLevel: Integer;
    constructor Create(ADest: TStream; ALevel: Integer); // ALevel in range 1-MaxLevel
    destructor Destroy; override;
    function Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64; override;
    function Read(var ABuffer; ACount: Longint): Longint; override;
    function Write(const ABuffer; ACount: Longint): Longint; override;
  private
    FDest: TStream;
    FLevel: Integer;
    FStreamOutBufferSize: size_t;
    FStreamOutBuffer: Pointer;
    FStream: ZSTD_CStream;
  end;

  TZSTDDecompressStream = class(TStream)
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
    FStreamInBuffer: Pointer;
    FInput: ZSTD_inBuffer;
    FStreamOutBufferSize: size_t;
    FStreamOutBuffer: Pointer;
    FStreamOutBufferSizePos: size_t;
    FOutput: ZSTD_outBuffer;
    FStream: ZSTD_DStream;
    FSeekBuffer: Pointer;
  end;

implementation

uses
  SysUtils;

const
  CopyBufferSize = 65536;

procedure ZSTDCompressStream(ASource, ADest: TStream; ALevel: Integer; ACount: Int64 = 0);
var
  Buffer: Pointer;
  CompressStream: TStream;
  FullStream: Boolean;
  Read: Integer;
begin
  GetMem(Buffer, CopyBufferSize);
  try
    CompressStream := TZSTDCompressStream.Create(ADest, ALevel);
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

procedure ZSTDDecompressStream(ASource, ADest: TStream; ACount: Int64 = 0);
var
  Buffer: Pointer;
  DecompressStream: TStream;
  FullStream: Boolean;
  Read: Integer;
begin
  GetMem(Buffer, CopyBufferSize);
  try
    DecompressStream := TZSTDDecompressStream.Create(ASource);
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
// TZSTDCompressStream
//**************************************************************************************************

class function TZSTDCompressStream.MaxLevel: Integer;
begin
  Result := ZSTD_maxCLevel;
end;

constructor TZSTDCompressStream.Create(ADest: TStream; ALevel: Integer);
begin
  inherited Create;
  FDest := ADest;
  FLevel := ALevel;
  if FLevel < 1 then FLevel := 1;
  if FLevel > MaxLevel then FLevel := MaxLevel;
end;

destructor TZSTDCompressStream.Destroy;
var
  Output: ZSTD_outBuffer;
begin
  if Assigned(FStream) then
    begin
      Output.dst := FStreamOutBuffer;
      Output.size := FStreamOutBufferSize;
      Output.pos := 0;
      ZSTDCheck(sZSTD_endStream, ZSTD_endStream(FStream, Output));
      if Output.pos > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, Output.pos);
      ZSTD_freeCStream(FStream);
    end;
  if Assigned(FStreamOutBuffer) then
    FreeMem(FStreamOutBuffer);
  inherited Destroy;
end;

function TZSTDCompressStream.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

function TZSTDCompressStream.Read(var ABuffer; ACount: Longint): Longint;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

function TZSTDCompressStream.Write(const ABuffer; ACount: Longint): Longint;
var
  Input: ZSTD_inBuffer;
  Output: ZSTD_outBuffer;
begin
  Result := ACount;
  if ACount = 0 then Exit;

  if not Assigned(FStreamOutBuffer) then
    begin
      FStreamOutBufferSize := ZSTD_CStreamOutSize;
      GetMem(FStreamOutBuffer, FStreamOutBufferSize);
    end;

  if not Assigned(FStream) then
    begin
      FStream := ZSTD_createCStream;
      if not Assigned(FStream) then
        raise EOutOfMemory.Create('');
      ZSTDCheck(sZSTD_initCStream, ZSTD_initCStream(FStream, FLevel));
    end;

  Input.src := @ABuffer;
  Input.size := ACount;
  Input.pos := 0;

  while Input.pos < Input.size do
    begin
      Output.dst := FStreamOutBuffer;
      Output.size := FStreamOutBufferSize;
      Output.pos := 0;
      ZSTDCheck(sZSTD_compressStream, ZSTD_compressStream(FStream, Output, Input));
      if Output.pos > 0 then
        FDest.WriteBuffer(FStreamOutBuffer^, Output.pos);
    end;
end;

//**************************************************************************************************
// TZSTDDecompressStream
//**************************************************************************************************

constructor TZSTDDecompressStream.Create(ASource: TStream);
begin
  inherited Create;
  FSource := ASource;
end;

destructor TZSTDDecompressStream.Destroy;
begin
  if Assigned(FStream) then
    ZSTD_freeDStream(FStream);
  if Assigned(FStreamInBuffer) then
    FreeMem(FStreamInBuffer);
  if Assigned(FStreamOutBuffer) then
    FreeMem(FStreamOutBuffer);
  if Assigned(FSeekBuffer) then
    FreeMem(FSeekBuffer);
  inherited Destroy;
end;

function TZSTDDecompressStream.Seek(const AOffset: Int64; AOrigin: TSeekOrigin): Int64;
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

function TZSTDDecompressStream.Read(var ABuffer; ACount: Longint): Longint;
var
  AvailableCount: size_t;
  Buffer: PByte;
  Source: PByte;
begin
  Result := 0;
  if ACount = 0 then Exit;

  if not Assigned(FStreamInBuffer) then
    begin
      FStreamInBufferSize := ZSTD_DStreamInSize;
      GetMem(FStreamInBuffer, FStreamInBufferSize);
      FInput.src := FStreamInBuffer;
      FInput.size := FStreamInBufferSize;
      FInput.pos := FStreamInBufferSize;
    end;

  if not Assigned(FStreamOutBuffer) then
    begin
      FStreamOutBufferSize := ZSTD_DStreamOutSize;
      GetMem(FStreamOutBuffer, FStreamOutBufferSize);
      FOutput.dst := FStreamOutBuffer;
      FOutput.size := FStreamOutBufferSize;
      FStreamOutBufferSizePos := 0;
    end;

  if not Assigned(FStream) then
    begin
      FStream := ZSTD_createDStream;
      if not Assigned(FStream) then
        raise EOutOfMemory.Create('');
      ZSTDCheck(sZSTD_initDStream, ZSTD_initDStream(FStream));
    end;

  Buffer := @ABuffer;
  while ACount > 0 do
    begin
      AvailableCount := FOutput.pos - FStreamOutBufferSizePos;
      if Integer(AvailableCount) > ACount then
        AvailableCount := ACount;
      if AvailableCount > 0 then
        begin
          Source := FStreamOutBuffer;
          Inc(Source, FStreamOutBufferSizePos);
          CopyMemory(Buffer, Source, AvailableCount);
          Inc(FStreamOutBufferSizePos, AvailableCount);
          Inc(Buffer, AvailableCount);
          Dec(ACount, AvailableCount);
          Inc(Result, AvailableCount);
          Inc(FPosition, AvailableCount);
          if ACount = 0 then Break;
        end;

      FOutput.pos := 0;
      FStreamOutBufferSizePos := 0;

      if (FInput.pos = FInput.size) and (FInput.size > 0) then
        begin
          FInput.size := FSource.Read(FStreamInBuffer^, FInput.size);
          FInput.pos := 0;
        end;

      ZSTDCheck(sZSTD_compressStream, ZSTD_decompressStream(FStream, FOutput, FInput));
      if (FOutput.pos = 0) and (FInput.size = 0) then Break;
    end;
end;

function TZSTDDecompressStream.Write(const ABuffer; ACount: Longint): Longint;
begin
  Result := 0; // Make compiler happy;
  RaiseLastOSError(ERROR_INVALID_FUNCTION);
end;

end.

