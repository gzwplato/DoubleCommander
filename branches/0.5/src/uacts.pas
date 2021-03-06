{
   Double Commander
   -------------------------------------------------------------------------
   This unit contains all DC actions

   Copyright (C) 2008  Dmitry Kolomiets (B4rr4cuda@rambler.ru)
   Copyright (C) 2008-2009  Koblov Alexander (Alexx2000@mail.ru)

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

unit uActs;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils, Dialogs, StringHashList, ActnList,
  uFileView, uFileViewNotebook, uFileSourceOperation, uFileFunctions,
  fViewer;
  
  
const cf_Null=0;
      cf_Error=-1;

  type

  TCommandFunc = procedure(param: string) of object;

  PActionState = ^TActionState;
  TActionState = record
    Enabled: Boolean;  //<en Whether the action is enabled (through hotkeys).
    Action: TAction;   //<en If a TAction is assigned to a named action,
                       //    it is cached here.
  end;

  { TActs }

  TActs=class
  private
   FCmdList:TStrings;
   function GetList:TStrings;
   procedure EnableAction(ActionState: PActionState; Enabled: Boolean);
   class function Methods(AClass:TClass) : TStringList;

   procedure ShowException(e: Exception);

   procedure OnCalcStatisticsStateChanged(Operation: TFileSourceOperation;
                                          State: TFileSourceOperationState);
   procedure OnCalcChecksumStateChanged(Operation: TFileSourceOperation;
                                        State: TFileSourceOperationState);
   procedure GetCommandFromBar (const cFilename, cParam: string;
                                var Com, Par, Pat:string);
  public
   FActionsState: TStringHashList;
   constructor Create;
   destructor Destroy;override;
   function Execute(Cmd: string; param:string =''): integer;
   function GetIndex(Cmd: string): integer;
   function GetCategoriesList(const List:TStrings):integer;
   function GetCommandsByCategory(Category:string; const List:TStrings):integer;
   function GetCommandCaption(sCommand: String; bAmpersand: Boolean = False): UTF8String;

   {en
      Adds a named action to a list of possible actions.
      @param(ActionName
             Name of the action _without_ any prefixes ('cm_' or 'act').)
   }
   procedure AddAction(ActionName: String);
   {en
      Adds a TAction to a list of possible actions.
   }
   procedure AddAction(Action: TAction);
   {en
      Enables/disables an action.
      @param(ActionName
             Name of the action _without_ any prefixes ('cm_' or 'act').)
      @param(Enable
             Whether to enable or disable the action.)
   }
   procedure EnableAction(ActionName: String; Enable: Boolean);
   {en
      Checks if the action is enabled.
      @param(ActionName
             Name of the action _without_ any prefixes ('cm_' or 'act').)
   }
   function  IsActionEnabled(ActionName: String): Boolean;
   procedure EnableAllActions(Enable: Boolean);

   //---------------------
   // The Do... functions are cm_... functions' counterparts which are to be
   // executed directly from the code with specific - especially non-string
   // - arguments (instead of calling cm_... functions, in which case
   // parameters would have to be converted to and from strings).
   //
   procedure DoRemoveTab(Notebook: TFileViewNotebook; PageIndex: Integer);
   procedure DoCopySelectedFileNamesToClipboard(FileView: TFileView; FullNames: Boolean);
   procedure DoNewTab(Notebook: TFileViewNotebook);
   procedure DoContextMenu(Panel: TFileView; X, Y: Integer; Background: Boolean);
   procedure DoTransferPath(SourcePage: TFileViewPage; TargetPage: TFileViewPage);
   procedure DoSortByFunctions(View: TFileView; FileFunctions: TFileFunctions);
   procedure DoShowMainMenu(bShow: Boolean);
   //---------------------

  published

   //--------------------------------------------------------------------------
   // The cm_... functions are 'user' functions which can be assigned to toolbar
   // button, hotkey, menu item, scripts, etc. Those functions take a string
   // parameter(s) set by the user.
   //
   //--------------------------------------------------------------------------
   // Only published functions and procedures can by found by MethodAddress
   //--------------------------------------------------------------------------
   //
   // All commands can be split into three groups:
   // 1. Global commands intended for the main application (cm_VisitHomePage,
   //    cm_About, cm_Exit, ...).
   //
   // 2. Commands intended for file views (cm_QuickSearch, cm_EditPath, etc.).
   //    Those commands are simply redirected to the currently active file view by calling:
   //       frmMain.ActiveFrame.ExecuteCommand(CommandName, param);
   //    If they are supported by the given file view they are executed there.
   //
   //    If in future there will be a need to pass specific parameters to the
   //    commands, i.e. not string, they should be implemented by creating
   //    an interface for each command, and each file view implementing those
   //    interfaces which commands it supports.
   //
   // 3. Commands intended for file sources (cm_Copy, cm_Rename, cm_MakeDir).
   //    The file operations will mostly work only for non-virtual file sources.
   //
   procedure cm_AddPathToCmdLine(param: string='');
   procedure cm_AddFilenameToCmdLine(param: string='');
   procedure cm_AddPathAndFilenameToCmdLine(param: string='');
   procedure cm_ContextMenu(param: string='');
   procedure cm_CopyFullNamesToClip(param: string='');
   procedure cm_Exchange(param:string='');
   procedure cm_OpenArchive(param:string='');
   procedure cm_TestArchive(param:string='');
   procedure cm_OpenDirInNewTab(param:string='');
   procedure cm_Open(param:string='');
   procedure cm_OpenVirtualFileSystemList(param:string='');
   procedure cm_TargetEqualSource(param:string='');
   procedure cm_LeftEqualRight(param:string='');
   procedure cm_RightEqualLeft(param:string='');
   procedure cm_PackFiles(param: string='');
   procedure cm_ExtractFiles(param: string='');
   procedure cm_QuickSearch(param: string='');
   procedure cm_QuickFilter(param: string='');
   procedure cm_LeftOpenDrives(param:string='');
   procedure cm_RightOpenDrives(param: string='');
   procedure cm_OpenBar(param: string='');
   procedure cm_ShowButtonMenu(param: string='');
   procedure cm_TransferLeft(param: string='');
   procedure cm_TransferRight(param: string='');
   procedure cm_GoToFirstFile(param: string='');
   procedure cm_GoToLastFile(param: string='');
   procedure cm_Minimize(param: string='');
   procedure cm_Wipe(param: string='');
   procedure cm_Exit(param: string='');
   procedure cm_NewTab(param: string='');
   procedure cm_RenameTab(param: string='');
   procedure cm_RemoveTab(param: string='');
   procedure cm_RemoveAllTabs(param: string='');
   procedure cm_NextTab(param: string='');
   procedure cm_PrevTab(param: string='');
   procedure cm_SetTabOptionNormal(param: string='');
   procedure cm_SetTabOptionPathLocked(param: string='');
   procedure cm_SetTabOptionPathResets(param: string='');
   procedure cm_SetTabOptionDirsInNewTab(param: string='');
   procedure cm_Copy(param: string='');
   procedure cm_CopyNoAsk(param: string='');
   procedure cm_Delete(param: string='');
   procedure cm_CheckSumCalc(param:string);
   procedure cm_CheckSumVerify(param:string);
   procedure cm_Edit(param: string='');
   procedure cm_EditPath(param: string='');
   procedure cm_MakeDir(param: string='');
   procedure cm_Rename(param: string='');
   procedure cm_RenameNoAsk(param: string='');
   procedure cm_View(param: string='');
   procedure cm_QuickView(param: string='');
   procedure cm_CopyNamesToClip(param: string='');
   procedure cm_FocusCmdLine(param: string='');
   procedure cm_FileAssoc(param: string='');
   procedure cm_HelpIndex(param: string='');
   procedure cm_Keyboard(param: string='');
   procedure cm_VisitHomePage(param: string='');
   procedure cm_About(param: string='');
   procedure cm_ShowSysFiles(param: string='');
   procedure cm_SwitchIgnoreList(param: string='');
   procedure cm_Options(param: string='');
   procedure cm_CompareContents(param: string='');
   procedure cm_Refresh(param: string='');
   procedure cm_ShowMainMenu(param: string='');
   procedure cm_DirHotList(param: string='');
   procedure cm_MarkInvert(param: string='');
   procedure cm_MarkMarkAll(param: string='');
   procedure cm_MarkUnmarkAll(param: string='');
   procedure cm_MarkPlus(param: string='');
   procedure cm_MarkMinus(param: string='');
   procedure cm_MarkCurrentExtension(param: string='');
   procedure cm_UnmarkCurrentExtension(param: string='');
   procedure cm_SaveSelection(param: string='');
   procedure cm_RestoreSelection(param: string='');
   procedure cm_SaveSelectionToFile(param: string='');
   procedure cm_LoadSelectionFromFile(param: string='');
   procedure cm_LoadSelectionFromClip(param: string='');
   procedure cm_Search(param: string='');
   procedure cm_HardLink(param: string='');
   procedure cm_MultiRename(param: string='');
   procedure cm_ReverseOrder(param: string='');
   procedure cm_SortByAttr(param: string='');
   procedure cm_SortByDate(param: string='');
   procedure cm_SortByExt(param: string='');
   procedure cm_SortByName(param: string='');
   procedure cm_SortBySize(param: string='');
   procedure cm_SymLink(param: string='');
   procedure cm_CopySamePanel(param: string='');
   procedure cm_DirHistory(param: string='');
   procedure cm_ViewHistory(param: string='');
   procedure cm_ViewHistoryPrev(param: string='');
   procedure cm_ViewHistoryNext(param: string='');
   procedure cm_EditNew(param: string='');
   procedure cm_RenameOnly(param: string='');
   procedure cm_RunTerm(param: string='');
   procedure cm_ShowCmdLineHistory(param: string='');
   procedure cm_CalculateSpace(param: string='');
   procedure cm_CountDirContent(param: string='');
   procedure cm_SetFileProperties(param: string='');
   procedure cm_FileProperties(param: string='');
   procedure cm_FileLinker(param: string='');
   procedure cm_FileSpliter(param: string='');
   procedure cm_PanelsSplitterPerPos(param: string='');
   procedure cm_EditComment(param: string='');
   procedure cm_CopyToClipboard(param: string='');
   procedure cm_CutToClipboard(param: string='');
   procedure cm_PasteFromClipboard(param: string='');
   procedure cm_ChangeDirToRoot(param: string='');
   procedure cm_ChangeDirToParent(param: string='');
   procedure cm_ChangeDir(param: string='');
   procedure cm_ClearLogWindow(param: string='');
   procedure cm_ClearLogFile(param: string='');
   procedure cm_NetworkConnect(param: string='');
   procedure cm_NetworkDisconnect(param: string='');
   procedure cm_HorizontalFilePanels(param: string='');
   procedure cm_OperationsViewer(param: string='');
   // Internal commands
   procedure cm_Int_RunCommandFromBarFile(param: string='');

   // Viewer
   procedure cm_Viewer_About(param: string='');
   procedure cm_Viewer_DeleteFile(param: string='');
   procedure cm_Viewer_NextFile(param: string='');

   //---------------------
   {   procedure SomeFunction (param:string; var Result:integer);
   procedure SomeProcedure(param:string);
   procedure Mess(param:string);}
   //---------------------
   property CommandList:TStrings read FCmdList; //be careful with these list's objects.
  end;

implementation

uses Forms, Controls, Clipbrd, strutils, LCLProc, HelpIntfs, dmHelpManager,
     fMain, fPackDlg, fFileOpDlg, fMkDir, fFileAssoc, fExtractDlg, fAbout,
     fOptions, fDiffer, fFindDlg, fSymLink, fHardLink, fMultiRename,
     fLinker, fSplitter, fDescrEdit, fCheckSumVerify, fCheckSumCalc, fSetFileProperties,
     uGlobs, uLng, uLog, uShowMsg, uOSForms, uOSUtils, uDCUtils, uGlobsPaths,
     uClassesEx, uShowForm, uShellExecute, uClipboard, uHash,
     uFilePanelSelect, uFile, uFileSystemFileSource, uQuickViewPanel,
     uOperationsManager, uFileSourceOperationTypes, uWfxPluginFileSource,
     uFileSystemDeleteOperation, uFileSourceExecuteOperation,
     uFileSourceOperationMessageBoxesUI, uFileSourceCalcChecksumOperation,
     uFileSourceCalcStatisticsOperation, uFileSource, uFileSourceProperty,
     uVfsFileSource, uFileSourceUtil, uArchiveFileSourceUtil,
     uTempFileSystemFileSource, uFileProperty, uFileSourceSetFilePropertyOperation,
     uFileSorting, uShellContextMenu, uTrash, uFileSystemCopyOperation, uFindEx,
     uTypes, fViewOperations, uVfsModule, uMultiListFileSource;

{ TActs }

class function TActs.Methods(AClass:TClass): TStringList;
//------------------------------------------------------
    type
       pmethodnamerec = ^tmethodnamerec;
       tmethodnamerec = packed record
          name : pshortstring;
          addr : pointer;
       end;

       tmethodnametable = packed record
         count : dword;
         entries : tmethodnamerec; // first entry
         // subsequent tmethodnamerec records follow
       end;

       pmethodnametable =  ^tmethodnametable;

var
 methodtable : pmethodnametable;
 i : dword;
 vmt : tclass;
 pentry: pmethodnamerec;

begin
   Result:=TStringList.Create;
   vmt:=AClass;
   while assigned(vmt) do
     begin
        methodtable:=pmethodnametable((Pointer(vmt)+vmtMethodTable)^);
        if assigned(methodtable) then
        begin
          pentry := @methodtable^.entries;
          for i:=0 to methodtable^.count-1 do
            Result.AddObject(pentry[i].name^,Tobject(AClass));
        end;
        vmt:=pclass(pointer(vmt)+vmtParent)^;
     end;
end;
//------------------------------------------------------


function TActs.GetList: TStrings;
begin
  Result:=Methods(Self.ClassType);
end;


constructor TActs.Create;
var
  i: Integer;
begin
  FCmdList:=GetList;
  FActionsState:=TStringHashList.Create(False); // not case-sensitive

  for i:=0 to FCmdList.Count - 1 do
    AddAction(Copy(FCmdList.Strings[i], 4,
                   Length(FCmdList.Strings[i]) - 3));
end;

destructor TActs.Destroy;
var
  i: Integer;
begin
  if Assigned(FCmdList) then FreeAndNil(FCmdList);
  if Assigned(FActionsState) then
  begin
    for i := 0 to FActionsState.Count - 1 do
      if Assigned(FActionsState.List[i]^.Data) then
        Dispose(PActionState(FActionsState.List[i]^.Data));

    FreeAndNil(FActionsState);
  end;
  inherited Destroy;
end;

function TActs.Execute(Cmd: string; param:string =''): integer;
var t:TMethod; ind:integer;
begin
    Result:=cf_Error;
    ind:={FCmdList.IndexOf(cmd);}GetIndex(Cmd);
    if ind=-1 then exit;
    if not Assigned(FCmdList.Objects[ind]) then exit;
    t.Data:=TClass(FCmdList.Objects[ind]).ClassInfo;
    t.Code:=TClass(FCmdList.Objects[ind]).MethodAddress(cmd);
    if Assigned(t.code) then
    begin
     Result:=cf_Null;
        TCommandFunc(t)(param);
  end;
end;


function TActs.GetIndex(Cmd: string): integer;
//------------------------------------------------------
    Function DoCompareText(const s1,s2 : string) : PtrInt;
      begin
        result:=CompareText(upcase(s1),upcase(s2));
      end;
    //---------------------
begin
  Result:=0;
  with FCmdList do
  begin
    While (Result<Count) and (DoCompareText(Strings[Result],Cmd)<>0) do Result:=Result+1;
    if Result=Count then Result:=-1;
  end;
end;

function TActs.GetCategoriesList(const List: TStrings): integer;
var s:string; i,p:integer;
begin
  List.Clear;
  for i:=0 to CommandList.Count-1 do
    begin
     s:=CommandList[i];
     //find forms
     if Pos('cm_',s)>0 then
       begin
         s:=copy(s,4,length(s)-3);
         p:=pos('_',s);
         if p>0 then
           begin
             s:=copy(s,1,p-1);
             if list.IndexOf(s)=-1 then
               List.Add(s);
           end
         else
           begin
            if list.IndexOf('Main')=-1 then
              List.Add('Main');
           end;
       end;
    end;
  result:=List.Count;
end;

function TActs.GetCommandsByCategory(Category: string; const List: TStrings
  ): integer;
var i:integer; s:string;
begin
  List.Clear;
  if Category='Main' then
    begin
    for i:=0 to CommandList.Count-1 do
      begin
       s:=CommandList[i];
       delete(s,1,3);
       if pos('_',s)=0 then
         List.Add(CommandList[i]);
      end;
    end
  else
    begin
      s:='cm_'+Category+'_';
      for i:=0 to CommandList.Count-1 do
       if pos(s,CommandList[i])>0 then
         List.Add(CommandList[i]);
    end;

  Result:=List.Count;
end;

function TActs.GetCommandCaption(sCommand: String; bAmpersand: Boolean): UTF8String;
//< find Comment for command
// command=caption of action assigned to command
var
  myAct: TContainedAction;
  lstr: String;
begin
  Result:= '';
  with frmMain.actionLst do
  begin
    lstr:= Copy(sCommand, 4, Length(sCommand) - 3);// get action name
    myAct:= ActionByName('act' + lstr); // get action
    if (myAct <> nil) and (myAct is TAction) then // if action exist and action is TAction. its Need?
      begin
        lstr:= (myAct as TAction).Caption; //copy caption
        if not bAmpersand then
          while pos('&', lstr) <> 0 do Delete(lstr, Pos('&', lstr), 1); //delete all ampersand
        Result:= lstr;
      end;
  end;
end;

procedure TActs.AddAction(ActionName: String);
var
  ActionState: PActionState;
begin
  if FActionsState.Find(ActionName) = -1 then
  begin
    New(ActionState);

    if Assigned(ActionState) then
    try
      ActionState^.Enabled := True;
      ActionState^.Action := nil;

      FActionsState.Add(ActionName, ActionState);
    except
      Dispose(ActionState);
    end;
  end;
end;

procedure TActs.AddAction(Action: TAction);
var
  ActionState: PActionState;
  ActionNameWithoutPrefix: string;
  Index: Integer;
begin
  ActionNameWithoutPrefix := Copy(Action.Name, 4, Length(Action.Name) - 3);

  Index := FActionsState.Find(ActionNameWithoutPrefix);
  if Index = -1 then
  begin
    New(ActionState);

    if Assigned(ActionState) then
    try
      ActionState^.Enabled := True;
      ActionState^.Action := Action;

      FActionsState.Add(ActionNameWithoutPrefix, ActionState);
    except
      Dispose(ActionState);
    end;
  end
  else
  begin
    // Action already exists. Update TAction reference.
    PActionState(FActionsState.List[Index]^.Data)^.Action := Action;
  end;
end;

procedure TActs.EnableAction(ActionState: PActionState; Enabled: Boolean);
begin
  if Assigned(ActionState) then
  begin
    ActionState^.Enabled := Enabled;
    if Assigned(ActionState^.Action) then
      ActionState^.Action.Enabled := Enabled;
  end;
end;

procedure TActs.EnableAction(ActionName: String; Enable: Boolean);
var
  ActionState: PActionState;
begin
  ActionState := FActionsState[ActionName];
  if Assigned(ActionState) then
    EnableAction(ActionState, Enable)
  else
    raise Exception.Create('Invalid Action Name: ' + ActionName);
end;

function TActs.IsActionEnabled(ActionName: String): Boolean;
var
  ActionState: PActionState;
begin
  ActionState := FActionsState[ActionName];
  if Assigned(ActionState) then
    Result := ActionState^.Enabled
  else
    raise Exception.Create('Invalid Action Name: ' + ActionName);
end;

procedure TActs.EnableAllActions(Enable: Boolean);
var
  i: Integer;
begin
  for i := 0 to FActionsState.Count - 1 do
    EnableAction(PActionState(FActionsState.List[i]^.Data), Enable);
end;

procedure TActs.ShowException(e: Exception);
begin
  MessageDlg(Application.Title, rsMsgLogError + LineEnding + e.Message, mtError, [mbOK], 0);
end;

//------------------------------------------------------

procedure TActs.OnCalcStatisticsStateChanged(Operation: TFileSourceOperation;
                                             State: TFileSourceOperationState);
var
  CalcStatisticsOperation: TFileSourceCalcStatisticsOperation;
  CalcStatisticsOperationStatistics: TFileSourceCalcStatisticsOperationStatistics;
begin
  if (State = fsosStopped) and (Operation.Result = fsorFinished) then
  begin
    CalcStatisticsOperation := Operation as TFileSourceCalcStatisticsOperation;
    CalcStatisticsOperationStatistics := CalcStatisticsOperation.RetrieveStatistics;
    with CalcStatisticsOperationStatistics do
    begin
      msgOK(Format(rsSpaceMsg, [Files, Directories, cnvFormatFileSize(Size), Numb2USA(IntToStr(Size))]));
    end;
  end;
end;

procedure TActs.OnCalcChecksumStateChanged(Operation: TFileSourceOperation;
                                           State: TFileSourceOperationState);
var
  CalcChecksumOperation: TFileSourceCalcChecksumOperation;
begin
  if (State = fsosStopped) and (Operation.Result = fsorFinished) then
  begin
    CalcChecksumOperation := Operation as TFileSourceCalcChecksumOperation;
    if CalcChecksumOperation.Mode = checksum_verify then
      ShowVerifyCheckSum(CalcChecksumOperation.Result);
  end;
end;

//------------------------------------------------------

procedure TActs.DoRemoveTab(Notebook: TFileViewNotebook; PageIndex: Integer);
begin
  with frmMain do
  begin
    RemovePage(Notebook, PageIndex);
    ActiveFrame.SetFocus;
  end;
end;

procedure TActs.DoCopySelectedFileNamesToClipboard(FileView: TFileView; FullNames: Boolean);
var
  I: Integer;
  sl: TStringList = nil;
  SelectedFiles: TFiles = nil;
  PathToAdd: String;
begin
  SelectedFiles := FileView.CloneSelectedFiles;
  try
    if SelectedFiles.Count > 0 then
    begin
      sl := TStringList.Create;
      for I := 0 to SelectedFiles.Count - 1 do
      begin
        if FullNames then
        begin
          // Workaround for not fully implemented TMultiListFileSource.
          if not FileView.FileSource.IsClass(TMultiListFileSource) then
            PathToAdd := FileView.CurrentAddress
          else
            PathToAdd := '';
          PathToAdd := PathToAdd + SelectedFiles[I].Path;
        end
        else
          PathToAdd := '';

        sl.Add(PathToAdd + SelectedFiles[I].Name);
      end;

      Clipboard.Clear;   // prevent multiple formats in Clipboard (specially synedit)
      Clipboard.AsText:= TrimRightLineEnding(sl.Text, sl.TextLineBreakStyle);
    end;

  finally
    if Assigned(sl) then
      FreeAndNil(sl);
    if Assigned(SelectedFiles) then
      FreeAndNil(SelectedFiles);
  end;
end;

procedure TActs.DoNewTab(Notebook: TFileViewNotebook);
var
  NewPage: TFileViewPage;
begin
  if tb_open_new_near_current in gDirTabOptions then
    NewPage := Notebook.InsertPage(Notebook.PageIndex + 1)
  else
    NewPage := Notebook.AddPage;
  Notebook.ActiveView.Clone(NewPage);
  NewPage.MakeActive;
  NewPage.UpdateCaption(GetLastDir(ExcludeTrailingPathDelimiter(NewPage.FileView.CurrentPath)));
end;

procedure TActs.DoContextMenu(Panel: TFileView; X, Y: Integer; Background: Boolean);
var
  aFile: TFile = nil;
  aFiles: TFiles = nil;
  sPath, sName: UTF8String;
begin
  // Temporarily work for Filesystem only.
  with frmMain do
  begin
    if not (Panel.FileSource.IsClass(TFileSystemFileSource)) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
    end;

    if Background then
      begin
        sName:= ExcludeTrailingPathDelimiter(Panel.CurrentPath);
        sPath:= ExtractFilePath(sName);
        aFiles:= TFiles.Create(sPath);
        aFile:= Panel.FileSource.CreateFileObject(sPath);
        aFile.Attributes:= faFolder;
        aFile.Name:= ExtractFileName(sName);
        aFiles.Add(aFile);
      end
    else
      begin
        aFiles:= Panel.CloneSelectedFiles;
      end;

    if Assigned(aFiles) then
    try
      if aFiles.Count > 0 then
      try
        ShowContextMenu(frmMain, aFiles, X, Y, Background, nil);
      except
        on e: EContextMenuException do
          ShowException(e);
      end;

    finally
      if Assigned(aFiles) then
        FreeAndNil(aFiles);
    end;
  end;
end;

procedure TActs.DoTransferPath(SourcePage: TFileViewPage; TargetPage: TFileViewPage);
var
  aFile: TFile;
  NewPath: String;
begin
  aFile := SourcePage.FileView.CloneActiveFile;
  if Assigned(aFile) then
  try
    if (fspLinksToLocalFiles in SourcePage.FileView.FileSource.GetProperties) and
       (SourcePage.FileView.FileSource.GetLocalName(aFile)) then
      begin
        if aFile.IsDirectory then
          ChooseFileSource(TargetPage.FileView, aFile.FullPath)
        else if not ChooseFileSource(TargetPage.FileView, aFile) then
          begin
            ChooseFileSource(TargetPage.FileView, aFile.Path);
            TargetPage.FileView.SetActiveFile(aFile.Name);
          end;
      end
    else if aFile.IsDirectory then
    begin
      if aFile.Name = '..' then
      begin
        NewPath := GetParentDir(SourcePage.FileView.CurrentPath)
      end
      else
      begin
        // Change to a subdirectory.
        NewPath := aFile.FullPath;
      end;

      if NewPath <> EmptyStr then
        TargetPage.FileView.AddFileSource(SourcePage.FileView.FileSource, NewPath);
    end
    else
    begin
      // Change file source, if the file under cursor can be opened as another file source.
      try
        if not ChooseFileSource(TargetPage.FileView, aFile) then
          TargetPage.FileView.AddFileSource(SourcePage.FileView.FileSource,
                                            SourcePage.FileView.CurrentPath);
      except
        on e: EFileSourceException do
          MessageDlg('Error', e.Message, mtError, [mbOK], 0);
      end;
    end;
  finally
    FreeAndNil(aFile);
  end;
end;

procedure TActs.DoSortByFunctions(View: TFileView; FileFunctions: TFileFunctions);
var
  NewSorting: TFileSortings = nil;
  CurrentSorting: TFileSortings;
  SortDirection: TSortDirection = sdNone;
  i: Integer;
begin
  if Length(FileFunctions) = 0 then
    Exit;

  CurrentSorting := View.Sorting;

  // Check if there is already sorting by one of the functions.
  // If it is then reverse direction of sorting.
  for i := 0 to Length(FileFunctions) - 1 do
  begin
    SortDirection := GetSortDirection(CurrentSorting, FileFunctions[i]);
    if SortDirection <> sdNone then
    begin
      SortDirection := ReverseSortDirection(SortDirection);
      Break;
    end;
  end;

  if SortDirection = sdNone then
    SortDirection := sdAscending;

  SetLength(NewSorting, 1);
  SetLength(NewSorting[0].SortFunctions, 1);
  NewSorting[0].SortFunctions[0] := FileFunctions[0]; // Sort by single function.
  NewSorting[0].SortDirection := SortDirection;

  View.Sorting := NewSorting;
end;

procedure TActs.DoShowMainMenu(bShow: Boolean);
begin
  gMainMenu := bShow;

  with frmMain do
  begin
    if bShow then
    begin
      Menu := mnuMain;
    end
    else if Assigned(Menu) then
    begin
      Menu := nil;
      {$IFDEF MSWINDOWS}
      // Workaround: on Windows need to recreate window to properly recalculate children sizes.
      RecreateWnd(frmMain);
      {$ENDIF}
    end;
  end;
end;

//------------------------------------------------------
//Published methods
//------------------------------------------------------

procedure TActs.cm_AddPathToCmdLine(param:string);
var
  OldPosition: Integer;
  AddedString: String;
begin
  with frmMain do
    begin
      OldPosition := edtCommand.SelStart;
      AddedString := QuoteStr(ActiveFrame.CurrentPath);
      edtCommand.Text := edtCommand.Text + AddedString;
      edtCommand.SelStart := OldPosition + Length(AddedString);
    end;
end;

procedure TActs.cm_AddFilenameToCmdLine(param: string='');
var
  AddedString: String;
  OldPosition: Integer;
  aFile: TFile;
begin
  with frmMain do
    begin
      aFile := ActiveFrame.CloneActiveFile;
      if Assigned(aFile) then
      try
        OldPosition := edtCommand.SelStart;
        AddedString := QuoteStr(aFile.Name) + ' ';
        edtCommand.Text := edtCommand.Text + AddedString;
        edtCommand.SelStart := OldPosition + Length(AddedString);
      finally
        FreeAndNil(aFile);
      end;
    end;
end;

procedure TActs.cm_AddPathAndFilenameToCmdLine(param: string='');
var
  AddedString: String;
  OldPosition: Integer;
  aFile: TFile;
begin
  with frmMain do
    begin
      aFile := ActiveFrame.CloneActiveFile;
      if Assigned(aFile) then
      try
        if aFile.Name = '..' then
          AddedString := QuoteStr(ActiveFrame.CurrentPath) + ' '
        else
          AddedString := QuoteStr(aFile.FullPath) + ' ';

        OldPosition := edtCommand.SelStart;
        edtCommand.Text := edtCommand.Text + AddedString;
        edtCommand.SelStart := OldPosition + Length(AddedString);
      finally
        FreeAndNil(aFile);
      end;
    end;
end;

procedure TActs.cm_ContextMenu(param:string);
begin
  // Let file view handle displaying context menu at appropriate position.
  frmMain.ActiveFrame.ExecuteCommand('cm_ContextMenu', '');
end;

procedure TActs.cm_CopyFullNamesToClip(param:string);
begin
  DoCopySelectedFileNamesToClipboard(frmMain.ActiveFrame, True);
end;

procedure TActs.cm_CopyNamesToClip(param:string);
begin
  DoCopySelectedFileNamesToClipboard(frmMain.ActiveFrame, False);
end;

//------------------------------------------------------
procedure TActs.cm_Exchange(param:string);
var
  sDir: String;
begin
  sDir:= FrmMain.ActiveFrame.CurrentPath;
  FrmMain.ActiveFrame.CurrentPath:= FrmMain.NotActiveFrame.CurrentPath;
  FrmMain.NotActiveFrame.CurrentPath:= sDir;
end;

procedure TActs.cm_OpenDirInNewTab(param:string);
var
  NewPage: TFileViewPage;
  NewPath: String;
  aFile: TFile;
begin
  with FrmMain do
  begin
    aFile := ActiveFrame.CloneActiveFile;
    if Assigned(aFile) then
    try
      if aFile.IsNameValid and
         (aFile.IsDirectory or aFile.IsLinkToDirectory) then
      begin
        NewPath := ActiveFrame.CurrentPath + aFile.Name;
        NewPage := ActiveNotebook.AddPage;
        ActiveFrame.Clone(NewPage);
        NewPage.FileView.CurrentPath := NewPath;
        if tb_open_new_in_foreground in gDirTabOptions then
          NewPage.MakeActive;
      end;
    finally
      FreeAndNil(aFile);
    end;
  end;
end;

procedure TActs.cm_TargetEqualSource(param:string);
begin
  with frmMain do
  begin
    NotActiveNotebook.ActivePage.FileView := nil;
    ActiveFrame.Clone(NotActiveNotebook.ActivePage);
    NotActiveNotebook.ActivePage.UpdateCaption(GetLastDir(
      ExcludeTrailingPathDelimiter(NotActiveNotebook.ActivePage.FileView.CurrentPath)));
  end;
end;

procedure TActs.cm_LeftEqualRight(param: string);
begin
  with frmMain do
  begin
    LeftTabs.ActivePage.FileView := nil;
    FrameRight.Clone(LeftTabs.ActivePage);
    LeftTabs.ActivePage.UpdateCaption(GetLastDir(ExcludeTrailingPathDelimiter(LeftTabs.ActivePage.FileView.CurrentPath)));

    // Destroying active view may have caused losing focus. Restore it if needed.
    if SelectedPanel = fpLeft then
      FrameLeft.SetFocus;
  end;
end;

procedure TActs.cm_RightEqualLeft(param: string);
begin
  with frmMain do
  begin
    RightTabs.ActivePage.FileView := nil;
    FrameLeft.Clone(RightTabs.ActivePage);
    RightTabs.ActivePage.UpdateCaption(GetLastDir(ExcludeTrailingPathDelimiter(RightTabs.ActivePage.FileView.CurrentPath)));

    // Destroying active view may have caused losing focus. Restore it if needed.
    if SelectedPanel = fpRight then
      FrameRight.SetFocus;
  end;
end;

procedure TActs.cm_OpenArchive(param:string);
var
  aFile: TFile;
begin
  with frmMain.ActiveFrame do
  begin
    aFile := CloneActiveFile;
    if Assigned(aFile) then
    try
      if aFile.IsNameValid then
      begin
        if aFile.IsDirectory or aFile.IsLinkToDirectory then
          ChangePathToChild(aFile)
        else
          ChooseArchive(frmMain.ActiveFrame, aFile, True);
      end;
    finally
      FreeAndNil(aFile);
    end;
  end;
end;

procedure TActs.cm_TestArchive(param: string);
var
  SelectedFiles: TFiles;
begin
  with frmMain do
  begin
    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      TestArchive(ActiveFrame, SelectedFiles);
    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_Open(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_Open', param);
end;

procedure TActs.cm_OpenVirtualFileSystemList(param:string);
var
  FileSource: IFileSource;
begin
  with frmMain do
  begin
    if (gWFXPlugins.Count = 0) and (gVfsModuleList.Count = 0) then Exit;
    FileSource:= TVfsFileSource.Create(gWFXPlugins);
    if Assigned(FileSource) then
    begin
      if dskLeft.Name = param then
        FrameLeft.AddFileSource(FileSource, FileSource.GetRootDir)
      else if dskRight.Name = param then
        FrameRight.AddFileSource(FileSource, FileSource.GetRootDir)
      else
        ActiveFrame.AddFileSource(FileSource, FileSource.GetRootDir)
    end;
  end;
end;

//------------------------------------------------------
(* Pack files in archive by creating a new archive *)
procedure TActs.cm_PackFiles(param:string);
var
  SelectedFiles: TFiles;
begin
  with frmMain do
  begin
    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      ShowPackDlg(ActiveFrame.FileSource,
                  nil, // No specific target (create new)
                  SelectedFiles,
                  NotActiveFrame.CurrentPath,
                  PathDelim { Copy to root of archive } {NotActiveFrame.FileSource.GetRootString}
                 );

    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

// This command is needed for extracting whole archive by Alt+F9 (without opening it).
procedure TActs.cm_ExtractFiles(param:string);
var
  SelectedFiles: TFiles;
begin
  with frmMain do
  begin
    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    if Assigned(SelectedFiles) then
    try
      if SelectedFiles.Count > 0 then
        ShowExtractDlg(ActiveFrame.FileSource, SelectedFiles,
                       NotActiveFrame.FileSource, NotActiveFrame.CurrentPath)
      else
        msgWarning(rsMsgNoFilesSelected);

    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_QuickSearch(param:string);
begin
  FrmMain.ActiveFrame.ExecuteCommand('cm_QuickSearch', param);
end;

procedure TActs.cm_QuickFilter(param: string='');
begin
  FrmMain.ActiveFrame.ExecuteCommand('cm_QuickFilter', param);
end;

procedure TActs.cm_LeftOpenDrives(param:string);
begin
  frmMain.ShowDrivesList(fpLeft);
end;

procedure TActs.cm_RightOpenDrives(param:string);
begin
  frmMain.ShowDrivesList(fpRight);
end;

procedure TActs.cm_OpenBar(param: string);
var
  sFileName: UTF8String;
  IniFile: TIniFileEx = nil;
begin
  if param = EmptyStr then Exit;
  with frmMain do
  try
    if Pos(PathDelim, param) <> 0 then
      sFileName:= GetCmdDirFromEnvVar(param)
    else
      sFileName:= gpCfgDir + param;
    IniFile:= TIniFileEx.Create(sFileName);
    MainToolBar.AutoSize:= False;
    MainToolBar.LoadFromIniFile(IniFile);
  finally
    MainToolBar.AutoSize:= True;
    FreeThenNil(IniFile);
  end;
end;

procedure TActs.cm_ShowButtonMenu(param:string);
var
  Point: TPoint;
  sFileName: UTF8String;
  IniFile: TIniFileEx = nil;
begin
  if param = EmptyStr then Exit;
  with frmMain do
  try
    if Pos(PathDelim, param) <> 0 then
      sFileName:= GetCmdDirFromEnvVar(param)
    else
      sFileName:= gpCfgDir + param;
    IniFile:= TIniFileEx.Create(sFileName);
    pmButtonMenu.LoadFromIniFile(IniFile);
    Point:=MainToolBar.ClientToScreen(Classes.Point(0,0));
    Point.Y:=Point.Y+MainToolbar.Height;
    Point.X:=mouse.CursorPos.X-60;
    pmButtonMenu.PopUp(Point.x,Point.Y);
  finally
    FreeThenNil(IniFile);
  end;
end;

procedure TActs.cm_TransferLeft(param:string);
begin
  if (frmMain.SelectedPanel = fpRight) then
    DoTransferPath(frmMain.RightTabs.ActivePage,
                   frmMain.LeftTabs.ActivePage);
end;

procedure TActs.cm_TransferRight(param:string);
begin
  if (frmMain.SelectedPanel = fpLeft) then
    DoTransferPath(frmMain.LeftTabs.ActivePage,
                   frmMain.RightTabs.ActivePage);
end;

procedure TActs.cm_GoToFirstFile(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_GoToFirstFile', '');
end;

procedure TActs.cm_GoToLastFile(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_GoToLastFile', '');
end;

procedure TActs.cm_Minimize(param:string);
begin
  FrmMain.MinimizeWindow;
end;

procedure TActs.cm_Wipe(param:string);
var
  theFilesToWipe: TFiles;
  Operation: TFileSourceOperation;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
begin
  with frmMain.ActiveFrame do
  begin
    if not (fsoWipe in FileSource.GetOperationsTypes) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
    end;

    // ------------------------------------------------------

    theFilesToWipe := CloneSelectedFiles; // free at Thread end by thread

    if Assigned(theFilesToWipe) then
    try
      if theFilesToWipe.Count = 0 then
        Exit;

      if not msgYesNo(frmMain.GetFileDlgStr(rsMsgWipeSel, rsMsgWipeFlDr, theFilesToWipe)) then
        Exit;

      Operation := FileSource.CreateWipeOperation(theFilesToWipe);

      if Assigned(Operation) then
      begin
        // Start operation.
        OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);

        ProgressDialog := TfrmFileOp.Create(OperationHandle);
        ProgressDialog.Show;
      end
      else
      begin
        msgWarning(rsMsgNotImplemented);
      end;

    finally
      if Assigned(theFilesToWipe) then
        FreeAndNil(theFilesToWipe);
    end;
  end;
end;

procedure TActs.cm_Exit(param:string);
begin
  frmMain.Close; // application.Terminate not save settings.
end;

procedure TActs.cm_NewTab(param:string);
begin
  DoNewTab(frmMain.ActiveNotebook);
end;

procedure TActs.cm_RenameTab(param: string);
var
  sCaption: UTF8String;
begin
  with frmMain do
  begin
    sCaption:= ActiveNotebook.Page[ActiveNotebook.PageIndex].Caption;
    if (Length(sCaption) > 0)  and (sCaption[1] = '*')  and
       (ActiveNotebook.Page[ActiveNotebook.PageIndex].LockState <> tlsNormal) and
       (tb_show_asterisk_for_locked in gDirTabOptions) then
      UTF8Delete(sCaption, 1, 1);
    if InputQuery(rsMsgTabRenameCaption, rsMsgTabRenamePrompt, sCaption) then
      ActiveNotebook.Page[ActiveNotebook.PageIndex].UpdateCaption(sCaption);
  end;
end;

procedure TActs.cm_RemoveTab(param:string);
begin
  with frmMain do
    DoRemoveTab(ActiveNotebook, ActiveNotebook.PageIndex);
end;

procedure TActs.cm_RemoveAllTabs(param: string);
var
  I: Integer;
  ANotebook: TFileViewNotebook;
begin
  with frmMain do
  begin
    if (tb_confirm_close_all in gDirTabOptions) then
      if not msgYesNo(rsMsgCloseAllInActiveTabs) then Exit;

    if param = 'LeftTabs' then
      ANotebook := LeftTabs
    else if param = 'RightTabs' then
      ANotebook := RightTabs
    else
      ANotebook := ActiveNotebook;

    for I := ANotebook.PageCount - 1 downto 0 do
      if I <> ANotebook.PageIndex then
        case RemovePage(ANotebook, I) of
          1: Continue; // skip tab
          2: Break;    // cancel operation
        end;

    ActiveFrame.SetFocus;
  end;
end;

procedure TActs.cm_NextTab(param: string);
begin
  frmMain.ActiveNotebook.ActivateNextTab;
end;

procedure TActs.cm_PrevTab(param: string);
begin
  frmMain.ActiveNotebook.ActivatePrevTab;
end;

procedure TActs.cm_SetTabOptionNormal(param: string='');
begin
  with frmMain.ActiveNotebook.ActivePage do
    LockState := tlsNormal;
end;

procedure TActs.cm_SetTabOptionPathLocked(param: string='');
begin
  with frmMain.ActiveNotebook.ActivePage do
    LockState := tlsPathLocked;
end;

procedure TActs.cm_SetTabOptionPathResets(param: string='');
begin
  with frmMain.ActiveNotebook.ActivePage do
    LockState := tlsPathResets;
end;

procedure TActs.cm_SetTabOptionDirsInNewTab(param: string='');
begin
  with frmMain.ActiveNotebook.ActivePage do
    LockState := tlsDirsInNewTab;
end;

//------------------------------------------------------

procedure TActs.cm_View(param:string);
var
  sl: TStringList = nil;
  i, n: Integer;
  sViewCmd: String;
  ActiveFile: TFile = nil;
  AllFiles: TFiles = nil;
  SelectedFiles: TFiles = nil;
  TempFiles: TFiles = nil;
  aFile: TFile;
  TempFileSource: ITempFileSystemFileSource = nil;
  Operation: TFileSourceOperation;
  aFileSource: IFileSource;
  UI: TFileSourceOperationMessageBoxesUI = nil;
begin
  with frmMain do
  try
    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    ActiveFile := ActiveFrame.CloneActiveFile;

    // Enter directories using View command.
    if Assigned(ActiveFile) and
       (ActiveFile.IsDirectory or ActiveFile.IsLinkToDirectory) then
    begin
      ActiveFrame.ExecuteCommand('cm_Open');
      Exit;
    end;

    if SelectedFiles.Count = 0 then
    begin
      msgWarning(rsMsgNoFilesSelected);
      Exit;
    end;

    // Default to using the file source directly.
    aFileSource := ActiveFrame.FileSource;

    // If files are links to local files
    if (fspLinksToLocalFiles in ActiveFrame.FileSource.Properties) then
      begin
        for I := 0 to SelectedFiles.Count - 1 do
          begin
            aFile := SelectedFiles[I];
            ActiveFrame.FileSource.GetLocalName(aFile);
          end;
      end
    // If files not directly accessible copy them to temp file source.
    else if not (fspDirectAccess in ActiveFrame.FileSource.Properties) then
    begin
      if not (fsoCopyOut in ActiveFrame.FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

      TempFiles := SelectedFiles.Clone;

      TempFileSource := TTempFileSystemFileSource.GetFileSource;

      Operation := ActiveFrame.FileSource.CreateCopyOutOperation(
                       TempFileSource,
                       TempFiles,
                       TempFileSource.FileSystemRoot);

      if Assigned(Operation) then
      begin
        // Call directly - not through operations manager.
        UI := TFileSourceOperationMessageBoxesUI.Create;
        try
          Operation.AddUserInterface(UI);
          Operation.Execute;
          if Operation.Result = fsorAborted then Exit;
        finally
          FreeAndNil(Operation);
          FreeAndNil(UI);
        end;

        aFileSource := TempFileSource;
        ChangeFileListRoot(TempFileSource.FileSystemRoot, SelectedFiles);
      end
      else
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;
    end;

    sl := TStringList.Create;
    for i := 0 to SelectedFiles.Count - 1 do
    begin
      aFile := SelectedFiles[i];

      if not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
      begin
        if (log_info in gLogOptions) then
          logWrite('View.Add: ' + aFile.FullPath, lmtInfo);

        //now test if exists View command in doublecmd.ext :)
        sViewCmd:= gExts.GetExtActionCmd(aFile, 'view');

        if (sViewCmd<>'') then
          begin
            ReplaceExtCommand(sViewCmd, aFile);
            ProcessExtCommand(sViewCmd, ActiveFrame.CurrentPath);
            // TODO:
            // If TempFileSource is used, create a wait thread that will
            // keep the TempFileSource alive until the command is finished.
          end
        else
          begin
            sl.Add(aFile.FullPath);
          end;
      end; // if selected
    end; // for

    // If only one file was selected then add all files in panel to the list.
    // Works only for directly accessible files and only when using internal viewer.
    if (sl.Count=1) and
       (not gExternalTools[etViewer].Enabled) and
       ([fspDirectAccess, fspLinksToLocalFiles] * ActiveFrame.FileSource.Properties <> []) then
      begin
        AllFiles := ActiveFrame.CloneFiles;

        if (fspLinksToLocalFiles in ActiveFrame.FileSource.Properties) then
          begin
            for I := 0 to AllFiles.Count - 1 do
              begin
                aFile := AllFiles[I];
                ActiveFrame.FileSource.GetLocalName(aFile);
              end;
          end;

        n:=0;
        for i := 0 to AllFiles.Count - 1 do
          begin
            aFile := AllFiles[i];
            if not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
              begin
                if n>0 then sl.Add(aFile.FullPath);
                if aFile.Name = ActiveFile.Name then n:=i;
              end;
          end;

        for i:=0 to n-1 do
          begin
            aFile := AllFiles[i];
            if not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
              sl.Add(aFile.FullPath);
          end;
      end;

    // if sl has files then view it
    if sl.Count > 0 then
      ShowViewerByGlobList(sl, aFileSource);

  finally
    if Assigned(sl) then
      FreeAndNil(sl);
    if Assigned(AllFiles) then
      FreeAndNil(AllFiles);
    if Assigned(SelectedFiles) then
      FreeAndNil(SelectedFiles);
    if Assigned(TempFiles) then
      FreeAndNil(TempFiles);
    if Assigned(ActiveFile) then
      FreeAndNil(ActiveFile);
  end;
end;

procedure TActs.cm_QuickView(param: string);
begin
  with frmMain do
  begin
    if Assigned(QuickViewPanel) then
      begin
        QuickViewClose;
      end
    else if (param <> 'Close') then
      begin
        QuickViewShow(NotActiveNotebook.ActivePage, ActiveFrame);
      end;
  end;
end;

procedure TActs.cm_Edit(param:string);
var
  i: Integer;
  sEditCmd: String;
  aFile: TFile;
  SelectedFiles: TFiles = nil;
begin
  with frmMain do
  try
    // If files are links to local files
    if (fspLinksToLocalFiles in ActiveFrame.FileSource.Properties) then
      begin
        SelectedFiles := ActiveFrame.CloneSelectedFiles;
        for I := 0 to SelectedFiles.Count - 1 do
          begin
            aFile := SelectedFiles[I];
            ActiveFrame.FileSource.GetLocalName(aFile);
          end;
      end
    // If files not directly accessible copy them to temp file source.
    else if not (fspDirectAccess in ActiveFrame.FileSource.Properties) then
      begin
        msgWarning(rsMsgNotImplemented);
        Exit;
      end
    else
      begin
        SelectedFiles := ActiveFrame.CloneSelectedFiles;
      end;

    for i := 0 to SelectedFiles.Count - 1 do
    begin
      aFile := SelectedFiles[i];

      // For now we only process one file.
      if not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
      begin
        //now test if exists View command in doublecmd.ext :)
        sEditCmd:= gExts.GetExtActionCmd(aFile, 'edit');

        if (sEditCmd <> '') then
          begin
            ReplaceExtCommand(sEditCmd, aFile);
            ProcessExtCommand(sEditCmd, aFile.Path);
          end
        else
          begin
            ShowEditorByGlob(aFile.FullPath);
          end;
        Break;
      end;
    end;

  finally
    if Assigned(SelectedFiles) then
      FreeAndNil(SelectedFiles);
  end;
end;

procedure TActs.cm_EditPath(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_EditPath', param);
end;

procedure TActs.cm_Copy(param:string);
begin
  if frmMain.CopyFiles(frmMain.NotActiveFrame.CurrentPath, True) then
    frmMain.ActiveFrame.UnselectAllFiles;
end;

procedure TActs.cm_CopyNoAsk(param: string='');
begin
  if frmMain.CopyFiles(frmMain.NotActiveFrame.CurrentPath, False) then
    frmMain.ActiveFrame.UnselectAllFiles;
end;

procedure TActs.cm_Rename(param:string);
begin
  if frmMain.MoveFiles(frmMain.NotActiveFrame.CurrentPath, True) then
    frmMain.ActiveFrame.UnselectAllFiles;
end;

procedure TActs.cm_RenameNoAsk(param: string='');
begin
  if frmMain.MoveFiles(frmMain.NotActiveFrame.CurrentPath, False) then
    frmMain.ActiveFrame.UnselectAllFiles;
end;

procedure TActs.cm_MakeDir(param:string);
var
  sPath: UTF8String;
  ActiveFile: TFile = nil;
  Operation: TFileSourceOperation = nil;
  UI: TFileSourceOperationMessageBoxesUI = nil;
begin
  with frmMain do
  try
    if not (fsoCreateDirectory in ActiveFrame.FileSource.GetOperationsTypes) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
    end;

    ActiveFile := ActiveFrame.CloneActiveFile;
    if Assigned(ActiveFile) and ActiveFile.IsNameValid then
      sPath := ActiveFile.Name // 21.05.2009 - pass name from cursor to makedir form
    else
      sPath := EmptyStr;

    if not frmMkDir.ShowMkDir(sPath) then Exit;   // show makedir dialog
    if (sPath = EmptyStr) then Exit;

    Operation := ActiveFrame.FileSource.CreateCreateDirectoryOperation(ActiveFrame.CurrentPath, sPath);
    if Assigned(Operation) then
    begin
      // Call directly - not through operations manager.
      UI := TFileSourceOperationMessageBoxesUI.Create;
      Operation.AddUserInterface(UI);
      Operation.Execute;

      sPath := ExtractFileName(ExcludeTrailingPathDelimiter(sPath));
      ActiveFrame.SetActiveFile(sPath);
    end;
  finally
    FreeAndNil(Operation);
    FreeAndNil(UI);
    FreeAndNil(ActiveFile);
  end;
end;

// Parameters:
// "recycle"           - delete to trash can
// "norecycle"         - delete directly
// "recyclesetting"    - if gUseTrash then delete to trash, otherwise delete directly
// "recyclesettingrev" - if gUseTrash then delete directly, otherwise delete to trash
// no parameter        - depends on gUseTrash
procedure TActs.cm_Delete(param:string);
var
  theFilesToDelete: TFiles;
  // 12.05.2009 - if delete to trash, then show another messages
  MsgDelSel, MsgDelFlDr : string;
  Operation: TFileSourceOperation;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
  bRecycle: Boolean = False;
begin
  with frmMain.ActiveFrame do
  begin
    if not (fsoDelete in FileSource.GetOperationsTypes) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
    end;

    if (((gUseTrash = True) and ((param = '') or (param = 'recyclesetting'))) or
        ((gUseTrash = False) and (param = 'recyclesettingrev')) or
        (param = 'recycle')) and
       FileSource.IsClass(TFileSystemFileSource) and
       mbCheckTrash(CurrentPath) then
    begin
      bRecycle := True;
    end;

    // 12.05.2009
    // Showing delete dialog: to trash or to /dev/null :)
    If bRecycle then
     begin
      MsgDelSel := rsMsgDelSelT;
      MsgDelFlDr := rsMsgDelFlDrT;
     end
    else
     begin
      MsgDelSel := rsMsgDelSel;
      MsgDelFlDr := rsMsgDelFlDr;
     end;

    // ------------------------------------------------------

    theFilesToDelete := CloneSelectedFiles; // free at Thread end by thread

    if Assigned(theFilesToDelete) then
    try
      if theFilesToDelete.Count = 0 then
        Exit;

      if not msgYesNo(frmMain.GetFileDlgStr(MsgDelSel, MsgDelFlDr, theFilesToDelete)) then
        Exit;

      Operation := FileSource.CreateDeleteOperation(theFilesToDelete);

      if Assigned(Operation) then
      begin
        // Special case for filesystem - 'recycle' parameter.
        if Operation is TFileSystemDeleteOperation then
          with Operation as TFileSystemDeleteOperation do
          begin
            // 30.04.2009 - передаем параметр корзины в поток.
            Recycle := bRecycle;
          end;

        // Start operation.
        OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);

        ProgressDialog := TfrmFileOp.Create(OperationHandle);
        ProgressDialog.Show;
      end
      else
      begin
        msgWarning(rsMsgNotImplemented);
      end;

    finally
      if Assigned(theFilesToDelete) then
        FreeAndNil(theFilesToDelete);
    end;
  end;
end;

procedure TActs.cm_CheckSumCalc(param:string);
var
  I: Integer;
  bSeparateFile: Boolean;
  HashAlgorithm: THashAlgorithm;
  sFileName: UTF8String;
  SelectedFiles: TFiles;
  Operation: TFileSourceCalcChecksumOperation;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
begin
  // This will work only for filesystem.
  // For other file sources use temp file system when it's done.

  with frmMain do
  begin
    if not (fsoCalcChecksum in ActiveFrame.FileSource.GetOperationsTypes) then
    begin
      msgWarning(rsMsgNotImplemented);
      Exit;
      // Create temp file source.
      // CopyOut ActiveFrame.FileSource to TempFileSource.
      // Do command on TempFileSource and later delete it (or leave cached on disk?)
    end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      if SelectedFiles.Count = 0 then
      begin
        msgWarning(rsMsgNoFilesSelected);
        Exit;
      end;

      bSeparateFile:= False;
      for I := 0 to SelectedFiles.Count - 1 do // find files in selection
        if not SelectedFiles[I].IsDirectory then
          begin
            bSeparateFile:= True;
            Break;
          end;

      if SelectedFiles.Count > 1 then
        sFileName:= ActiveFrame.CurrentPath + MakeFileName(ActiveFrame.CurrentPath, 'checksum')
      else
        sFileName:= ActiveFrame.CurrentPath + SelectedFiles[0].Name;

      if ShowCalcCheckSum(sFileName, bSeparateFile, HashAlgorithm) then
      begin
        Operation := ActiveFrame.FileSource.CreateCalcChecksumOperation(
                       SelectedFiles, ActiveFrame.CurrentPath, sFileName) as TFileSourceCalcChecksumOperation;

        if Assigned(Operation) then
        begin
          Operation.Mode := checksum_calc;
          Operation.OneFile := not bSeparateFile;
          Operation.Algorithm := HashAlgorithm;

          // Start operation.
          OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);

          ProgressDialog := TfrmFileOp.Create(OperationHandle);
          ProgressDialog.Show;
        end
        else
        begin
          msgWarning(rsMsgNotImplemented);
        end;
      end;

    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_CheckSumVerify(param:string);
var
  I: Integer;
  SelectedFiles: TFiles;
  Operation: TFileSourceCalcChecksumOperation;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
begin
  // This will work only for filesystem.
  // For other file sources use temp file system when it's done.

  with frmMain do
  begin
    if not (fsoCalcChecksum in ActiveFrame.FileSource.GetOperationsTypes) then
    begin
      msgWarning(rsMsgNotImplemented);
      Exit;
      // Create temp file source.
      // CopyOut ActiveFrame.FileSource to TempFileSource.
      // Do command on TempFileSource and later delete it (or leave cached on disk?)
    end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      if SelectedFiles.Count = 0 then
      begin
        msgWarning(rsMsgNoFilesSelected);
        Exit;
      end;

      for I := 0 to SelectedFiles.Count - 1 do // find files in selection
        if not FileExtIsHash(SelectedFiles[I].Extension) then
        begin
          msgError(rsMsgSelectOnlyCheckSumFiles);
          Exit;
        end;

      Operation := ActiveFrame.FileSource.CreateCalcChecksumOperation(
                     SelectedFiles, '', '') as TFileSourceCalcChecksumOperation;

      if Assigned(Operation) then
      begin
        Operation.AddStateChangedListener([fsosStopped], @OnCalcChecksumStateChanged);
        Operation.Mode := checksum_verify;

        // Start operation.
        OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);

        ProgressDialog := TfrmFileOp.Create(OperationHandle);
        ProgressDialog.Show;
      end
      else
      begin
        msgWarning(rsMsgNotImplemented);
      end;

    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_FocusCmdLine(param:string);
begin
  if frmMain.edtCommand.Visible then
  begin
    // Show temporarily command line on user request.
    if (not gCmdLine) and (frmMain.IsCommandLineVisible = False) then
    begin
      frmMain.pnlCommand.Show;
    end;

    frmMain.edtCommand.SetFocus;
  end;
end;

procedure TActs.cm_FileAssoc(param:string);
begin
  ShowFileAssocDlg;
end;

procedure TActs.cm_HelpIndex(param: string='');
begin
  ShowHelpOrErrorForKeyword('', '/index.html');
end;

procedure TActs.cm_Keyboard(param: string='');
begin
  ShowHelpOrErrorForKeyword('', '/shortcuts.html');
end;

procedure TActs.cm_VisitHomePage(param: string='');
var
  ErrMsg: String;
begin
  dmHelpMgr.HTMLHelpDatabase.ShowURL('http://doublecmd.sourceforge.net','Double Commander Web Site', ErrMsg);
end;

procedure TActs.cm_About(param:string);
begin
  ShowAboutBox;
end;

procedure TActs.cm_ShowSysFiles(param:string);
begin
  with frmMain do
  begin
    uGlobs.gShowSystemFiles:= not uGlobs.gShowSystemFiles;
    actShowSysFiles.Checked:= uGlobs.gShowSystemFiles;
    //repaint both panels
    FrameLeft.Reload;
    FrameRight.Reload;
  end;
end;

procedure TActs.cm_SwitchIgnoreList(param: string);
begin
  with frmMain do
  begin
    gIgnoreListFileEnabled:= not gIgnoreListFileEnabled;
    actSwitchIgnoreList.Checked:= gIgnoreListFileEnabled;
    //repaint both panels
    FrameLeft.Reload;
    FrameRight.Reload;
  end;
end;

procedure TActs.cm_Options(param:string);
var
  Ind: Integer;
begin
  if Assigned(frmOptions) then
    begin
      if frmOptions.WindowState = wsMinimized then
        frmOptions.WindowState:= wsNormal
      else
        frmOptions.BringToFront;
    end
  else
    begin
      frmOptions := TfrmOptions.Create(Application);
      if TryStrToInt(param, Ind) then
        frmOptions.Tag:= Ind; // else Tag:=0;

      frmOptions.Show;
  end;
end;

procedure TActs.cm_CompareContents(param:string);
var
  FilesToCompare: TStringList = nil;
  DirsToCompare: TStringList = nil;

  procedure AddItem(const aFile: TFile);
  begin
    if not aFile.IsDirectory then
      FilesToCompare.Add(aFile.Path + aFile.Name)
    else
      DirsToCompare.Add(aFile.Path + aFile.Name);
  end;

  procedure RunExtDiffer(CompareList: TStringList);
  var
    i : Integer;
    sCommand: String;
  begin
    with gExternalTools[etDiffer] do
    begin
      sCommand := QuoteStr(ReplaceEnvVars(Path));
      if Parameters <> EmptyStr then
        sCommand := sCommand + ' ' + Parameters;
      for i := 0 to CompareList.Count - 1 do
        sCommand := sCommand + ' ' + QuoteStr(CompareList.Strings[i]);
      ExecCmdFork(sCommand, RunInTerminal, '', KeepTerminalOpen);
    end;
  end;

var
  i : Integer;
  ActiveSelectedFiles: TFiles = nil;
  NotActiveSelectedFiles: TFiles = nil;
begin
  //Maybe this will not be dependant on file view but file source.
  //But will work only for non-virtual file sources.
  //frmMain.ActiveFrame.ExecuteCommand('cm_CompareContents', param);

  with frmMain do
  begin
    // For now work only for filesystem.
    // Later use temporary file system for other file sources.

    try
      FilesToCompare := TStringList.Create;
      DirsToCompare := TStringList.Create;

      if param = 'dir' then
      begin
        DirsToCompare.Add(FrameLeft.CurrentPath);
        DirsToCompare.Add(FrameRight.CurrentPath);
      end
      else
      begin
        // For now work only for filesystem.
        if not (ActiveFrame.FileSource.IsClass(TFileSystemFileSource)) then
        begin
          msgWarning(rsMsgNotImplemented);
          Exit;
        end;

        try
          ActiveSelectedFiles := ActiveFrame.CloneSelectedFiles;

          if ActiveSelectedFiles.Count = 1 then
          begin
            NotActiveSelectedFiles := NotActiveFrame.CloneSelectedFiles;

            if NotActiveSelectedFiles.Count = 1 then
            begin
              // For now work only for filesystem.
              if not (NotActiveFrame.FileSource.IsClass(TFileSystemFileSource)) then
              begin
                msgWarning(rsMsgNotImplemented);
                Exit;
              end;

              { compare single selected files in both panels }

              AddItem(ActiveSelectedFiles[0]);
              AddItem(NotActiveSelectedFiles[0]);
            end
            else
            begin
              // Only one file selected in active panel.
              MsgWarning(rsMsgInvalidSelection);
              Exit;
            end;
          end
          else if ActiveSelectedFiles.Count > 1 then
          begin
            { compare all selected files in active frame }

            for i := 0 to ActiveSelectedFiles.Count - 1 do
              AddItem(ActiveSelectedFiles[i]);
          end;

        finally
          if Assigned(ActiveSelectedFiles) then
            FreeAndNil(ActiveSelectedFiles);
          if Assigned(NotActiveSelectedFiles) then
            FreeAndNil(NotActiveSelectedFiles);
        end;
      end;

      if ((FilesToCompare.Count > 0) and (DirsToCompare.Count > 0))
      or ((FilesToCompare.Count = 1) or (DirsToCompare.Count = 1)) then
      begin
         // Either files or directories must be selected and more than one.
         MsgWarning(rsMsgInvalidSelection)
      end
      else if FilesToCompare.Count > 0 then
      begin
        if gExternalTools[etDiffer].Enabled then
          RunExtDiffer(FilesToCompare)
        else if FilesToCompare.Count = 2 then
          ShowDiffer(FilesToCompare.Strings[0], FilesToCompare.Strings[1])
        else
          MsgWarning(rsMsgTooManyFilesSelected);
      end
      else if DirsToCompare.Count > 0 then
      begin
        if gExternalTools[etDiffer].Enabled then
          RunExtDiffer(DirsToCompare)
        else
          MsgWarning(rsMsgNotImplemented);
      end
      else
        msgWarning(rsMsgNoFilesSelected);

    finally
      if Assigned(FilesToCompare) then
        FreeAndNil(FilesToCompare);
      if Assigned(DirsToCompare) then
        FreeAndNil(DirsToCompare);
    end;
  end;
end;

procedure TActs.cm_ShowMainMenu(param:string);
begin
  DoShowMainMenu(not gMainMenu);
end;

procedure TActs.cm_Refresh(param:string);
begin
  frmMain.ActiveFrame.Reload;
end;

//------------------------------------------------------
  
procedure TActs.cm_MarkInvert(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkInvert', param);
end;

procedure TActs.cm_MarkMarkAll(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkMarkAll', param);
end;

procedure TActs.cm_MarkUnmarkAll(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkUnmarkAll', param);
end;

procedure TActs.cm_MarkPlus(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkPlus', param);
end;

procedure TActs.cm_MarkMinus(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkMinus', param);
end;

procedure TActs.cm_MarkCurrentExtension(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_MarkCurrentExtension', param);
end;

procedure TActs.cm_UnmarkCurrentExtension(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_UnmarkCurrentExtension', param);
end;

procedure TActs.cm_SaveSelection(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_SaveSelection', param);
end;

procedure TActs.cm_RestoreSelection(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_RestoreSelection', param);
end;

procedure TActs.cm_SaveSelectionToFile(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_SaveSelectionToFile', param);
end;

procedure TActs.cm_LoadSelectionFromFile(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_LoadSelectionFromFile', param);
end;

procedure TActs.cm_LoadSelectionFromClip(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_LoadSelectionFromClip', param);
end;

//------------------------------------------------------

procedure TActs.cm_DirHotList(param:string);
var
  p:TPoint;
begin
  frmMain.CreatePopUpHotDir;// TODO: i thing in future this must call on create or change
  p:=frmMain.ActiveFrame.ClientToScreen(Classes.Point(0,0));
  frmMain.pmHotList.Popup(p.X,p.Y);
end;

procedure TActs.cm_Search(param:string);
begin
  ShowFindDlg(frmMain.ActiveFrame.CurrentPath);
end;


//------------------------------------------------------

procedure TActs.cm_SymLink(param:string);
var
  sExistingFile, sLinkToCreate: String;
  SelectedFiles: TFiles;
begin
  with frmMain do
  begin
    // Symlinks work only for file system.
    if not (ActiveFrame.FileSource.IsClass(TFileSystemFileSource)) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
      // Or create a symlink in temp filesystem and CopyIn to target file source.
    end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      if SelectedFiles.Count > 1 then
        msgWarning(rsMsgTooManyFilesSelected)
      else if SelectedFiles.Count = 0 then
        msgWarning(rsMsgNoFilesSelected)
      else
      begin
        sExistingFile := SelectedFiles[0].Path + SelectedFiles[0].Name;

        if param <> '' then
          sLinkToCreate := param
        else
        begin
          if NotActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            sLinkToCreate := NotActiveFrame.CurrentPath
          else
            sLinkToCreate := ActiveFrame.CurrentPath
        end;

        sLinkToCreate := sLinkToCreate + SelectedFiles[0].Name;

        if ShowSymLinkForm(sExistingFile, sLinkToCreate, ActiveFrame.CurrentPath) then
        begin
          ActiveFrame.Reload;
          if NotActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            NotActiveFrame.Reload;
        end;
      end;

    finally
      FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_HardLink(param:string);
var
  sExistingFile, sLinkToCreate: String;
  SelectedFiles: TFiles;
begin
  with frmMain do
  begin
    // Hard links work only for file system.
    if not (ActiveFrame.FileSource.IsClass(TFileSystemFileSource)) then
    begin
      msgWarning(rsMsgErrNotSupported);
      Exit;
    end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      if SelectedFiles.Count > 1 then
        msgWarning(rsMsgTooManyFilesSelected)
      else if SelectedFiles.Count = 0 then
        msgWarning(rsMsgNoFilesSelected)
      else
      begin
        sExistingFile := SelectedFiles[0].Path + SelectedFiles[0].Name;

        if param <> '' then
          sLinkToCreate := param
        else
        begin
          if NotActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            sLinkToCreate := NotActiveFrame.CurrentPath
          else
            sLinkToCreate := ActiveFrame.CurrentPath
        end;

        sLinkToCreate := sLinkToCreate + SelectedFiles[0].Name;

        if ShowHardLinkForm(sExistingFile, sLinkToCreate, ActiveFrame.CurrentPath) then
        begin
          ActiveFrame.Reload;
          if NotActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            NotActiveFrame.Reload;
        end;
      end;

    finally
      FreeAndNil(SelectedFiles);
    end;
  end;
end;

// Uses to change sort direction when columns header is disabled
procedure TActs.cm_ReverseOrder(param:string);
begin
  with frmMain.ActiveFrame do
    Sorting := ReverseSortDirection(Sorting);
end;

procedure TActs.cm_SortByName(param:string);
var
  FileFunctions: TFileFunctions = nil;
begin
  AddSortFunction(FileFunctions, fsfName);
  AddSortFunction(FileFunctions, fsfNameNoExtension);
  DoSortByFunctions(frmMain.ActiveFrame, FileFunctions);
end;

procedure TActs.cm_SortByExt(param:string);
var
  FileFunctions: TFileFunctions = nil;
begin
  AddSortFunction(FileFunctions, fsfExtension);
  DoSortByFunctions(frmMain.ActiveFrame, FileFunctions);
end;

procedure TActs.cm_SortBySize(param:string);
var
  FileFunctions: TFileFunctions = nil;
begin
  AddSortFunction(FileFunctions, fsfSize);
  DoSortByFunctions(frmMain.ActiveFrame, FileFunctions);
end;

procedure TActs.cm_SortByDate(param:string);
var
  FileFunctions: TFileFunctions = nil;
begin
  AddSortFunction(FileFunctions, fsfModificationTime);
  DoSortByFunctions(frmMain.ActiveFrame, FileFunctions);
end;

procedure TActs.cm_SortByAttr(param:string);
var
  FileFunctions: TFileFunctions = nil;
begin
  AddSortFunction(FileFunctions, fsfAttr);
  DoSortByFunctions(frmMain.ActiveFrame, FileFunctions);
end;

procedure TActs.cm_MultiRename(param:string);
var
  aFiles: TFiles;
begin
  with frmMain do
  begin
    if not (fsoSetFileProperty in ActiveFrame.FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

    aFiles:= ActiveFrame.CloneSelectedFiles;
    if Assigned(aFiles) then
      try
        if aFiles.Count > 0 then
          ShowMultiRenameForm(ActiveFrame.FileSource, aFiles)
        else
          msgWarning(rsMsgNoFilesSelected);
      finally
        FreeAndNil(aFiles);
      end;
  end;
end;

//------------------------------------------------------

procedure TActs.cm_CopySamePanel(param:string);
begin
  frmMain.CopyFiles('', True);
end;

procedure TActs.cm_RenameOnly(param:string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_RenameOnly', param);
end;

procedure TActs.cm_EditNew(param:string);
var
  sNewFile: String;
  hFile: System.THandle = 0;
  aFile: TFile;
  Attrs: TFileAttrs;
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_EditNew', param);

  // For now only works for FileSystem.

  with frmMain do
  if ActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
  begin
    aFile := ActiveFrame.CloneActiveFile;
    if Assigned(aFile) then
    try
      if aFile.IsNameValid then
        sNewFile:= aFile.Name
      else
        sNewFile:= rsEditNewFile;
    finally
      FreeAndNil(aFile);
    end;

    if not InputQuery(rsEditNewOpen, rsEditNewFileName, sNewFile) then Exit;

    // If user entered only a filename prepend it with current directory.
    if ExtractFilePath(sNewFile) = '' then
      sNewFile:= ActiveFrame.CurrentPath + sNewFile;

    Attrs := mbFileGetAttr(sNewFile);
    if Attrs = faInvalidAttributes then
    begin
      hFile := mbFileCreate(sNewFile);
      if hFile = feInvalidHandle then
      begin
        MessageDlg(rsMsgErrECreate, mbSysErrorMessage(GetLastOSError), mtWarning, [mbOK], 0);
        Exit;
      end;
      FileClose(hFile);
      ActiveFrame.FileSource.Reload(ExtractFilePath(sNewFile));
    end
    else if FPS_ISDIR(Attrs) then
    begin
      MessageDlg(rsMsgErrECreate, Format(rsMsgErrCreateFileDirectoryExists,
        [ExtractFileName(sNewFile)]), mtWarning, [mbOK], 0);
      Exit;
    end;

    ShowEditorByGlob(sNewFile);
  end
  else
    msgWarning(rsMsgNotImplemented);
end;

// Shows recently visited directories (global).
procedure TActs.cm_DirHistory(param:string);
var
  p:TPoint;
begin
  frmMain.CreatePopUpDirHistory;
  p:=frmMain.ActiveFrame.ClientToScreen(Classes.Point(0,0));
  frmMain.pmDirHistory.Popup(p.X,p.Y);
end;

// Shows browser-like history for active file view.
procedure TActs.cm_ViewHistory(param:string);
begin
  frmMain.ShowFileViewHistory;
end;

procedure TActs.cm_ViewHistoryPrev(param: string='');
begin
  with frmMain do
  begin
    ActiveFrame.GoToPrevHistory;
  end;
end;

procedure TActs.cm_ViewHistoryNext(param: string='');
begin
  with frmMain do
  begin
    ActiveFrame.GoToNextHistory;
  end;
end;

procedure TActs.cm_ShowCmdLineHistory(param:string);
begin
  with frmMain do
  begin
    if IsCommandLineVisible then
    begin
      edtCommand.SetFocus;
      if edtCommand.Items.Count>0 then
        edtCommand.DroppedDown:=True;
    end;
  end;
end;

procedure TActs.cm_RunTerm(param:string);
begin
  if not frmMain.edtCommand.Focused then
    begin
      mbSetCurrentDir(frmMain.ActiveFrame.CurrentPath);
      ExecCmdFork(gRunTerm);
    end;
end;

procedure TActs.cm_CalculateSpace(param:string);
var
  SelectedFiles: TFiles;
  Operation: TFileSourceOperation;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
begin
  with frmMain do
  begin
    if not (fsoCalcStatistics in ActiveFrame.FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    try
      Operation := ActiveFrame.FileSource.CreateCalcStatisticsOperation(SelectedFiles);
      Operation.AddStateChangedListener([fsosStopped], @OnCalcStatisticsStateChanged);
      OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);
      ProgressDialog := TfrmFileOp.Create(OperationHandle);
      ProgressDialog.Show;
    finally
      if Assigned(SelectedFiles) then
        FreeAndNil(SelectedFiles);
    end;
  end;
end;

procedure TActs.cm_CountDirContent(param: string);
begin
  frmMain.ActiveFrame.ExecuteCommand('cm_CountDirContent', param);
end;

procedure TActs.cm_SetFileProperties(param: string);
var
  ActiveFile: TFile = nil;
  SelectedFiles: TFiles = nil;
  aFileProperties: TFileProperties;
  Operation: TFileSourceSetFilePropertyOperation = nil;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
begin
  with frmMain do
  try
    if not (fsoSetFileProperty in ActiveFrame.FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

    SelectedFiles := ActiveFrame.CloneSelectedFiles;
    ActiveFile := ActiveFrame.CloneActiveFile;
    if Assigned(ActiveFile) then
      begin
        FillByte(aFileProperties, SizeOf(aFileProperties), 0);
        if fpAttributes in ActiveFile.SupportedProperties then
          aFileProperties[fpAttributes]:= ActiveFile.Properties[fpAttributes].Clone;
        if fpModificationTime in ActiveFile.SupportedProperties then
          aFileProperties[fpModificationTime]:= ActiveFile.Properties[fpModificationTime].Clone;
        if fpCreationTime in ActiveFile.SupportedProperties then
          aFileProperties[fpCreationTime]:= ActiveFile.Properties[fpCreationTime].Clone;
        if fpLastAccessTime in ActiveFile.SupportedProperties then
          aFileProperties[fpLastAccessTime]:= ActiveFile.Properties[fpLastAccessTime].Clone;

        Operation:= ActiveFrame.FileSource.CreateSetFilePropertyOperation(
                        SelectedFiles,
                        aFileProperties) as TFileSourceSetFilePropertyOperation;

        if Assigned(Operation) then
          begin
            if ShowChangeFilePropertiesDialog(Operation) then
              begin
                OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);
                Operation := nil; // So it doesn't get destroyed below.
                ProgressDialog := TfrmFileOp.Create(OperationHandle);
                ProgressDialog.Show;
              end;
          end;
      end;
  finally
    if Assigned(SelectedFiles) then
      FreeAndNil(SelectedFiles);
    if Assigned(ActiveFile) then
      FreeAndNil(ActiveFile);
    if Assigned(Operation) then
      FreeAndNil(Operation);
  end;
end;

procedure TActs.cm_FileProperties(param:string);
var
  SelectedFiles: TFiles;
  Operation: TFileSourceExecuteOperation;
  aFile: TFile;
begin
  with frmMain do
  begin
    if ActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
      begin
        SelectedFiles := ActiveFrame.CloneSelectedFiles;
        if Assigned(SelectedFiles) then
        try
          if SelectedFiles.Count > 0 then
          try
            ShowFilePropertiesDialog(ActiveFrame.FileSource, SelectedFiles);
            ActiveFrame.Reload;
          except
            on e: EContextMenuException do
              ShowException(e);
          end;
        finally
          FreeAndNil(SelectedFiles);
        end;
      end
    else if (fsoExecute in ActiveFrame.FileSource.GetOperationsTypes) then
      begin
        aFile:= ActiveFrame.CloneActiveFile;
        if Assigned(aFile) then
          try
            Operation:= ActiveFrame.FileSource.CreateExecuteOperation(
                            aFile,
                            ActiveFrame.CurrentPath,
                            'properties') as TFileSourceExecuteOperation;
            if Assigned(Operation) then
              Operation.Execute;
          finally
            FreeThenNil(Operation);
            FreeThenNil(aFile);
          end;
      end;
  end;
end;

procedure TActs.cm_FileLinker(param:string);
var
  I: Integer;
  aSelectedFiles: TFiles = nil;
  aFile: TFile;
begin
  with frmMain, frmMain.ActiveFrame do
  begin
    if not (fsoCombine in FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

    try
      aSelectedFiles := CloneSelectedFiles;

      for I := 0 to aSelectedFiles.Count - 1 do
        begin
          aFile := aSelectedFiles[I];
          if (aFile.IsDirectory or aFile.IsLinkToDirectory) then
          begin
            msgWarning(rsMsgInvalidSelection);
            Exit;
          end;
        end;

      if aSelectedFiles.Count > 1 then
        ShowLinkerFilesForm(FileSource, aSelectedFiles, NotActiveFrame.CurrentPath)
      else
        msgWarning(rsMsgInvalidSelection);
    finally
      FreeThenNil(aSelectedFiles);
    end; // try
  end; // with
end;

procedure TActs.cm_FileSpliter(param:string);
var
  I: Integer;
  aFile: TFile = nil;
begin
  with frmMain, frmMain.ActiveFrame do
  begin
    if not (fsoSplit in FileSource.GetOperationsTypes) then
      begin
        msgWarning(rsMsgErrNotSupported);
        Exit;
      end;

    try
      aFile := CloneActiveFile;
      if (not Assigned(aFile)) or (aFile.IsDirectory or aFile.IsLinkToDirectory) then
        msgWarning(rsMsgInvalidSelection)
      else
        ShowSplitterFileForm(FileSource, aFile, NotActiveFrame.CurrentPath);
    finally
      FreeThenNil(aFile);
    end; // try
  end; // with
end;

procedure TActs.cm_PanelsSplitterPerPos(param: string);
var i:integer;
begin
  with frmMain do
  begin
   if TryStrToInt(param,i) then
     begin
       if not gHorizontalFilePanels then
         pnlLeft.Width:= (pnlNoteBooks.Width-MainSplitter.Width) * i div 100
       else
         pnlLeft.Height:= (pnlNoteBooks.Height-MainSplitter.Height) * i div 100;
     end;
  end;
end;

procedure TActs.cm_EditComment(param: string);
var
  aFile: TFile;
begin
  with frmMain.ActiveFrame do
  begin
    if (fspDirectAccess in FileSource.GetProperties) then
      begin
        aFile:= CloneActiveFile;
        if Assigned(aFile) then
          try
            if aFile.IsNameValid then
              ShowDescrEditDlg(CurrentPath + aFile.Name)
            else
              msgWarning(rsMsgNoFilesSelected);
          finally
            FreeAndNil(aFile);
          end;
      end
    else if (fspLinksToLocalFiles in FileSource.GetProperties) then
      begin
        aFile:= CloneActiveFile;
        if Assigned(aFile) then
          try
            if aFile.IsNameValid then
              begin
                if FileSource.GetLocalName(aFile) then
                  ShowDescrEditDlg(aFile.FullPath)
                else
                  msgWarning(rsMsgErrNotSupported);
              end
            else
              begin
                msgWarning(rsMsgNoFilesSelected);
              end;
          finally
            FreeAndNil(aFile);
          end;
      end
    else
      msgWarning(rsMsgErrNotSupported);
  end;
end;

function SendToClipboard(ClipboardMode: uClipboard.TClipboardOperation):Boolean;
var
  sl: TStringList = nil;
  i : Integer;
  theSelectedFiles: TFiles = nil;
begin
  // Only works for file system.

  Result := False;

  with frmMain.ActiveFrame do
  if FileSource.IsClass(TFileSystemFileSource) then
  begin
    sl := TStringList.Create;
    try
      theSelectedFiles := CloneSelectedFiles;

      for i := 0 to theSelectedFiles.Count - 1 do
        sl.Add(CurrentPath + theSelectedFiles[i].Name);

      case ClipboardMode of
        uClipboard.ClipboardCut:
            Result := uClipboard.CutToClipboard(sl);

        uClipboard.ClipboardCopy:
            Result := uClipboard.CopyToClipboard(sl);
      end;

    finally
      if Assigned(sl) then
        FreeAndNil(sl);
      if Assigned(theSelectedFiles) then
        FreeAndNil(theSelectedFiles);
    end;
  end
  else
    msgWarning(rsMsgErrNotSupported);
end;

procedure TActs.cm_CopyToClipboard(param: string='');
begin
  SendToClipboard(ClipboardCopy);
end;

procedure TActs.cm_CutToClipboard(param: string='');
begin
  SendToClipboard(ClipboardCut);
end;

procedure TActs.cm_PasteFromClipboard(param: string='');
var
  ClipboardOp: TClipboardOperation;
  filenamesList: TStringList;
  Files: TFiles = nil;
  Operation: TFileSourceOperation = nil;
  OperationHandle: TOperationHandle;
  ProgressDialog: TfrmFileOp;
  SourceFileSource: IFileSource = nil;
begin
  with frmMain do
  begin
    if PasteFromClipboard(ClipboardOp, filenamesList) = True then
    try
      // fill file list with files
      Files := TFileSystemFileSource.CreateFilesFromFileList(
          ExtractFilePath(filenamesList[0]), fileNamesList, True);

      if Files.Count > 0 then
      begin
        case ClipboardOp of

          uClipboard.ClipboardCut:
          begin
            SourceFileSource := TFileSystemFileSource.GetFileSource;

            if ActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            begin
              if not (fsoMove in ActiveFrame.FileSource.GetOperationsTypes) then
              begin
                msgWarning(rsMsgErrNotSupported);
                Exit;
              end;

              Operation := SourceFileSource.CreateMoveOperation(
                             Files, ActiveFrame.CurrentPath);
            end
            else
            begin
              if (not (fsoCopyIn in ActiveFrame.FileSource.GetOperationsTypes)) or
                 (not (fsoDelete in SourceFileSource.GetOperationsTypes)) then
              begin
                msgWarning(rsMsgErrNotSupported);
                Exit;
              end;
  {
              // Meta-operation: CopyIn + Delete

              Operation := ActiveFrame.FileSource.CreateCopyInOperation(
                             SourceFileSource, Files,
                             ActiveFrame.CurrentPath);
  }
            end;
          end;

          uClipboard.ClipboardCopy:
          begin
            if not (fsoCopyIn in ActiveFrame.FileSource.GetOperationsTypes) then
            begin
              msgWarning(rsMsgErrNotSupported);
              Exit;
            end;

            SourceFileSource := TFileSystemFileSource.GetFileSource;

            if ActiveFrame.FileSource.IsClass(TFileSystemFileSource) then
            begin
              Operation := SourceFileSource.CreateCopyOutOperation(
                             ActiveFrame.FileSource, Files,
                             ActiveFrame.CurrentPath);
            end
            else
            begin
              Operation := ActiveFrame.FileSource.CreateCopyInOperation(
                             SourceFileSource, Files,
                             ActiveFrame.CurrentPath);
            end;
          end;

          else
            // Invalid clipboard operation.
            Exit;

        end;

        if Assigned(Operation) then
        begin
          if Operation is TFileSystemCopyOperation then
            (Operation as TFileSystemCopyOperation).AutoRenameItSelf:= True;
          OperationHandle := OperationsManager.AddOperation(Operation, ossAutoStart);
          ProgressDialog := TfrmFileOp.Create(OperationHandle);
          ProgressDialog.Show;

          // Files have been moved so clear the clipboard because
          // the files location in the clipboard is invalid now.
          if ClipboardOp = uClipboard.ClipboardCut then
            uClipboard.ClearClipboard;
        end
        else
          msgWarning(rsMsgNotImplemented);
      end;

    finally
      FreeAndNil(fileNamesList);
      if Assigned(Files) then
        FreeAndNil(Files);
    end;
  end;
end;

procedure TActs.cm_ChangeDirToRoot(param: string='');
begin
  with frmMain.ActiveFrame do
  begin
    CurrentPath := FileSource.GetRootDir(CurrentPath);
  end;
end;

procedure TActs.cm_ChangeDirToParent(param: string='');
begin
  frmMain.ActiveFrame.ChangePathToParent(True);
end;

// Parameters:
// Full path to a directory.
procedure TActs.cm_ChangeDir(param: string='');
begin
  FrmMain.ActiveFrame.CurrentPath := ReplaceEnvVars(param);
end;

procedure TActs.cm_ClearLogWindow(param: string);
begin
  frmMain.seLogWindow.Lines.Clear;
end;

procedure TActs.cm_ClearLogFile(param: string);
begin
  mbDeleteFile(gLogFileName);
end;

procedure TActs.cm_NetworkConnect(param: string);
begin
  {
  ShowConnectionManager(frmMain.ActiveFrame);
  }
end;

procedure TActs.cm_NetworkDisconnect(param: string);
begin
  {
  if frmMain.ActiveFrame.FileSource.IsClass(TWfxPluginFileSource) then
  with frmMain.ActiveFrame.FileSource as IWfxPluginFileSource do
  begin
    if param <> EmptyStr then
      WfxModule.WfxNetworkCloseConnection(param);
  end;
  }
end;

procedure TActs.cm_HorizontalFilePanels(param: string='');
begin
  gHorizontalFilePanels := not gHorizontalFilePanels;
  frmMain.actHorizontalFilePanels.Checked := gHorizontalFilePanels;
  frmMain.UpdateWindowView;
end;

procedure TActs.cm_OperationsViewer(param: string='');
begin
  ShowOperationsViewer;
end;

procedure TActs.cm_Int_RunCommandFromBarFile(param: string='');
var
  SR : TSearchRecEx;
  Res, i : Integer;
  sCmd, sParam, sPath : string;
begin
  Res := FindFirstEx(gpCfgDir + '*.bar', faAnyFile, SR);
  while Res = 0 do
  begin
    GetCommandFromBar (gpCfgDir + Sr.Name, param, sCmd, sParam, sPath);
    if sCmd = '' then
      Res := FindNextEx(SR)
    else
      Res := -1;
  end;
  FindCloseEx(SR);
  if sCmd <> '' then
    begin
      sParam:= ReplaceEnvVars(sParam);
      ReplaceExtCommand(sParam, frmMain.FrameLeft, frmMain.FrameRight, frmMain.ActiveFrame);
      if Actions.Execute(sCmd, sParam) = uActs.cf_Error then
          //Result:= True
          //  else
        begin
          sCmd:= mbExpandFileName(sCmd);
          sPath:= ReplaceEnvVars(sPath);
          ReplaceExtCommand(sPath, frmMain.FrameLeft, frmMain.FrameRight, frmMain.ActiveFrame);
          if sPath <> '' then
            mbSetCurrentDir(sPath);
          // Only add a space after command if there are parameters.
          if Length(sParam) > 0 then
            sParam := ' ' + sParam;
          //Result:= ExecCmdFork(Format('"%s"%s', [sCmd, sParam]));
          ExecCmdFork(Format('"%s"%s', [sCmd, sParam]));
        end;
    end;
end;

procedure TActs.GetCommandFromBar (const cFilename, cParam: string; var Com, Par, Pat:string);
var
  i, BtnCount: integer;
  IniFile: TIniFileEx=nil;
begin
  Com :='';
  IniFile:= TIniFileEx.Create(cFilename);
  BtnCount := IniFile.ReadInteger('Buttonbar', 'Buttoncount', 0);
  for i := 1 to BtnCount do
    begin
       if IniFile.ReadString('Buttonbar', 'misk' + IntToStr(i), '') = cParam then
         begin
           Com := IniFile.ReadString('Buttonbar', 'cmd' + IntToStr(i), '');
           Par := IniFile.ReadString('Buttonbar', 'param' + IntToStr(i), '');
           Pat := IniFile.ReadString('Buttonbar', 'path' + IntToStr(i), '');
         end;
    end;
  FreeThenNil(IniFile);
end;

procedure TActs.cm_Viewer_DeleteFile(param: string='');
begin
  if Assigned(frmViewer) then
    frmViewer.btnDeleteFileClick(frmViewer);
end;

procedure TActs.cm_Viewer_NextFile(param: string='');
begin
  if Assigned(frmViewer) then
    frmViewer.miNextClick (frmViewer);
end;

procedure TActs.cm_Viewer_About(param: string='');
begin
  if Assigned(frmViewer) then
    frmViewer.miAbout2Click(frmViewer);
end;

end.

