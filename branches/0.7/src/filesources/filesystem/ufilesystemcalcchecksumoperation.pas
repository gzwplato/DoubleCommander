unit uFileSystemCalcChecksumOperation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs,
  uFileSourceCalcChecksumOperation,
  uFileSource,
  uFileSourceOperationOptions,
  uFileSourceOperationUI,
  uFile,
  uGlobs, uLog, uHash, DCClassesUtf8;

type

  { TFileSystemCalcChecksumOperation }

  TFileSystemCalcChecksumOperation = class(TFileSourceCalcChecksumOperation)

  private
    FFullFilesTree: TFiles;  // source files including all files/dirs in subdirectories
    FStatistics: TFileSourceCalcChecksumOperationStatistics; // local copy of statistics
    FCheckSumFile: TStringListEx;
    FBuffer: Pointer;
    FBufferSize: LongWord;
    FChecksumsList: TObjectList;

    // Options.
    FSymLinkOption: TFileSourceOperationOptionSymLink;
    FSkipErrors: Boolean;

    procedure InitializeVerifyMode;
    procedure InitializeRightToLeft(const Path: String);
    procedure InitializeLeftToRight(const Path: String);
    procedure AddFile(const Path, FileName, Hash: String);
    function CheckSumCalc(aFile: TFile; out aValue: String): Boolean;
    procedure LogMessage(sMessage: String; logOptions: TLogOptions; logMsgType: TLogMsgType);

    function CalcChecksumProcessFile(aFile: TFile): Boolean;
    function VerifyChecksumProcessFile(aFile: TFile; ExpectedChecksum: String): Boolean;

  public
    constructor Create(aTargetFileSource: IFileSource;
                       var theFiles: TFiles;
                       aTargetPath: String;
                       aTargetMask: String); override;

    destructor Destroy; override;

    procedure Initialize; override;
    procedure MainExecute; override;
    procedure Finalize; override;
  end;

implementation

uses
  LCLProc, FileUtil,
  uLng, uFileSystemUtil, uFileSystemFileSource, DCOSUtils, DCStrUtils;

type
  TChecksumEntry = class
  public
    Checksum: String;
    Algorithm: THashAlgorithm;
  end;

const
  SFV_HEADER = '; Generated by WIN-SFV32 v1.0';
  DC_HEADER = '; (Compatible: Double Commander)';

constructor TFileSystemCalcChecksumOperation.Create(
                aTargetFileSource: IFileSource;
                var theFiles: TFiles;
                aTargetPath: String;
                aTargetMask: String);
begin
  FBuffer := nil;
  FSymLinkOption := fsooslNone;
  FSkipErrors := False;
  FFullFilesTree := nil;
  FCheckSumFile := TStringListEx.Create;
  FChecksumsList := TObjectList.Create(True);

  inherited Create(aTargetFileSource, theFiles,
                   aTargetPath, aTargetMask);
end;

destructor TFileSystemCalcChecksumOperation.Destroy;
begin
  inherited Destroy;

  if Assigned(FBuffer) then
  begin
    FreeMem(FBuffer);
    FBuffer := nil;
  end;

  if Assigned(FFullFilesTree) then
    FreeAndNil(FFullFilesTree);
  if Assigned(FCheckSumFile) then
    FreeAndNil(FCheckSumFile);
  if Assigned(FChecksumsList) then
    FreeAndNil(FChecksumsList);
end;

procedure TFileSystemCalcChecksumOperation.Initialize;
begin
  // Get initialized statistics; then we change only what is needed.
  FStatistics := RetrieveStatistics;

  case Mode of
    checksum_calc:
      begin
        FillAndCount(Files, False, False,
                     FFullFilesTree,
                     FStatistics.TotalFiles,
                     FStatistics.TotalBytes);     // gets full list of files (recursive)

        if (Algorithm = HASH_SFV) and OneFile then
        begin
          FCheckSumFile.Add(SFV_HEADER);
          FCheckSumFile.Add(DC_HEADER);
        end;
      end;
    checksum_verify:
      InitializeVerifyMode;
  end;

  FBufferSize := gHashBlockSize;
  GetMem(FBuffer, FBufferSize);
end;

procedure TFileSystemCalcChecksumOperation.MainExecute;
var
  aFile: TFile;
  CurrentFileIndex: Integer;
  OldDoneBytes: Int64; // for if there was an error
  Entry: TChecksumEntry;
