program FilesAndFolders;

uses
  Vcl.Forms,
  FormAbout in 'FormAbout.pas' {AboutBox},
  DateTime in 'DateTime.pas' {DateTimeBox},
  SizeThread in 'SizeThread.PAS',
  Main in 'Main.pas' {MainForm},
  fieldslist in 'HellogrammingComponents\fieldslist.pas',
  HelpAwareLabel in 'HellogrammingComponents\HelpAwareLabel.pas',
  ShExDriveComboBox in 'HellogrammingComponents\ShExDriveComboBox.pas',
  FileInfoUtils in 'FileInfoUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDateTimeBox, DateTimeBox);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
