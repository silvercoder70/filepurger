unit uDeleteFiles;

interface

uses Classes, SysUtils;

procedure DeleteFilesOlderThan(ADirectory: string; ATime: TDateTime);

implementation

uses
  System.IOUtils,
  System.Types,
  WinApi.Windows,
  uDebugTool;

function FileTimeToDateTime(const AFileTime: TFileTime): TDateTime;
var
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;
begin
  // Convert the file time to local file time
  if not FileTimeToLocalFileTime(AFileTime, LocalFileTime) then
    RaiseLastOSError;
  // Convert the local file time to system time
  if not FileTimeToSystemTime(LocalFileTime, SystemTime) then
    RaiseLastOSError;
  // Convert the system time to Delphi's TDateTime
  Result := SystemTimeToDateTime(SystemTime);
end;

procedure DeleteFilesOlderThan(ADirectory: string; ATime: TDateTime);
var
  LFiles: TStringDynArray;
begin
  DebugMessage('begin DeleteFilesOlderThan');
  DebugMessage('  Params: ADirectory=' + ADirectory + ',ATime=' + DateTimeToStr(ATime));

  LFiles := TDirectory.GetFiles(ADirectory, '*',
              TSearchOption.soTopDirectoryOnly,
              function (const Path: string;
                        const SR: TSearchRec): Boolean
              begin
                var dt := FileTimeToDateTime(SR.FindData.ftLastAccessTime);
                Result := dt < ATime;
              end);

  for var LFileName in LFiles do
  begin
    DebugMessage('  deleting file ' + LFileName);
  end;
  DebugMessage('end DeleteFilesOlderThan');
end;


end.
