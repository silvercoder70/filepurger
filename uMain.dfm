object FilePurgerService: TFilePurgerService
  DisplayName = 'FilePurgerService'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 600
  Width = 800
  PixelsPerInch = 120
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 230
    Top = 130
  end
end
