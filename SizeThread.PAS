unit SizeThread;

interface

uses
  Windows, Messages;

const
  WM_UPDATEDIRSIZE = WM_USER + 1;

var
  FolderSize, ActualFolderSize, FileNo, FolderNo : Integer;
  CurClusterSize   : Integer;
  fDirThreadActive : Boolean;
  fKillDirThread   : Boolean;
  hDirThread       : THandle;
  IDDirThread      : LongWord;
  hDirTreeOwner    : HWND;
  curDir           : string;
  Tick             : Integer;

function DirThreadMain(Ignored : Pointer) : Integer;

function GetActualSize(LogicalSize, ClusterSize : Integer) : Integer;

implementation

uses SysUtils;

function GetActualSize(LogicalSize, ClusterSize : Integer) : Integer;
const
  Vals : array[False..True] of Integer = (0, 1);
begin
  Result := (LogicalSize div ClusterSize)*ClusterSize;
  Inc(Result, Vals[LogicalSize mod ClusterSize <> 0]*ClusterSize);
end;

procedure DirThreadProcess(const Path : string);
var
  SearchRec : TSearchRec;
  Status : Integer;
  NewTick : Integer;
begin
  NewTick := GetTickCount;
  if NewTick - Tick > 250 then
  begin
    Tick := NewTick;
    PostMessage(hDirTreeOwner, WM_UPDATEDIRSIZE, 0, 0);
  end;
  Status := FindFirst(Path + '\*.*', faAnyFile, SearchRec);
  try
    while Status = 0 do
    begin
      if fKillDirThread then Exit;
      if (SearchRec.Attr and faDirectory = faDirectory) then
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          Inc(FolderNo);
          DirThreadProcess(Path + '\' + SearchRec.Name);
        end;
      end
      else
      begin
        Inc(FolderSize, SearchRec.Size);
        Inc(ActualFolderSize, GetActualSize(SearchRec.Size, CurClusterSize));
        Inc(FileNo);
      end;
      Status := FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
end;

function DirThreadMain(Ignored : Pointer) : Integer;
begin
  FolderSize := 0;
  ActualFolderSize := 0;
  FileNo     := 0;
  FolderNo   := 0;
  Tick       := GetTickCount;
  DirThreadProcess(curDir);
  Result := 0;
  if fKillDirThread = False then PostMessage(hDirTreeOwner, WM_UPDATEDIRSIZE, 0, 0);
  fDirThreadActive := False;
  EndThread(Result);
end;

end.
