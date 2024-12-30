{*************************************************************************}
{  This file is part of Files And Folders.                                }
{  Copyright (c) 1997-2025 Hellogramming                                  }
{  https://www.hellogramming.com/                                         }
{                                                                         }
{  Files And Folders is free software; you can redistribute it and/or     }
{  modify it under the terms of the MIT License.                          }
{*************************************************************************}

unit HelpAwareLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  THelpAwareLabel = class(TLabel)
  private
    FHelpContext: THelpContext;
  published
    property HelpContext: THelpContext read FHelpContext write FHelpContext default 0;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Hellogramming', [THelpAwareLabel]);
end;

end.
