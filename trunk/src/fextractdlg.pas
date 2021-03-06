{
   Double Commander
   -------------------------------------------------------------------------
   File unpacking window

   Copyright (C) 2007-2015 Alexander Koblov (alexx2000@mail.ru)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

}

unit fExtractDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, EditBtn, ExtCtrls, Buttons,
  Menus, DividerBevel, uFile, uFileSource, uArchiveFileSource, fButtonForm,
  uOperationsManager;

type

  { TfrmExtractDlg }

  TfrmExtractDlg = class(TfrmButtonForm)
    cbExtractPath: TCheckBox;
    cbInSeparateFolder: TCheckBox;
    cbOverwrite: TCheckBox;
    DividerBevel: TDividerBevel;
    edtPassword: TEdit;
    edtExtractTo: TDirectoryEdit;
    lblExtractTo: TLabel;
    lblPassword: TLabel;
    cbFileMask: TComboBox;
    lblFileMask: TLabel;
    pnlCheckBoxes: TPanel;
    pnlLabels: TPanel;
    procedure cbExtractPathChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FArcType: String;
    procedure SwitchOptions;
    procedure ExtractArchive(ArchiveFileSource: IArchiveFileSource; TargetFileSource: IFileSource;
                             const TargetPath: String; QueueId: TOperationsManagerQueueIdentifier);
  public
    { public declarations }
  end;

// Frees 'SourceFiles'.
procedure ShowExtractDlg(SourceFileSource: IFileSource; var SourceFiles: TFiles;
                         TargetFileSource: IFileSource; sDestPath: String);

implementation

{$R *.lfm}

uses
  Dialogs,
  uGlobs, uDCUtils, uShowMsg, uLng, DCStrUtils,
  uFileSourceOperation,
  uFileSystemFileSource,
  uArchiveFileSourceUtil,
  uFileSourceOperationTypes,
  uMultiArchiveFileSource,
  uMultiArchiveCopyOutOperation,
  uWcxArchiveFileSource,
  uWcxArchiveCopyOutOperation,
  uFileSourceOperationOptions,
  uMasks;

function GetTargetPath(FileSource: IArchiveFileSource; const TargetPath: String): String;
begin
  // if destination path is not absolute then extract to path there archive is located
  if GetPathType(TargetPath) <> ptAbsolute then
    Result := GetAbsoluteFileName(ExtractFilePath(FileSource.ArchiveFileName), TargetPath)
  else
    Result := IncludeTrailingPathDelimiter(TargetPath);
end;

procedure ShowExtractDlg(SourceFileSource: IFileSource; var SourceFiles: TFiles;
                         TargetFileSource: IFileSource; sDestPath: String);
var
  I: integer;
  Operation: TFileSourceOperation;
  ArchiveFileSource: IArchiveFileSource;
  extractDialog: TfrmExtractDlg;
  Result: boolean;
begin
  if not TargetFileSource.IsClass(TFileSystemFileSource) then
  begin
    msgWarning(rsMsgErrNotSupported);
    Exit;
  end;

  extractDialog := TfrmExtractDlg.Create(nil);
  if Assigned(extractDialog) then
    try
      with extractDialog do
      begin
        edtExtractTo.Text := sDestPath;

        if SourceFileSource.IsClass(TArchiveFileSource) then
          cbInSeparateFolder.Visible := False;
        cbFileMask.Items.Assign(glsMaskHistory);
        EnableControl(edtPassword, False);

        // If one archive is selected
        if (SourceFiles.Count = 1) then
        begin
          FArcType:= SourceFiles[0].Extension;
          SwitchOptions;
        end;

        // Show form
        Result := (ShowModal = mrOk);

        if Result then
        begin
          if glsMaskHistory.IndexOf(cbFileMask.Text) < 0 then
            glsMaskHistory.Add(cbFileMask.Text);

          sDestPath := edtExtractTo.Text;

          // if in archive
          if SourceFileSource.IsClass(TArchiveFileSource) then
          begin
            if fsoCopyOut in SourceFileSource.GetOperationsTypes then
            begin
              sDestPath := GetTargetPath(SourceFileSource as IArchiveFileSource, sDestPath);

              Operation := SourceFileSource.CreateCopyOutOperation(TargetFileSource, SourceFiles, sDestPath);

              if Assigned(Operation) then
              begin
                // Start operation.
                OperationsManager.AddOperation(Operation, QueueIdentifier, False);
              end
              else
                msgWarning(rsMsgNotImplemented);
            end
            else
              msgWarning(rsMsgErrNotSupported);
          end
          else
          // if filesystem
          if SourceFileSource.IsClass(TFileSystemFileSource) then
          begin
            for I := 0 to SourceFiles.Count - 1 do // extract all selected archives
            begin
              try
                // Check if there is a ArchiveFileSource for possible archive.
                ArchiveFileSource := GetArchiveFileSource(SourceFileSource, SourceFiles[i]);

                // Extract current item, if files count > 1 then put to queue
                if (I > 0) and (QueueIdentifier = FreeOperationsQueueId) then
                  ExtractArchive(ArchiveFileSource, TargetFileSource, sDestPath, SingleQueueId)
                else
                  ExtractArchive(ArchiveFileSource, TargetFileSource, sDestPath, QueueIdentifier);

              except
                on E: Exception do
                begin
                  MessageDlg(E.Message, mtError, [mbOK], 0);
                end;
              end;
            end; // for
          end
          else
            msgWarning(rsMsgErrNotSupported);

        end; // if Result
      end;

    finally
      if Assigned(extractDialog) then
        FreeAndNil(extractDialog);
      if Assigned(SourceFiles) then
        FreeAndNil(SourceFiles);
    end;
