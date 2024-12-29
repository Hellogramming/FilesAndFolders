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
