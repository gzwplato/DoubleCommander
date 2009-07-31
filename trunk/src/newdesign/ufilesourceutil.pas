unit uFileSourceUtil;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uFileView, uFile;

procedure ChooseFile(aFileView: TFileView; aFile: TFile);

implementation

uses
  uFileSource, uFileSystemFileSource, uGlobs, uShellExecute, uOSUtils,
  LCLProc;

procedure ChooseFile(aFileView: TFileView; aFile: TFile);
var
  sOpenCmd: String;
  i: Integer;
  FileSource: TFileSource;
begin
  // For now work only for FileSystem until temporary file system is done.
  if aFileView.FileSource is TFileSystemFileSource then
  begin
    //now test if exists Open command in doublecmd.ext :)
    sOpenCmd:= gExts.GetExtActionCmd(aFile, 'open');
    if (sOpenCmd<>'') then
    begin
{
      if Pos('{!VFS}',sOpenCmd)>0 then
      begin
        if fVFS.FindModule(sName) then
        begin
          LoadPanelVFS(pfri);
          Exit;
        end;
      end;
}
      ReplaceExtCommand(sOpenCmd, aFile, aFileView.FileSource.CurrentPath);
      if ProcessExtCommand(sOpenCmd, aFileView.FileSource.CurrentPath) then
        Exit;
    end;

    // and at the end try to open by system
    mbSetCurrentDir(aFileView.FileSource.CurrentPath);
    ShellExecute(aFile.Name);
    aFileView.Reload;
  end;
end;

end.