end;

{ TfrmExtractDlg }

procedure TfrmExtractDlg.FormCreate(Sender: TObject);
begin
  InitPropStorage(Self);
end;

procedure TfrmExtractDlg.cbExtractPathChange(Sender: TObject);
begin
  SwitchOptions;
end;

procedure TfrmExtractDlg.SwitchOptions;
var
  I: LongInt;
begin
  // Check for this archive will be processed by MultiArc
  for I := 0 to gMultiArcList.Count - 1 do
    with gMultiArcList.Items[I] do
    begin
      if FEnabled and MatchesMaskList(FArcType, FExtension, ',') then
      begin
        // If addon supports unpacking without path
        if (Length(FExtractWithoutPath) <> 0) then
          cbExtractPath.Enabled:= True
        else
          begin
            cbExtractPath.Enabled:= False;
            cbExtractPath.Checked:= True;
          end;
        // If addon supports unpacking with password
        if cbExtractPath.Checked then
          EnableControl(edtPassword, (Pos('%W', FExtract) <> 0))
        else
          EnableControl(edtPassword, (Pos('%W', FExtractWithoutPath) <> 0));
        Break;
      end;
    end;
end;

procedure TfrmExtractDlg.ExtractArchive(ArchiveFileSource: IArchiveFileSource;
  TargetFileSource: IFileSource; const TargetPath: String;
  QueueId: TOperationsManagerQueueIdentifier);
var
  FilesToExtract: TFiles;
  Operation: TFileSourceOperation;
  sTmpPath: string;
begin
  if Assigned(ArchiveFileSource) then
  begin
    // Check if List and CopyOut are supported.
    if [fsoList, fsoCopyOut] * ArchiveFileSource.GetOperationsTypes = [fsoList, fsoCopyOut] then
    begin
      // Get files to extract.
      FilesToExtract := ArchiveFileSource.GetFiles(ArchiveFileSource.GetRootDir);

      if Assigned(FilesToExtract) then
        try
          sTmpPath := GetTargetPath(ArchiveFileSource, TargetPath);

          // if each archive in separate folder
          if cbInSeparateFolder.Checked then
          begin
            sTmpPath := sTmpPath + ExtractOnlyFileName(ArchiveFileSource.ArchiveFileName) + PathDelim;
          end;

          // extract all files
          Operation := ArchiveFileSource.CreateCopyOutOperation(TargetFileSource, FilesToExtract, sTmpPath);

          // Set operation specific options
          if Assigned(Operation) then
          begin
            if ArchiveFileSource.IsInterface(IMultiArchiveFileSource) then
            begin
              with Operation as TMultiArchiveCopyOutOperation do
              begin
                Password := edtPassword.Text;
                ExtractWithoutPath:= not cbExtractPath.Checked;
              end;
            end
            else if ArchiveFileSource.IsInterface(IWcxArchiveFileSource) then
            begin
              with Operation as TWcxArchiveCopyOutOperation do
              begin
                if cbOverwrite.Checked then
                  FileExistsOption := fsoofeOverwrite;
                ExtractWithoutPath:= not cbExtractPath.Checked;
              end;
            end;

            // Start operation.
            OperationsManager.AddOperation(Operation, QueueId, False);
          end
          else
            msgWarning(rsMsgNotImplemented);

        finally
          if Assigned(FilesToExtract) then
            FreeAndNil(FilesToExtract);
        end;
    end
    else
      msgWarning(rsMsgErrNotSupported);

  end;
end;

end.

