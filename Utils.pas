unit Utils;

interface

uses Windows;

const
  KB2Bytes = 1024;

function FormatFileSize(Size : Int64) : string;
function FormatFileTimeLong(FTime : TFileTime) : string;

implementation

uses SysUtils;

function FormatFileSize(Size : Int64) : string;
var
  Bytes, KB : Double;
begin
  Bytes := Size; KB := Bytes/KB2Bytes;
  if KB >= 1024 then
    Result := Format('%.2n MB (%.0n bytes)', [KB/1024, Bytes])
  else
    if Bytes > 1024 then
      Result := Format('%.1n KB (%.0n bytes)', [KB, Bytes])
    else
      Result := Format('%.0n bytes', [Bytes]);
end;

{ Formats a file date/time to a string using the long date/time format }
function FormatFileTimeLong(FTime : TFileTime) : string;
var
  LocalFileTime : TFileTime;
  STime : TSystemTime;
  D : TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  FileTimeToLocalFileTime(FTime, LocalFileTime);
  FileTimeToSystemTime(LocalFileTime, STime);
  D := SystemTimeToDateTime(STime);
  DecodeTime(D, Hour, Min, Sec, MSec);
  if (Hour <> 0) or (Min <> 0) or (Sec <> 0) or (MSec <> 0) then
    Result := FormatDateTime('dddd, mmmm d, yyyy hh:mm:ss AM/PM', D)
  else
    Result := FormatDateTime('dddd, mmmm d, yyyy', D);
end;

end.
