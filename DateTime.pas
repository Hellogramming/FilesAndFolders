{*************************************************************************}
{  This file is part of Files And Folders.                                }
{  Copyright (c) 1997-2025 Hellogramming                                  }
{  https://www.hellogramming.com/                                         }
{                                                                         }
{  Files And Folders is free software; you can redistribute it and/or     }
{  modify it under the terms of the MIT License.                          }
{*************************************************************************}

unit DateTime;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Calendar, StdCtrls, ComCtrls, Mask;

var
  FDateTime : TFileTime;
  DateTimeChanged : Boolean;

type
  TDateTimeBox = class(TForm)
    cmdChange: TButton;
    cmdCancel: TButton;
    TheDate: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    ediTime: TEdit;
    cmdNow: TButton;
    procedure cmdChangeClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdNowClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DateTimeBox: TDateTimeBox;

implementation

{$R *.DFM}

procedure TDateTimeBox.cmdChangeClick(Sender: TObject);
var
  STime : TSystemTime;
  LocalFileTime : TFileTime;
  T : TDateTime;
begin
  T := StrToTime(ediTime.Text); { convert time from time field }

  { calc new date/time }
  DateTimeToSystemTime(Int(TheDate.Date) + Frac(T), STime);
  SystemTimeToFileTime(STime, LocalFileTime);
  LocalFileTimeToFileTime(LocalFileTime, FDateTime);

  DateTimeChanged := True;
  Close; { close form }
end;

procedure TDateTimeBox.cmdCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDateTimeBox.FormCreate(Sender: TObject);
var
  LocalFileTime : TFileTime;
  STime : TSystemTime;
  DT : TDateTime;
begin
  DateTimeChanged := False;

  cmdNow.Height := ediTime.Height + 1;

  FileTimeToLocalFileTime(FDateTime, LocalFileTime);
  FileTimeToSystemTime(LocalFileTime, STime);

  DT := SystemTimeToDateTime(STime);
  TheDate.ShowCheckBox := (Int(DT) = 0);
  TheDate.Date := DT;
  ediTime.Text := TimeToStr(Frac(DT));
  if TheDate.Checked = False then
  begin
    TheDate.Date := Now;
    TheDate.Checked := False;
  end;

end;

procedure TDateTimeBox.cmdNowClick(Sender: TObject);
begin
  ediTime.Text := TimeToStr(Now);
end;

end.
