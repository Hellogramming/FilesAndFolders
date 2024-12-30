{*************************************************************************}
{  This file is part of Files And Folders.                                }
{  Copyright (c) 1997-2025 Hellogramming                                  }
{  https://www.hellogramming.com/                                         }
{                                                                         }
{  Files And Folders is free software; you can redistribute it and/or     }
{  modify it under the terms of the MIT License.                          }
{*************************************************************************}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Outline, DirOutln, StdCtrls, FileCtrl, ComCtrls, ExtCtrls, ShellAPI,
  CommCtrl, Menus, Calendar, SizeThread, Buttons, ShExDriveComboBox,
  HelpAwareLabel, FieldsList, ImgList;

type
  TConfiguration = record
    ShowIcon    : Boolean;
    CalcDirSize : Boolean;
  end;

type
  TSortBy = (sbName, sbType, sbDate);

type
  TMainForm = class(TForm)
    TFolderTreeImages: TImageList;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuView: TMenuItem;
    mnuHelp: TMenuItem;
    Bevel1: TBevel;
    StatusBar: TStatusBar;
    pageInfo: TPageControl;
    sheetProperties: TTabSheet;
    panProp1: TPanel;
    imgIcon: TImage;
    ediName: TEdit;
    sheetAttributes: TTabSheet;
    sheetDateTime: TTabSheet;
    panAttr: TPanel;
    chkArchive: TCheckBox;
    chkHidden: TCheckBox;
    chkReadOnly: TCheckBox;
    chkSystem: TCheckBox;
    panProp2: TPanel;
    txtType: THelpAwareLabel;
    ediType: TEdit;
    txtSize: THelpAwareLabel;
    ediSize: TEdit;
    txtContains: THelpAwareLabel;
    ediContains: TEdit;
    chkDirectory: TCheckBox;
    ediCreated: TEdit;
    ediModified: TEdit;
    ediAccessed: TEdit;
    cmdCreated: TButton;
    Label1: THelpAwareLabel;
    Label2: THelpAwareLabel;
    Label3: THelpAwareLabel;
    cmdModified: TButton;
    cmdAccessed: TButton;
    cmdApply: TButton;
    txtMSDOSName: THelpAwareLabel;
    ediMSDOSName: TEdit;
    cmdFileExit: TMenuItem;
    cmdViewDriveInfo: TMenuItem;
    N2: TMenuItem;
    cmdViewSort: TMenuItem;
    cmdHelpTopics: TMenuItem;
    N3: TMenuItem;
    cmdHelpAbout: TMenuItem;
    cmdViewSortByName: TMenuItem;
    cmdViewSortByType: TMenuItem;
    cmdViewSortByDate: TMenuItem;
    N4: TMenuItem;
    cmdViewSortAscending: TMenuItem;
    N1: TMenuItem;
    cmdViewAlwaysOnTop: TMenuItem;
    txtActualSize: THelpAwareLabel;
    ediActualSize: TEdit;
    DrivePropList: TFieldsList;
    cmdViewIcons: TMenuItem;
    cmdViewFolderSize: TMenuItem;
    Panel1: TPanel;
    TheTree: TTreeView;
    panLeftTop: TPanel;
    boxDrives: TShExDriveComboBox;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure TheTreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TheTreeGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TheTreeChange(Sender: TObject; Node: TTreeNode);
    procedure cmdCreatedClick(Sender: TObject);
    procedure cmdApplyClick(Sender: TObject);
    procedure chkArchiveClick(Sender: TObject);
    procedure boxDrivesChange(Sender: TObject);
    procedure cmdFileExitClick(Sender: TObject);
    procedure cmdViewDriveInfoClick(Sender: TObject);
    procedure TheTreeCollapsed(Sender: TObject; Node: TTreeNode);
    procedure cmdViewSortAscendingClick(Sender: TObject);
    procedure cmdViewSortByNameClick(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure cmdViewAlwaysOnTopClick(Sender: TObject);
    procedure cmdHelpAboutClick(Sender: TObject);
    procedure cmdHelpTopicsClick(Sender: TObject);
    procedure cmdViewIconsClick(Sender: TObject);
    procedure cmdViewFolderSizeClick(Sender: TObject);
    procedure panLeftTopResize(Sender: TObject);
  protected
    procedure WMUpdateDirSize(var Message: TMessage); message WM_UPDATEDIRSIZE;
  private
    TrueChange      : Boolean; // true file/folder focus change
    CurIsDrive      : Boolean;
    CurDrive        : Char;
    CurFileOrFolder : string;
    AttributeChange : Boolean;
    LastWasDrive    : Boolean;
    FSortBy         : TSortBy;
    CurStoredInSB   : string;

    procedure ShowSizeDisplayControls(fShowSize, fShowContains : Boolean);
    procedure SetSortBy(Value : TSortBy);
    function GetNodePath(Node : TTreeNode) : string;
    procedure ReadDirectory(const Path : string; const Node : TTreeNode);
    procedure GetFileInfo(CalcSize : Boolean);
    procedure GetDriveInfo;
    procedure UpdateFolder;
    procedure ReadDrive;

  public
    Config : TConfiguration;
    FindData : TWin32FindData;
    property SortBy : TSortBy read FSortBy write SetSortBy;
  end;

var
  MainForm: TMainForm;

implementation

uses DateTime, FormAbout, FileInfoUtils;

{$R *.DFM}

var
  SortAscending   : Boolean;

function FormatIntWithComma(N : Integer) : String;
var
  R : Real;
begin
  R := N;
  Result := Format('%.0n', [R]);
end;

{***********************************************************************}
{        Files & Folders Tree Implementation                            }
{***********************************************************************}

procedure TMainForm.ShowSizeDisplayControls(fShowSize, fShowContains : Boolean);
begin
  txtSize.Visible       := fShowSize;
  ediSize.Visible       := fShowSize;
  txtActualSize.Visible := fShowSize;
  ediActualSize.Visible := fShowSize;
  txtContains.Visible   := fShowContains;
  ediContains.Visible   := fShowContains;
end;

function TMainForm.GetNodePath(Node : TTreeNode) : string;
begin
  Result := '';
  while True do
  begin
    Result := Node.Text + '\' + Result;
    if Node.Parent = nil then
    begin
      Result := CurDrive + ':\' + Result;
      Break;
    end;
    Node := Node.Parent;
  end;
  SetLength(Result, Length(Result) - 1);
end;

function SortFunction(Node1, Node2: TTreeNode; ParamSort: integer): integer; stdcall;
const
  ResArray : array[False..True] of Integer = (-1, 1);
begin
  if Boolean(Node1.Data) xor Boolean(Node2.Data) then
  begin
    Result := ResArray[Node1.Data = nil];
    Exit;
  end;

  case TSortBy(ParamSort) of
    sbName :
      Result := lstrcmp(PChar(Node1.Text),  PChar(Node2.Text));
    sbType :
    begin
      Result := lstrcmp(PChar(ExtractFileExt(Node1.Text)),
                PChar(ExtractFileExt(Node2.Text)));
      if Result = 0 then Result := lstrcmp(PChar(Node1.Text),  PChar(Node2.Text));
    end;
    sbDate : Result := Node1.StateIndex - Node2.StateIndex;
  end;
  if SortAscending = False then Result := -Result;
end;

procedure TMainForm.SetSortBy(Value : TSortBy);
begin
  FSortBy := Value;
  try
    TheTree.CustomSort(@SortFunction, Integer(FSortBy));
  finally
    cmdViewSort.Items[Integer(FSortBy)].Checked := True;
  end;
end;

procedure TMainForm.ReadDirectory(const Path : string; const Node : TTreeNode);
var
  SearchRec, ChildSearchRec : TSearchRec;
  Status, ChildStatus : Integer;
  ChildNode : TTreeNode;
begin
  Status := FindFirst(Path + '\*.*', faAnyFile, SearchRec);
  try
    while Status = 0 do
    begin
      if StrLen(SearchRec.FindData.cAlternateFileName) = 0 then
      begin
        StrLower(PChar(SearchRec.Name));
        SearchRec.Name[1] := UpCase(SearchRec.Name[1]);
      end;
      if (SearchRec.Attr and faDirectory = faDirectory) then
      begin  // add folder
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          ChildNode := TheTree.Items.AddChildObject(Node, SearchRec.Name, Pointer(1));
          ChildNode.StateIndex := SearchRec.Time;
          ChildStatus := FindFirst(Path + '\' + SearchRec.Name + '\*.*',
                         faAnyFile, ChildSearchRec);
          try
            while ChildStatus = 0 do
            begin
              if (ChildSearchRec.Name <> '.') and
                 (ChildSearchRec.Name <> '..') then
              begin
                ChildNode.HasChildren := True;
                Break;
              end;
              ChildStatus := FindNext(ChildSearchRec);
            end;
          finally
            FindClose(ChildSearchRec);
          end;
        end;
      end
      else
      begin  // add file
        ChildNode := TheTree.Items.AddChildObject(Node, SearchRec.Name, nil);
        ChildNode.StateIndex := SearchRec.Time;
      end;
      Status := FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
    if Node <> nil then Node.Data := Pointer(2);
  end;
  if Node = nil then TheTree.CustomSort(@SortFunction, Integer(FSortBy))
  else Node.CustomSort(@SortFunction, Integer(FSortBy));
end;

procedure TMainForm.TheTreeExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  if Node.Expanded then Exit;
  Screen.Cursor := crHourglass;
  try
    ReadDirectory(GetNodePath(Node), Node);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.TheTreeGetImageIndex(Sender: TObject; Node: TTreeNode);
const
  DIcons : array[False..True] of Integer = (1, 2);
var
  I : Integer;
begin
  I := Integer(Node.Data);
  if Node.Data = nil then
  begin
    Node.SelectedIndex := 0;
    Node.ImageIndex := 0;
  end
  else
  begin
    Node.SelectedIndex := DIcons[Node.Expanded];
    Node.ImageIndex := Node.SelectedIndex;
  end;
end;

procedure TMainForm.TheTreeChange(Sender: TObject; Node: TTreeNode);
begin
  if TrueChange = False then Exit;
  Screen.Cursor := crHourglass;
  try
    CurFileOrFolder := GetNodePath(Node);
    GetFileInfo(True);
  finally
    Screen.Cursor := crDefault;
  end;
end;

{***********************************************************************}
{        Drive/File/Folder Info Routines                                }
{***********************************************************************}

(*--------------------------------------------------------------------*)
(* Display drive logical information (sector size, total bytes, etc.) *)
(*--------------------------------------------------------------------*)
procedure TMainForm.GetDriveInfo;
const
  DriveTypeStr : array[0..DRIVE_RAMDISK] of string =
  ('Unknown Type', 'Root Not Found', 'removable', 'fixed', 'remote',
   'CD-ROM', 'RAM');
var
  uFlags    : UINT;
  info      : TSHFileInfo;
  SysImgList : Integer;
  lpSectorsPerCluster     : DWORD;	// sectors per cluster
  lpBytesPerSector        : DWORD;	// bytes per sector
  lpNumberOfFreeClusters  : DWORD;	// number of free clusters
  lpTotalNumberOfClusters : DWORD; 	// total number of clusters
begin
  CurIsDrive := True;

  { Get drive logical information }
  GetDiskFreeSpace(PChar(CurDrive + ':\'), lpSectorsPerCluster,
  lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters);
  { Get drive cluster size }
  CurClusterSize := lpSectorsPerCluster*lpBytesPerSector;
  if CurClusterSize = -1 then CurClusterSize := 1;

  { Show drive info panels }
  if LastWasDrive = False then
  begin
    pageInfo.ActivePage        := sheetProperties;
    sheetAttributes.TabVisible := False;
    sheetDateTime.TabVisible   := False;
    panProp2.Visible           := False;
    DrivePropList.Visible      := True;
    LastWasDrive               := True;
  end;

  { Get drive shell information }
  uFlags := SHGFI_DISPLAYNAME;
  if Config.ShowIcon then uFlags := uFlags + SHGFI_SYSICONINDEX;
  SysImgList := SHGetFileInfo(PChar(CurDrive + ':\'), 0, info, sizeof(info), uFlags);
  ediName.Text := info.szDisplayName;

  { Update status bar }
  CurStoredInSB := info.szDisplayName;
  CurStoredInSB := CurStoredInSB + ' (' +
  DriveTypeStr[GetDriveType(PChar(CurDrive + ':\'))] + ')';
  StatusBar.SimpleText := CurStoredInSB;

  { Draw drive associated icon }
  if Config.ShowIcon then
    with imgIcon.Canvas do
    begin
      Brush.Color := clBtnFace;
      FillRect(ClipRect);
      ImageList_Draw(SysImgList, info.iIcon, Handle, 0, 0, ILD_NORMAL);
    end;

  { Display drive logical information }
  with DrivePropList do
  begin
    FieldValues[0] := FormatIntWithComma(lpSectorsPerCluster);
    FieldValues[1] := FormatIntWithComma(lpBytesPerSector);
    FieldValues[2] := FormatIntWithComma(lpBytesPerSector*lpSectorsPerCluster);
    FieldValues[3] := FormatIntWithComma(lpTotalNumberOfClusters);
    FieldValues[4] := FormatIntWithComma(lpNumberOfFreeClusters);
    FieldValues[5] := FormatIntWithComma(lpBytesPerSector * lpSectorsPerCluster * lpTotalNumberOfClusters);
    FieldValues[6] := FormatIntWithComma(lpBytesPerSector * lpSectorsPerCluster * lpNumberOfFreeClusters);
    if ItemIndex < 0 then ItemIndex := 0;
  end;
end;

(*--------------------------------------------------------------------*)
(* Display file/folder information (properties, size, attribs, date   *)
(*--------------------------------------------------------------------*)
procedure TMainForm.GetFileInfo(CalcSize : Boolean);
var
  FileHandle : THandle;
  uFlags     : UINT;
  info       : TSHFileInfo;
  SysImgList : Integer;
begin
  CurIsDrive := False;

  { Disable Apply and Date/Time Change buttons}
  AttributeChange     := False;
  cmdApply.Enabled    := False;
  cmdCreated.Enabled  := False;
  cmdModified.Enabled := False;
  cmdAccessed.Enabled := False;

  { Update status bar}
  CurStoredInSB := CurFileOrFolder;
  StatusBar.SimpleText := CurStoredInSB;

  { Show file info panels }
  if LastWasDrive then
  begin
    sheetAttributes.TabVisible := True;
    sheetDateTime.TabVisible   := True;
    DrivePropList.Visible      := False;
    panProp2.Visible           := True;
    LastWasDrive               := False;
  end;

  { Display file information }

  { Shell information }
  uFlags := SHGFI_TYPENAME + SHGFI_DISPLAYNAME;
  if Config.ShowIcon then uFlags := uFlags + SHGFI_SYSICONINDEX;
  SysImgList := SHGetFileInfo(PChar(CurFileOrFolder), 0, info, sizeof(info), uFlags);
  ediType.Text := info.szTypeName;
  ediName.Text := info.szDisplayName;
  { Show icon }
  if Config.ShowIcon then
    with imgIcon.Canvas do
    begin
      Brush.Color := clBtnFace;
      FillRect(ClipRect);
      ImageList_Draw(SysImgList, info.iIcon, Handle, 0, 0, ILD_NORMAL);
    end;

  FileHandle := FindFirstFile(PChar(CurFileOrFolder), FindData);
  if FileHandle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(FileHandle);
    if StrLen(FindData.cAlternateFileName) > 0 then // MS-DOS name
      ediMSDOSName.Text := FindData.cAlternateFileName
    else
      ediMSDOSName.Text := FindData.cFileName;
    { display attributes }
    chkArchive.Checked   := Boolean(FindData.dwFileAttributes and FILE_ATTRIBUTE_ARCHIVE);
    chkHidden.Checked    := Boolean(FindData.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN);
    chkReadOnly.Checked  := Boolean(FindData.dwFileAttributes and FILE_ATTRIBUTE_READONLY);
    chkSystem.Checked    := Boolean(FindData.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM);
    chkDirectory.Checked := Boolean(FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY);
    { display date/time }
    ediCreated.Text  := FormatFileTimeLong(FindData.ftCreationTime);
    ediModified.Text := FormatFileTimeLong(FindData.ftLastWriteTime);
    ediAccessed.Text := FormatFileTimeLong(FindData.ftLastAccessTime);
  end
  else
  begin
    Application.MessageBox('File/folder not found', nil, MB_ICONHAND);
    Exit;
  end;

  { Enable Date/Time change buttons if file (not folder) }
  if chkDirectory.Checked = False then
  begin
    cmdCreated.Enabled  := True;
    cmdModified.Enabled := True;
    cmdAccessed.Enabled := True;
  end;

  if CalcSize = False then Exit;

  { Kill size thread if active }
  if fDirThreadActive then
  begin
    fKillDirThread := True;
    SetThreadPriority(hDirThread, THREAD_PRIORITY_HIGHEST);
    WaitForSingleObject(hDirThread, INFINITE);
  end;

  { Calculate and display file(s)/folder(s) size }
  if chkDirectory.Checked then
  begin
    if Config.CalcDirSize then
    begin
      ShowSizeDisplayControls(True, True);
      
      ediSize.Text := '';
      ediActualSize.Text := '';
      ediContains.Text := '';

      fKillDirThread := False;
      hDirTreeOwner := Handle;
      curDir := CurFileOrFolder;
      fDirThreadActive := True;
      hDirThread := BeginThread(nil, 0, @DirThreadMain, nil, 0, IDDirThread);
    end
    else ShowSizeDisplayControls(False, False);
  end
  else
  begin
    ShowSizeDisplayControls(True, False);
    ediSize.Text := FormatFileSize(FindData.nFileSizeLow);
    ediActualSize.Text := FormatFileSize(GetActualSize(FindData.nFileSizeLow, CurClusterSize));
  end;
end;

{***********************************************************************}
{        Folder Size Thread related routines                            }
{***********************************************************************}

procedure TMainForm.UpdateFolder;
var
  lpCriticalSection: TRTLCriticalSection;
  R1, R2 : Real;
begin
  InitializeCriticalSection(lpCriticalSection);
  EnterCriticalSection(lpCriticalSection);
  try
    ediSize.Text := FormatFileSize(FolderSize);
    ediActualSize.Text := FormatFileSize(ActualFolderSize);
    R1 := FileNo;
    R2 := FolderNo;
    ediContains.Text := Format('%.0n Files, %.0n Folders', [R1, R2]);
  finally
    LeaveCriticalSection(lpCriticalSection);
    DeleteCriticalSection(lpCriticalSection);
  end;
end;

procedure TMainForm.WMUpdateDirSize(var Message: TMessage);
begin
  UpdateFolder;
end;

{***********************************************************************}
{        File/Folder Attributes related routines                        }
{***********************************************************************}

procedure TMainForm.chkArchiveClick(Sender: TObject);
begin
  if AttributeChange = False then
  begin
    AttributeChange  := True;
    cmdApply.Enabled := True;
  end;
end;

procedure TMainForm.cmdApplyClick(Sender: TObject);
var
  A : DWORD;
begin
  { Changes the attributes of the current selected file/folder }
  A := FindData.dwFileAttributes;
  if chkArchive.Checked then A := A or FILE_ATTRIBUTE_ARCHIVE
  else A := A and (not FILE_ATTRIBUTE_ARCHIVE);
  if chkHidden.Checked then A := A or FILE_ATTRIBUTE_HIDDEN
  else A := A and (not FILE_ATTRIBUTE_HIDDEN);
  if chkReadOnly.Checked then A := A or FILE_ATTRIBUTE_READONLY
  else A := A and (not FILE_ATTRIBUTE_READONLY);
  if chkSystem.Checked then A := A or FILE_ATTRIBUTE_SYSTEM
  else A := A and (not FILE_ATTRIBUTE_SYSTEM);
  if SetFileAttributes(PChar(CurFileOrFolder), A) = FALSE then
    Application.MessageBox('Setting file/folder attributes failed',
    PChar(Application.Title), mb_OK + mb_ICONERROR)
  else
  begin
    AttributeChange := False;
    cmdApply.Enabled := False;
  end;
  GetFileInfo(False);
end;

{***********************************************************************}
{        Date/Time related routines                                     }
{***********************************************************************}

procedure TMainForm.cmdCreatedClick(Sender: TObject);
var
  hFile : THandle;
  Res : Boolean;
  OrigAttr : DWORD;
begin
  case (Sender as TButton).Tag of
    1: FDateTime := FindData.ftCreationTime;
    2: FDateTime := FindData.ftLastWriteTime;
    3: FDateTime := FindData.ftLastAccessTime;
  end;

  with TDateTimeBox.Create(Self) do
  try
    ShowModal; { show Change Date/Time dialog box }
  finally
    Free;
  end;

 if DateTimeChanged then
 begin
  OrigAttr := GetFileAttributes(PChar(CurFileOrFolder)); { save file attributes }
  try
    SetFileAttributes(PChar(CurFileOrFolder), FILE_ATTRIBUTE_NORMAL); { set no attribute }
    { Change file time }
    Res := False;
    hFile := FileOpen(CurFileOrFolder, fmOpenWrite);
    case (Sender as TButton).Tag of
      1: Res := SetFileTime(hFile, @FDateTime, nil, nil);
      2: Res := SetFileTime(hFile, nil, nil, @FDateTime);
      3: Res := SetFileTime(hFile, nil, @FDateTime, nil);
    end;
    FileClose(hFile);
  finally
    SetFileAttributes(PChar(CurFileOrFolder), OrigAttr); { restore original attributes }
    GetFileInfo(False); { re-read file information }
    if Res = False then { display an error message }
      Application.MessageBox('Setting file date/time failed',
      PChar(Application.Title), mb_OK + mb_ICONERROR)
  end;
 end;
end;

{***********************************************************************}
{        Drives Combo Box related routines                              }
{***********************************************************************}

procedure TMainForm.ReadDrive;
var
  NewDrive : Char;
begin
  NewDrive := boxDrives.Drive;
  if NewDrive = #0 then Exit;
  try
    ChDir(NewDrive + ':\');
  except
    on E:EInOutError do
    begin
      Application.MessageBox(PChar(NewDrive + ': is not accessible. The drive door may not be closed or the network connection may be down. Please try to correct this error and retry.'),
      PChar(Application.Title), mb_OK + mb_ICONERROR);
      boxDrives.Drive := CurDrive;
      Exit;
    end;
  end;
  CurDrive := NewDrive;
  Screen.Cursor := crHourglass;
  TheTree.Items.BeginUpdate;
  try
    TrueChange := False;
    TheTree.Items.Clear;
    ReadDirectory(CurDrive + ':', nil);
    GetDriveInfo;
  finally
    TrueChange := True;
    TheTree.Items.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.boxDrivesChange(Sender: TObject);
begin
  ReadDrive;
end;

procedure TMainForm.TheTreeCollapsed(Sender: TObject; Node: TTreeNode);
begin
  Node.DeleteChildren;
  Node.HasChildren := True;
end;

(**********************************************************************)
(*  File menu                                                         *)
(**********************************************************************)

{ Close Application }
procedure TMainForm.cmdFileExitClick(Sender: TObject);
begin
  Close;
end;

(**********************************************************************)
(*  View menu                                                         *)
(**********************************************************************)

{ Refresh }
procedure TMainForm.cmdViewDriveInfoClick(Sender: TObject);
begin
  ReadDrive;
end;

{ Sort By }
procedure TMainForm.cmdViewSortByNameClick(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  try
    SortBy := TSortBy((Sender As TMenuItem).Tag);
  finally
    Screen.Cursor := crDefault;
  end;
end;

{ Ascending or descending sort }
procedure TMainForm.cmdViewSortAscendingClick(Sender: TObject);
const
  MenuEntryNames : array[False..True] of string = ('Descending', 'Ascending');
begin
  Screen.Cursor := crHourglass;
  try
    SortAscending := not SortAscending;
    cmdViewSortAscending.Caption := MenuEntryNames[SortAscending];
    TheTree.CustomSort(@SortFunction, Integer(FSortBy));
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.cmdViewIconsClick(Sender: TObject);
begin
  cmdViewIcons.Checked := not cmdViewIcons.Checked;
  Config.ShowIcon := cmdViewIcons.Checked;
  if Config.ShowIcon then
  begin                     // show icon
    if CurIsDrive then GetDriveInfo
    else GetFileInfo(False)
  end
  else
    with imgIcon.Canvas do  // erase icon
    begin
      Brush.Color := clBtnFace;
      FillRect(ClipRect);
    end;
end;

procedure TMainForm.cmdViewFolderSizeClick(Sender: TObject);
begin
  cmdViewFolderSize.Checked := not cmdViewFolderSize.Checked;
  Config.CalcDirSize := cmdViewFolderSize.Checked;
  if Config.CalcDirSize then
  begin                     // compute folder size
    if CurIsDrive = False then GetFileInfo(True)
  end
  else ShowSizeDisplayControls(False, False);
end;

{ Always On Top }
procedure TMainForm.cmdViewAlwaysOnTopClick(Sender: TObject);
begin
  cmdViewAlwaysOnTop.Checked := not cmdViewAlwaysOnTop.Checked;
  if cmdViewAlwaysOnTop.Checked then
    SetWindowPos(handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE)
  else
    SetWindowPos(handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE);
end;

(**********************************************************************)
(*  Help menu                                                         *)
(**********************************************************************)

{ display Help Topics }
procedure TMainForm.cmdHelpTopicsClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER, 0);
end;

{ show About box }
procedure TMainForm.cmdHelpAboutClick(Sender: TObject);
begin
  with TAboutBox.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

(**********************************************************************)
(*  Form create                                                       *)
(**********************************************************************)

procedure TMainForm.ShowHint(Sender: TObject);
begin
  if Application.Hint = '' then StatusBar.SimpleText := CurStoredInSB
                           else StatusBar.SimpleText := Application.Hint;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  T : TTreeNode;
  SearchRec : TSearchRec;
  Status : Integer;
begin

  with DrivePropList do
  begin
    ValueIdent := 100;
    AddField('Sectors Per Cluster', '(unknown)');
    AddField('Bytes Per Sector', '(unknown)');
    AddField('Bytes Per Cluster', '(unknown)');
    AddField('Total Clusters', '(unknown)');
    AddField('Free Clusters', '(unknown)');
    AddField('Total Bytes', '(unknown)');
    AddField('Free Bytes', '(unknown)');
  end;

  fDirThreadActive := False; // no thread active
  { Set program default configuration }
  with Config do
  begin
    ShowIcon := True;
    CalcDirSize := True;
  end;
  SortAscending := True;
  FSortBy := sbName;

  Application.OnHint := ShowHint;       { hint event-handler }
  Application.HelpFile := ExtractFileDir(ParamStr(0)) + '\FILFOL.HLP'; { help file }

  { Load icon resources }
  try
    TFolderTreeImages.ResourceLoad(rtBitmap, 'UNKNOWNFILE', clBlue);
    TFolderTreeImages.ResourceLoad(rtBitmap, 'CLOSEDFOLDER', clBlue);
    TFolderTreeImages.ResourceLoad(rtBitmap, 'OPENFOLDER', clBlue);
  finally
    boxDrives.Drive := ParamStr(0)[1];
  end;
end;

procedure TMainForm.panLeftTopResize(Sender: TObject);
begin
  boxDrives.Width := panLeftTop.Width;
end;

end.
//  Application.MessageBox(PChar(IntToStr(GetHeapStatus.TotalAllocated)), '', 0);