begin
  for CurrentFileIndex := 0 to FFullFilesTree.Count - 1 do
  begin
    aFile := FFullFilesTree[CurrentFileIndex];

    with FStatistics do
    begin
      CurrentFile := aFile.Path + aFile.Name;
      CurrentFileTotalBytes := aFile.Size;
      CurrentFileDoneBytes := 0;
    end;

    UpdateStatistics(FStatistics);

    if not aFile.IsDirectory then
    begin
      // If there will be an error in ProcessFile the DoneBytes value
      // will be inconsistent, so remember it here.
      OldDoneBytes := FStatistics.DoneBytes;

      case Mode of
        checksum_calc:
          CalcChecksumProcessFile(aFile);

        checksum_verify:
          begin
            Entry := FChecksumsList.Items[CurrentFileIndex] as TChecksumEntry;
            Algorithm := Entry.Algorithm;
            VerifyChecksumProcessFile(aFile, Entry.Checksum);
          end;
      end;

      with FStatistics do
      begin
        DoneFiles := DoneFiles + 1;
        DoneBytes := OldDoneBytes + aFile.Size;

        UpdateStatistics(FStatistics);
      end;
    end;

    CheckOperationState;
  end;

  case Mode of
    checksum_calc:
      // make result
      if OneFile then
        try
          FCheckSumFile.SaveToFile(TargetMask);
        except
          on E: EFCreateError do
            AskQuestion(rsMsgErrECreate + ' ' + TargetMask + ':',
                                 E.Message, [fsourOk], fsourOk, fsourOk);
          on E: EWriteError do
            AskQuestion(rsMsgErrEWrite + ' ' + TargetMask + ':',
                               E.Message, [fsourOk], fsourOk, fsourOk);
        end;

    checksum_verify:
      begin
      end;
  end;
end;

procedure TFileSystemCalcChecksumOperation.Finalize;
begin
end;

procedure TFileSystemCalcChecksumOperation.AddFile(const Path, FileName, Hash: String);
var
  aFileToVerify: TFile;
  Entry: TChecksumEntry;
begin
  try
    aFileToVerify := TFileSystemFileSource.CreateFileFromFile(Path + FileName);
    if not (aFileToVerify.IsDirectory or aFileToVerify.IsLinkToDirectory) then
    begin
      with FStatistics do
      begin
        TotalFiles := TotalFiles + 1;
        TotalBytes := TotalBytes + aFileToVerify.Size;
      end;

      FFullFilesTree.Add(aFileToVerify);
      Entry := TChecksumEntry.Create;
      FChecksumsList.Add(Entry);
      Entry.Checksum := Hash;
      Entry.Algorithm := Algorithm;
    end
    else
      FreeAndNil(aFileToVerify);

  except
    on EFileNotFound do
      begin
        AddString(FResult.Missing, FileName);
      end
    else
      begin
        FreeAndNil(aFileToVerify);
        raise;
      end;
  end;
end;

procedure TFileSystemCalcChecksumOperation.InitializeRightToLeft(const Path: String);
var
  I: Integer;
  Hash, FileName: String;
begin
  for I := 1 to FCheckSumFile.Count - 1 do
  begin
    // Skip empty lines
    if (Length(FCheckSumFile[I]) = 0) then Continue;
    // Skip comments
    if (FCheckSumFile[I][1] = ';') then Continue;

    FileName := FCheckSumFile[I];
    Hash := Copy(FileName, Length(FileName) - 7, 8);
    FileName := Copy(FileName, 1, Length(FileName) - 9);

    AddFile(Path, FileName, Hash);

    CheckOperationState;
  end;
end;

procedure TFileSystemCalcChecksumOperation.InitializeLeftToRight(const Path: String);
var
  I: Integer;
  FileName: String;
begin
  for I := 0 to FCheckSumFile.Count - 1 do
  begin
    // Skip empty lines
    if (Length(FCheckSumFile[I]) = 0) then Continue;
    // Skip comments
    if (FCheckSumFile[I][1] = ';') then Continue;

    FileName := Copy(FCheckSumFile.ValueFromIndex[I], 2, MaxInt);

    AddFile(Path, FileName, FCheckSumFile.Names[I]);

    CheckOperationState;
  end;
end;

procedure TFileSystemCalcChecksumOperation.InitializeVerifyMode;
var
  aFile: TFile;
  Entry: TChecksumEntry;
  CurrentFileIndex: Integer;
begin
  FFullFilesTree := TFiles.Create(Files.Path);

  if Length(TargetPath) > 0 then
  begin
    aFile := Files[0].Clone;

    with FStatistics do
    begin
      TotalFiles := TotalFiles + 1;
      TotalBytes := TotalBytes + aFile.Size;
    end;

    FFullFilesTree.Add(aFile);
    Entry := TChecksumEntry.Create;
    FChecksumsList.Add(Entry);
    Entry.Checksum := TargetPath;
    Entry.Algorithm := Algorithm;

    CheckOperationState;
    Exit;
  end;

  FChecksumsList.Clear;
  for CurrentFileIndex := 0 to Files.Count - 1 do
  begin
    aFile := Files[CurrentFileIndex];
    FCheckSumFile.Clear;
    FCheckSumFile.NameValueSeparator:= #32;
    FCheckSumFile.LoadFromFile(aFile.FullPath);

    if (FCheckSumFile.Count = 0) then Continue;

    Algorithm := FileExtToHashAlg(aFile.Extension);

    if (Algorithm = HASH_SFV) and (FCheckSumFile[0] = SFV_HEADER) then
      InitializeRightToLeft(aFile.Path)
    else begin
      InitializeLeftToRight(aFile.Path);
    end;
  end;
end;

function TFileSystemCalcChecksumOperation.CalcChecksumProcessFile(aFile: TFile): Boolean;
var
  FileName: String;
  sCheckSum: String;
