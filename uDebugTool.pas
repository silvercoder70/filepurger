unit uDebugTool;

interface

procedure DebugMessage(AMessage: string);

implementation

uses Windows;

procedure DebugMessage(AMessage: string);
begin
  OutputDebugString(PChar(AMessage));
end;


end.
