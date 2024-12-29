unit ShExDriveComboBox;

interface

uses
  Windows, Messages, Classes, Controls, StdCtrls;

type
  TShExDriveComboBox = class(TCustomComboBox)
  private
    FDrive: Char;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure SetDrive(NewDrive: Char);
    function GetDriveName : string;
    procedure ResetItemHeight;
  protected
    icoWidth  : Integer;
    icoHeight : Integer;
    FOnChange: TNotifyEvent;
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure Click; override;
    procedure BuildList; virtual;
    procedure Change; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Text;
    property Drive: Char read FDrive write SetDrive;
    property DriveName : string read GetDriveName;
  published
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDrag;
  end;

procedure Register;


implementation


uses ShellAPI, Graphics, SysUtils;

function GetItemHeight(Font: TFont): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  Result := Metrics.tmHeight;
end;

constructor TShExDriveComboBox.Create(AOwner: TComponent);
//var
//  Temp: ShortString;
begin
  inherited Create(AOwner);
  Style := csOwnerDrawFixed;
//  GetDir(0, Temp);
  FDrive := #0; { make default drive selected }
  icoWidth  := GetSystemMetrics(SM_CXSMICON);
  icoHeight := GetSystemMetrics(SM_CYSMICON);
  ResetItemHeight;
end;

destructor TShExDriveComboBox.Destroy;
begin
  inherited Destroy;
end;

procedure TShExDriveComboBox.BuildList;
var
  DriveNum  : Integer;
  DriveBits : set of 0..25;
  DriveChar : Char;
  DriveName : string;
  info      : TSHFileInfo;
begin
  { fill list }
  Clear;
  Integer(DriveBits) := GetLogicalDrives;
  for DriveNum := 0 to 25 do
  begin
    if not (DriveNum in DriveBits) then Continue;
    DriveChar := Char(DriveNum + Ord('a'));

    SHGetFileInfo(PChar(DriveChar + ':\'), 0, info, sizeof(info),
                  SHGFI_DISPLAYNAME + SHGFI_ICON + SHGFI_SMALLICON);

    DriveName := info.szDisplayName;
    DriveName := UpCase(DriveChar) + DriveName;
    Items.AddObject(DriveName, TObject(info.hIcon));
  end;
end;

procedure TShExDriveComboBox.SetDrive(NewDrive: Char);
var
  Item: Integer;
begin
  NewDrive := UpCase(NewDrive);
  if NewDrive <> FDrive then
  begin
    FDrive := NewDrive;

    { change selected item }
    for Item := 0 to Items.Count - 1 do
    begin
      if (UpCase(Items[Item][1]) = FDrive) then
      begin
        ItemIndex := Item;
        break;
      end;
    end;
    Change;
  end;
end;

procedure TShExDriveComboBox.CreateWnd;
begin
  inherited CreateWnd;
  BuildList;
//  SetDrive (FDrive);
end;

procedure TShExDriveComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  with Canvas do
  begin
    FillRect(Rect);

    DrawIconEx(Handle,
               Rect.Left + 2,
               (Rect.Top + Rect.Bottom - icoHeight) div 2,
               HICON(Items.Objects[Index]),
               icoWidth, icoHeight, 0, 0, DI_NORMAL);

   { uses DrawText instead of TextOut in order to get clipping against
     the combo box button   }
    Rect.Left := Rect.Left + icoWidth + 6;
    DrawText(Canvas.Handle, PChar(Items[Index]) + 1, -1, Rect,
             DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
  end;
end;

procedure TShExDriveComboBox.Click;
begin
  inherited Click;
  if ItemIndex >= 0 then
    Drive := Items[ItemIndex][1];
end;

procedure TShExDriveComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

procedure TShExDriveComboBox.ResetItemHeight;
var
  nuHeight: Integer;
begin
  nuHeight :=  GetItemHeight(Font);
  if nuHeight < (icoHeight) then nuHeight := icoHeight;
  ItemHeight := nuHeight;
end;

procedure TShExDriveComboBox.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure Register;
begin
  RegisterComponents('Hellogramming', [TShExDriveComboBox]);
end;

function TShExDriveComboBox.GetDriveName: string;
begin
  Result := Copy(Items[ItemIndex], 2, MaxInt);
end;

end.
