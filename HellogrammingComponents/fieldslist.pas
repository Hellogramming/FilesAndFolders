unit fieldslist;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFieldsList = class(TCustomListBox)

  private
    FValueIdent : Integer;
    function GetFieldName(Index : Integer) : string;
    procedure SetFieldName(Index : Integer; Value : string);
    function GetFieldValue(Index : Integer) : string;
    procedure SetFieldValue(Index : Integer; Value : string);
    function GetFieldsCount : Integer;

  protected
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;

  public
    procedure AddField(const Name, Value : string);
    procedure RemoveField(Index : Integer);
    procedure RemoveAllFileds;
    procedure UpdateScrollBar;
    property FieldNames[Index : Integer] : string read GetFieldName write SetFieldName;
    property FieldValues[Index : Integer] : string read GetFieldValue write SetFieldValue;
    property FieldsCount : Integer read GetFieldsCount;
    property ValueIdent : Integer read FValueIdent write FValueIdent;

    constructor Create(AOwner: TComponent); override;

  published
    property Align;
    property BorderStyle;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ExtendedSelect;
    property Font;
    property ImeMode;
    property ImeName;
    property IntegralHeight;
    property ItemHeight;
//    property Items;
    property MultiSelect;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
//    property Style;
    property TabOrder;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
//    property OnDrawItem;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

procedure Register;

implementation

function TFieldsList.GetFieldName(Index : Integer) : string;
begin
  if (Index < Items.Count) and (Index >= 0) then
    Result := Copy(Items[Index], 1, Integer(Items.Objects[Index]))
  else
    Result := '';
end;

function TFieldsList.GetFieldValue(Index : Integer) : string;
begin
  if (Index < Items.Count) and (Index >= 0) then
    Result := Copy(Items[Index], Integer(Items.Objects[Index]) + 1, MaxInt)
  else
    Result := '';
end;

procedure TFieldsList.SetFieldName(Index : Integer; Value : string);
begin
  if (Index < Items.Count) and (Index >= 0) then
  begin
    Items[Index] := Value + GetFieldValue(Index);
    Items.Objects[Index] := TObject(Length(Value));
  end;
end;

procedure TFieldsList.SetFieldValue(Index : Integer; Value : string);
begin
  if (Index < Items.Count) and (Index >= 0) then
    Items[Index] := GetFieldName(Index) + ' ' + Value;
end;

function TFieldsList.GetFieldsCount : Integer;
begin
  Result := Items.Count;
end;

procedure TFieldsList.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  PartialRect : TRect;
  OrigBrushColor, OrigFontColor : TColor;
begin
  with Canvas do
  begin
    FillRect(Rect);

    PartialRect := Rect;
    PartialRect.Right := PartialRect.Left + ValueIdent;

    OrigBrushColor := Brush.Color;
    Brush.Color := 0;
    FillRect(PartialRect);

    Dec(PartialRect.Bottom);
    Dec(PartialRect.Right);

    Brush.Color := clBtnFace;
    DrawEdge(Handle, PartialRect, BDR_RAISEDINNER, BF_RECT + BF_MIDDLE);

    PartialRect.Left := PartialRect.Left + 2;
    OrigFontColor := Font.Color;
    Font.Color := clBtnText;
    DrawText(Handle, PChar(GetFieldName(Index)), -1, PartialRect,
             DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    Font.Color := OrigFontColor;

    Brush.Color := OrigBrushColor;
    PartialRect := Rect;
    PartialRect.Left := PartialRect.Left + ValueIdent;

    DrawText(Handle, PChar(GetFieldValue(Index)), -1, PartialRect,
             DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
  end;
end;

procedure TFieldsList.AddField(const Name, Value : string);
begin
  Items.Objects[Items.Add(Concat(Name, ' ', Value))] := TObject(Length(Name));
end;

procedure TFieldsList.RemoveField(Index : Integer);
begin
  Items.Delete(Index);
end;

procedure TFieldsList.RemoveAllFileds;
begin
  Items.Clear;
end;

procedure TFieldsList.UpdateScrollBar;
var
  I : Integer;
  CurWidth, MaxWidth : Integer;
begin
  { calculate horizontal extent and show horizontal scroll-bar if necessary }
  MaxWidth := 0;
  for I := 0 to Items.Count - 1 do
  begin
    CurWidth := Canvas.TextWidth(GetFieldValue(I));
    if CurWidth > MaxWidth then MaxWidth := CurWidth;
  end;
  SendMessage(Handle, LB_SETHORIZONTALEXTENT, MaxWidth + ValueIdent + 2, 0);
end;

constructor TFieldsList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := lbOwnerDrawFixed;
end;

procedure Register;
begin
  RegisterComponents('Hellogramming', [TFieldsList]);
end;

end.
