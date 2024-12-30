{*************************************************************************}
{  This file is part of Files And Folders.                                }
{  Copyright (c) 1997-2025 Hellogramming                                  }
{  https://www.hellogramming.com/                                         }
{                                                                         }
{  Files And Folders is free software; you can redistribute it and/or     }
{  modify it under the terms of the MIT License.                          }
{*************************************************************************}

unit FileInfoUtils;

interface

uses Windows;

const
  KB2Bytes = 1024;
  MB2Bytes = 1024*1024;
  GB2Bytes = 1024*1024*1024;
  
(************ File path/names routines *******************************)

{ Adds a slah separator to the end of a folder/drive name if not already present }
function AddSlashSep(const Path: string): string;
{ Removes the last slash separator }
function GetWithoutSlashSep(const Path: string): string;
{ Extracts file name without extension }
function ExtractFileNameWithoutExt(const FileName : string) : string;
{ Returns the last name in a full pathname }
function ExtractLastName(const Path : string) : string;
{ Return true if file name has wildcards in it }
function HasWildcards(FileName : PChar): Boolean;
function PathIsDrive(const Path : string) : Boolean;
function ExtractFilePathWithoutSlash(const Path : string) : string;

(************ File date/time routines ********************************)

{ Converts a file date/time to a integer and vice versa }
function FileTimeToInt(FTime : TFileTime) : Integer;
function IntToFileTime(ITime : Integer) : TFileTime;
{ Formats a file date/time to a string using the short date/time format }
function FormatFileTimeShort(FTime : TFileTime) : string;
{ Formats a file date/time to a string using the long date/time format }
function FormatFileTimeLong(FTime : TFileTime) : string;

(************ File size routines *************************************)

{ Formats a file size to a string using the Shell format type }
function IntToCommaStr(Size : Integer) : string;
function HugeIntToCommaStr(Size : Comp) : string;

function FormatFileSize(Size : Integer) : string;
function HugeFormatFileSize(Size : Comp) : string;
function FormatFileSizeShort(Size : Integer) : string;
function HugeFormatFileSizeShort(Size : Comp) : string;
function FormatFileSizeInBytes(Size : Integer) : string;
function HugeFormatFileSizeInBytes(Size : Comp) : string;

implementation

uses SysUtils;

(*********************************************************************)
(*  File path/names routines                                         *)
(*********************************************************************)

{ Adds a slah separator to the end of a folder/drive name if not already present }
function AddSlashSep(const Path: string): string;
begin
  Result := Path;
  if (Path <> '') and (Path[Length(Path)] <> '\') then
    Result := Result + '\';
end;

{ Removes the last slash separator }
function GetWithoutSlashSep(const Path: string): string;
begin
  if (Path <> '') and (Path[Length(Path)] = '\') then Result := Copy(Path, 1, Length(Path) - 1)
  else Result := Path;
end;

{ Extracts file name without extension }
function ExtractFileNameWithoutExt(const FileName : string) : string;
var
  CommaP : PChar;
begin
  CommaP := StrRScan(PChar(FileName), '.'); { find final '.' }
  if CommaP <> nil then
       Result := Copy(FileName, 1, CommaP - PChar(FileName))
  else Result := FileName;
end;

{ Returns the last name in a full pathname }
function ExtractLastName(const Path : string) : string;
var
  I : Integer;
begin
  Result := GetWithoutSlashSep(Path);
  I := Length(Result);
  while (I > 0) and not (Result[I] in ['\', ':']) do Dec(I);
  Result := Copy(Result, I + 1, 255);
end;

{ Return true if file name has wildcards in it }
function HasWildcards(FileName : PChar): Boolean;
begin
  HasWildcards := (StrScan(FileName, '*') <> nil) or
    (StrScan(FileName, '?') <> nil);
end;

function PathIsDrive(const Path : string) : Boolean;
var
  S : string;
begin
  S := AddSlashSep(Path);
  Result := (Length(S) = 3) and (S[2] = ':');
end;

function ExtractFilePathWithoutSlash(const Path : string) : string;
begin
  Result := ExtractFilePath(Path);
  if not PathIsDrive(Result) then Result := GetWithoutSlashSep(Result);
end;

(*********************************************************************)
(*  File date/time routines                                          *)
(*********************************************************************)

{ Converts a file date/time to a integer }
function FileTimeToInt(FTime : TFileTime) : Integer;
var
  LocalFileTime : TFileTime;
begin
  FileTimeToLocalFileTime(FTime, LocalFileTime);
  FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi, LongRec(Result).Lo);
end;

function IntToFileTime(ITime : Integer) : TFileTime;
begin
  DosDateTimeToFileTime(LongRec(ITime).Hi, LongRec(ITime).Lo, Result);
end;

{ Formats a file date/time to a string using the short date/time format }
function FormatFileTimeShort(FTime : TFileTime) : string;
var
  LocalFileTime : TFileTime;
  Time : Integer;
begin
  FileTimeToLocalFileTime(FTime, LocalFileTime);
  FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);

  if Time <> 0 then Result := DateTimeToStr(FileDateToDateTime(Time))
  else Result := '(unknown)';
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

(*********************************************************************)
(*  File size routines                                               *)
(*********************************************************************)

function IntToCommaStr(Size : Integer) : String;
var
  Bytes : Double;
begin
  Bytes := Size; Result := Format('%.0n', [Bytes]);
end;

function HugeIntToCommaStr(Size : Comp) : String;
var
  Bytes : Double;
begin
  Bytes := Size; Result := Format('%.0n', [Bytes]);
end;

function FormatFileSize(Size : Integer) : string;
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

function HugeFormatFileSize(Size : Comp) : string;
var
  Bytes, KB, MB : Double;
begin
  Bytes := Size; KB := Bytes/KB2Bytes; MB := Bytes/MB2Bytes;
  if MB >= 1024 then
    Result := Format('%.2n GB (%.0n bytes)', [MB/1024, Bytes])
  else
    if KB >= 1024 then
      Result := Format('%.2n MB (%.0n bytes)', [KB/1024, Bytes])
    else
      if Bytes > 1024 then
        Result := Format('%.1n KB (%.0n bytes)', [KB, Bytes])
      else
        Result := Format('%.0n bytes', [Bytes]);
end;

function FormatFileSizeShort(Size : Integer) : string;
var
  Bytes, KB : Double;
begin
  Bytes := Size; KB := Bytes/1024;
  if KB >= 1024 then
    Result := Format('%.1n MB', [KB/1024])
  else
    if Bytes > 1024 then
      Result := Format('%.0n KB', [KB])
    else
      Result := Format('%.0n bytes', [Bytes]);
end;

function HugeFormatFileSizeShort(Size : Comp) : string;
var
  Bytes, KB, MB : Double;
begin
  Bytes := Size; KB := Bytes/KB2Bytes; MB := Bytes/MB2Bytes;
  if MB >= 1024 then
    Result := Format('%.2n GB', [MB/1024])
  else
    if KB >= 1024 then
      Result := Format('%.1n MB', [KB/1024])
    else
      if Bytes > 1024 then
        Result := Format('%.0n KB', [KB])
      else
        Result := Format('%.0n bytes', [Bytes]);
end;

function FormatFileSizeInBytes(Size : Integer) : string;
begin
  Result := IntToCommaStr(Size) + ' byte';
  if Size <> 1 then Result := Result + 's';
end;

function HugeFormatFileSizeInBytes(Size : Comp) : string;
begin
  Result := HugeIntToCommaStr(Size) + ' byte';
  if Size <> 1 then Result := Result + 's';
end;

end.
