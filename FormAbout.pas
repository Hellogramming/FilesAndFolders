{*************************************************************************}
{  This file is part of Files And Folders.                                }
{  Copyright (c) 1997-2025 Hellogramming                                  }
{  https://www.hellogramming.com/                                         }
{                                                                         }
{  Files And Folders is free software; you can redistribute it and/or     }
{  modify it under the terms of the MIT License.                          }
{*************************************************************************}

unit FormAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TAboutBox = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cmdOK: TButton;
    Label6: TLabel;
    Edit1: TEdit;
    Image2: TImage;
    Label5: TLabel;
    procedure cmdOKClick(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}


procedure TAboutBox.cmdOKClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.Image2Click(Sender: TObject);
begin
  WinExec('start https://www.hellogramming.com/', 0);
end;


end.
