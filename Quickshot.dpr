program Quickshot;

{$R *.dres}

uses
  Winapi.Windows,
  Vcl.Forms,
  uQuickshot in 'uQuickshot.pas' {fQuickshot},
  uOptions in 'uOptions.pas',
  uHint in 'uHint.pas',
  uPrtScreen in 'uPrtScreen.pas' {fPrtScreen};

{$R *.res}

procedure AppOnTaskBar(AMainForm: TForm; const AVisible: boolean = false);
var
  AppHandle: HWND;
begin
  AppHandle := AMainForm.Handle;
  ShowWindow(AppHandle, SW_HIDE);
  if AVisible then
    ShowWindow(AppHandle, SW_SHOW)
  else
    SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE)
      and (not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);
end;

begin
  if FindWindow('TfQuickshot',nil) <> 0 then
    begin
      MessageBox(0,PChar('Ёкземпл€р программы уже запущен!'),PChar('Quick Shot - сообщение...'),48);
      SetForegroundWindow(FindWindow('TfQuickshot',nil));
    end
  else
    begin
      Application.Initialize;
      Application.ShowMainForm := false;
      Application.MainFormOnTaskbar := True;
      Application.Title := 'Quick Shot - Ѕыстра€ нарезка экрана';
      Application.CreateForm(TfQuickshot, fQuickshot);
  AppOnTaskBar(fQuickshot);
      Application.Run;
    end;
end.
