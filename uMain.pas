unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.ExtCtrls,
  System.Types;

type
  TFilePurgerService = class(TService)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    type TDeleteSettings = record
      OlderThanDays: integer;
      Directories: TStringDynArray;
    end;

    procedure LoadSettings(var AConfig: TDeleteSettings);
    procedure LogSettings(const AConfig: TDeleteSettings);
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  FilePurgerService: TFilePurgerService;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  System.IniFiles,
  uDebugTool,
  uDeleteFiles;

procedure AddStringToArray(var Arr: TStringDynArray; const NewStr: string);
begin
  SetLength(Arr, Length(Arr) + 1);
  Arr[High(Arr)] := NewStr;
end;

function IsArrayEmpty(const Arr: TStringDynArray): Boolean;
begin
  Result := Length(Arr) = 0;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  FilePurgerService.Controller(CtrlCode);
end;

function TFilePurgerService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TFilePurgerService.LoadSettings(var AConfig: TDeleteSettings);
const
  DefaultDays = 14;
var
  Settings: TIniFile;
begin
  var ConfigFile := TPath.ChangeExtension(ParamStr(0), '.ini');
  Settings := TIniFile.Create(ConfigFile);
  AConfig.OlderThanDays := Settings.ReadInteger('System', 'Days', DefaultDays);
  SetLength(AConfig.Directories, 0);

  var LCounter := 1;
  var LDone := False;
  while not LDone do
  begin
    var DirKey := 'Dir' + LCounter.ToString;
    var LDir := Settings.ReadString('System', DirKey, EmptyStr);
    if LDir = EmptyStr then
      LDone := True
    else
    begin
      AddStringToArray(AConfig.Directories, LDir);
      Inc(LCounter);
    end;
  end;
  Settings.Free;
end;

procedure TFilePurgerService.LogSettings(const AConfig: TDeleteSettings);
begin
  DebugMessage('begin Configuration');
  DebugMessage('  .OlderThanDays=' + AConfig.OlderThanDays.ToString);
  for var LI := Low(AConfig.Directories) to High(AConfig.Directories) do
    DebugMessage('  .Directory' + LI.ToString + '=' + AConfig.Directories[LI]);
  DebugMessage('end Configuration');
end;

procedure TFilePurgerService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Timer1.Enabled := true;
  Started := True;
  LogMessage('File Purger service started', EVENTLOG_INFORMATION_TYPE);
end;

procedure TFilePurgerService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Stopped := True;
  LogMessage('File Purger service stopped', EVENTLOG_INFORMATION_TYPE);
end;

procedure TFilePurgerService.Timer1Timer(Sender: TObject);
var
  Config: TDeleteSettings;
begin
  Timer1.Enabled := false;

  DebugMessage('begin TFilePurgerService.Timer1Timer');
  try
    LoadSettings(Config);
    LogSettings(Config);
    if (Config.OlderThanDays > 0) and
      (not IsArrayEmpty(Config.Directories)) then
    begin
      var LDelOlderThan := Now - Config.OlderThanDays;
      for var LDir in Config.Directories do
        DeleteFilesOlderThan(LDir, LDelOlderThan);

    end;
    Timer1.Interval := 60 * 1000 * 15; {15 minutes}
  except
    on e: exception do
      LogMessage('ManageDownloads::Exception=' + e.message);
  end;
  DebugMessage('end TFilePurgerService.Timer1Timer');

  //Timer1.Enabled := True;
end;

end.