begin
  Result := False;
  FileName := aFile.Path + aFile.Name;

  if not OneFile then
  begin
    FCheckSumFile.Clear;
    if Algorithm = HASH_SFV then
    begin
      FCheckSumFile.Add(SFV_HEADER);
      FCheckSumFile.Add(DC_HEADER);
    end;
  end;

  CheckSumCalc(aFile, sCheckSum);

  if Algorithm = HASH_SFV then
  begin
    FCheckSumFile.Add(ExtractDirLevel(FFullFilesTree.Path,
                                      aFile.Path) + aFile.Name + ' ' + sCheckSum);
  end
  else begin
    FCheckSumFile.Add(sCheckSum + ' *' + ExtractDirLevel(FFullFilesTree.Path,
                                                         aFile.Path) + aFile.Name);
  end;

  if not OneFile then
    try
      FCheckSumFile.SaveToFile(FileName + '.' + HashFileExt[Algorithm]);
    except
      on E: EFCreateError do
        AskQuestion(rsMsgErrECreate + ' ' + FileName + '.' + HashFileExt[Algorithm] + ':',
                                 E.Message, [fsourOk], fsourOk, fsourOk);
      on E: EWriteError do
        AskQuestion(rsMsgErrEWrite + ' ' + FileName + '.' + HashFileExt[Algorithm] + ':',
                               E.Message, [fsourOk], fsourOk, fsourOk);
    end;
end;

function TFileSystemCalcChecksumOperation.VerifyChecksumProcessFile(
           aFile: TFile; ExpectedChecksum: String): Boolean;
var
  sCheckSum: String;
  sFileName: String;
begin
  Result:= False;
  sFileName:= ExtractDirLevel(FFullFilesTree.Path, aFile.Path) + aFile.Name;

  if (CheckSumCalc(aFile, sCheckSum) = False) then
    AddString(FResult.ReadError, sFileName)
  else
    begin
      if (CompareText(sCheckSum, ExpectedChecksum) = 0) then
        AddString(FResult.Success, sFileName)
      else
        AddString(FResult.Broken, sFileName);
    end;
end;

function TFileSystemCalcChecksumOperation.CheckSumCalc(aFile: TFile; out
  aValue: String): Boolean;
var
  hFile: THandle;
  Context: THashContext;
  BytesRead, BytesToRead: Int64;
  bRetryRead: Boolean;
  TotalBytesToRead: Int64 = 0;
begin
  hFile := feInvalidHandle;
  BytesToRead := FBufferSize;

  HashInit(Context, Algorithm);
  try
    hFile:= mbFileOpen(aFile.FullPath, fmOpenRead or fmShareDenyNone);

    Result:= hFile <> feInvalidHandle;
    if Result then
      begin
        TotalBytesToRead := mbFileSize(aFile.FullPath);

        while TotalBytesToRead > 0 do
        begin
          // Without the following line the reading is very slow
          // if it tries to read past end of file.
          if TotalBytesToRead < BytesToRead then
            BytesToRead := TotalBytesToRead;

          repeat
            try
              bRetryRead := False;
              BytesRead := FileRead(hFile, FBuffer^, BytesToRead);

              if (BytesRead = 0) then
                Raise EReadError.Create(mbSysErrorMessage(GetLastOSError));

              TotalBytesToRead := TotalBytesToRead - BytesRead;

              HashUpdate(Context, FBuffer^, BytesRead);

            except
              on E: EReadError do
                begin
                  if gSkipFileOpError then
                  begin
                    LogMessage(rsMsgErrERead + ' ' + aFile.FullPath + ': ' + E.Message,
                               [], lmtError);
                    Exit(False);
                  end
                  else
                  case AskQuestion(rsMsgErrERead + ' ' + aFile.FullPath + ': ',
                                   E.Message,
                                   [fsourRetry, fsourSkip, fsourAbort],
                                   fsourRetry, fsourSkip) of
                    fsourRetry:
                      bRetryRead := True;
                    fsourAbort:
                      RaiseAbortOperation;
                    fsourSkip:
                      Exit(False);
                  end; // case
                end;
            end;
          until not bRetryRead;

          with FStatistics do
          begin
            CurrentFileDoneBytes := CurrentFileDoneBytes + BytesRead;
            DoneBytes := DoneBytes + BytesRead;

            UpdateStatistics(FStatistics);
          end;

          CheckOperationState; // check pause and stop
        end;//while
      end;

  finally
    HashFinal(Context, aValue);
    if hFile <> feInvalidHandle then
    begin
      FileClose(hFile);
      hFile := feInvalidHandle;
    end;
  end;
end;

procedure TFileSystemCalcChecksumOperation.LogMessage(sMessage: String; logOptions: TLogOptions; logMsgType: TLogMsgType);
begin
  case logMsgType of
    lmtError:
      if not (log_errors in gLogOptions) then Exit;
    lmtInfo:
      if not (log_info in gLogOptions) then Exit;
    lmtSuccess:
      if not (log_success in gLogOptions) then Exit;
  end;

  if logOptions <= gLogOptions then
  begin
    logWrite(Thread, sMessage, logMsgType);
  end;
end;

end.
