unit uQuickshot;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.SHFolder,
  {$WARN UNIT_PLATFORM OFF}
  VCL.FileCtrl,
  {$WARN UNIT_PLATFORM ON}
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.PNGImage, Vcl.Menus, Vcl.WinXCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ToolWin, Winapi.MMSystem, uOptions;

type
  TfQuickshot = class(TForm)
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    NPrtSc: TMenuItem;
    NOption: TMenuItem;
    N1: TMenuItem;
    NExit: TMenuItem;
    N2: TMenuItem;
    NAbout: TMenuItem;
    NHelp: TMenuItem;
    N10: TMenuItem;
    ImageList: TImageList;
    PageControl: TPageControl;
    TabSheetMain: TTabSheet;
    Panel1: TPanel;
    tsAutorun: TToggleSwitch;
    btnOk: TButton;
    btnDefault: TButton;
    TabSheetMore: TTabSheet;
    Panel2: TPanel;
    tsSplash: TToggleSwitch;
    tsSound: TToggleSwitch;
    stMessage: TToggleSwitch;
    Bevel1: TBevel;
    tsIncremen: TToggleSwitch;
    tsOpenDir: TToggleSwitch;
    tsOpenFile: TToggleSwitch;
    Panel3: TPanel;
    txtCatalog: TLabeledEdit;
    btnCatalogChange: TButton;
    txtFileName: TLabeledEdit;
    Bevel2: TBevel;
    Bevel3: TBevel;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    tsButton: TToggleSwitch;
    procedure NExitClick(Sender: TObject);
    procedure NAboutClick(Sender: TObject);
    procedure NHelpClick(Sender: TObject);
    procedure btnCatalogChangeClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tsAutorunClick(Sender: TObject);
    procedure NOptionClick(Sender: TObject);
    procedure NPrtScClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure txtFileNameKeyPress(Sender: TObject; var Key: Char);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Секция частных объявлений }
    procedure WMGetSysCommand(var Msg:TMessage); message WM_SYSCOMMAND;
    procedure WMHotKey(var Msg : TWMHotKey); message WM_HOTKEY;
  protected
    { Cекция защищенных объявлений }
  public
    { Cекция общих объявлений }
    Setting: TREGOptions;
  end;

const
  id_SnapShot = 101;

var
  fQuickshot: TfQuickshot;

implementation

{$R *.dfm}

uses uPrtScreen;

procedure SoundPlay(soundFile: string);
var
  sound: Pointer;
begin
  sound:=Pointer(FindResource(hInstance, PChar(soundFile), RT_RCDATA));
  if sound <> nil then
    begin
      sound:=Pointer(LoadResource(hInstance,HRSRC(sound)));
      if sound <> nil then sound:=LockResource(HGLOBAL(sound));
    end;
  sndPlaySound(sound, SND_MEMORY or SND_NODEFAULT or SND_ASYNC);
end;

function GetSpecialFolderPath(const folder: Integer): string;
{ 1 "[Текущий пользователь]\My Documents"
  2  "All Users\Application Data"
  3  "[User Specific]\Application Data"
  4  "Program Files"
  5  "All Users\Documents" }
const
  SHGFP_TYPE_CURRENT = 0;
var
  path: array [0 .. MAX_PATH] of Char;
begin
  try
    if SUCCEEDED(SHGetFolderPath(0, folder, 0, SHGFP_TYPE_CURRENT, @path[0])) then Result := path
    else Result := ExtractFilePath(ParamStr(0));
  except
    Result := ExtractFilePath(ParamStr(0));
  end;
end;

procedure TfQuickshot.WMGetSysCommand(var Msg: TMessage);
begin
  if (Msg.WParam = SC_MINIMIZE) or (Msg.WParam = SC_CLOSE) then fQuickshot.Hide
  else inherited;
end;

procedure TfQuickshot.WMHotKey(var Msg: TWMHotKey);
begin
  if Msg.HotKey = id_SnapShot then
    if fPrtScreen = nil then fQuickshot.NPrtSc.Click;
end;

procedure TfQuickshot.FormCreate(Sender: TObject);
begin
  RegisterHotKey(fQuickshot.Handle, id_SnapShot, 0, VK_SNAPSHOT);
  PageControl.ActivePage:=TabSheetMain;
  Setting:=TREGOptions.Create;
  if not DirectoryExists(GetSpecialFolderPath(5)+'\Quickshot') then
    CreateDir(GetSpecialFolderPath(5)+'\Quickshot');
  Setting.Add(txtCatalog, 'Text', itString, GetSpecialFolderPath(5)+'\Quickshot');
  Setting.Add(txtFileName, 'Text', itString, 'quickShot');
  Setting.Add(tsAutorun, 'State', itString, tssOn);
  Setting.Add(tsIncremen, 'State', itString, tssOn);
  Setting.Add(tsOpenDir, 'State', itString, tssOff);
  Setting.Add(tsOpenFile, 'State', itString, tssOff);
  Setting.Add(tsSplash, 'State', itString, tssOn);
  Setting.Add(tsSound, 'State', itString, tssOn);
  Setting.Add(stMessage, 'State', itString, tssOn);
  Setting.Add(tsButton, 'State', itString, tssOn);
  Setting.Load;

  TrayIcon.BalloonFlags:=bfInfo;
  TrayIcon.BalloonTimeout:=10;
  TrayIcon.BalloonTitle:= 'Quick Shot - программа запущена';
  TrayIcon.BalloonHint := 'Нажмите PrtSc для того, чтобы сделать скриншот...';
  if stMessage.State = TToggleSwitchState.tssOn then TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.FormDestroy(Sender: TObject);
begin
  UnRegisterHotKey(fQuickshot.Handle, id_SnapShot);
end;

procedure TfQuickshot.FormHide(Sender: TObject);
begin
  Setting.Save;
end;

procedure TfQuickshot.FormShow(Sender: TObject);
begin
  fQuickshot.Left:= Screen.Width - fQuickshot.Width - 60;
  fQuickshot.Top:= Screen.Height - fQuickshot.Height - 60;
end;

procedure TfQuickshot.tsAutorunClick(Sender: TObject);
begin
  if tsAutorun.State = TToggleSwitchState.tssOn then Setting.Autorun(true)
  else Setting.Autorun(false);
end;

procedure TfQuickshot.txtFileNameKeyPress(Sender: TObject; var Key: Char);
begin
  if AnsiChar(key) in ['/','\',':','?','"','<','>','|'] then key:=chr(0);
end;

procedure TfQuickshot.btnCatalogChangeClick(Sender: TObject);
var
  tmp: string;
begin
  tmp := txtCatalog.Text;
  if SelectDirectory('Установка рабочего каталога', '', tmp) then
    begin
      txtCatalog.Text:=tmp;
      TrayIcon.BalloonFlags:=bfInfo;
      TrayIcon.BalloonTimeout:=10;
      TrayIcon.BalloonTitle:= 'Quick Shot - настройки...';
      TrayIcon.BalloonHint := 'Установлен рабочий каталог : ' + #13 + txtCatalog.Text;
    end
  else
    begin
      TrayIcon.BalloonFlags:=bfError;
      TrayIcon.BalloonTimeout:=10;
      TrayIcon.BalloonTitle:= 'Quick Shot - настройки...';
      TrayIcon.BalloonHint := 'Выбор рабочего каталога отменен!';
    end;
  if stMessage.State = TToggleSwitchState.tssOn then TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.btnDefaultClick(Sender: TObject);
begin
  Setting.Default;
  Setting.Save;
  TrayIcon.BalloonFlags:=bfInfo;
  TrayIcon.BalloonTimeout:=10;
  TrayIcon.BalloonTitle:= 'Quick Shot - настройки...';
  TrayIcon.BalloonHint := 'Настройки программы установлены по умолчанию...';
  if stMessage.State = TToggleSwitchState.tssOn then TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.btnOkClick(Sender: TObject);
begin
  if fQuickshot.Showing then fQuickshot.Hide;
  Setting.Save;
  TrayIcon.BalloonFlags:=bfInfo;
  TrayIcon.BalloonTimeout:=10;
  TrayIcon.BalloonTitle:= 'Quick Shot - настройки...';
  TrayIcon.BalloonHint := 'Настройки программы сохранены...';
  if stMessage.State = TToggleSwitchState.tssOn then TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.NPrtScClick(Sender: TObject);
begin
  if fQuickshot.Showing then fQuickshot.Hide;
  TrayIcon.Visible:=not TrayIcon.Visible;
  if not DirectoryExists(txtCatalog.Text) then CreateDir(txtCatalog.Text);
  try
    fPrtScreen:=TfPrtScreen.Create(nil);
    try
      if tsSound.State = TToggleSwitchState.tssOn then soundPlay('prtsc');
      if tsSplash.State = TToggleSwitchState.tssOff then FreeAndNil(fPrtScreen.ImageSplash);
      fPrtScreen.ShowModal;
    finally
      FreeAndNil(fPrtScreen);
    end;
  finally
    if not TrayIcon.Visible then TrayIcon.Visible:=not TrayIcon.Visible;
    TrayIcon.BalloonFlags:=bfInfo;
    TrayIcon.BalloonTimeout:=10;
    TrayIcon.BalloonTitle:= 'Quick Shot - снимок...';
    TrayIcon.BalloonHint := 'Работа со снимком окончена...';
    if stMessage.State = TToggleSwitchState.tssOn then TrayIcon.ShowBalloonHint;
  end;
end;

procedure TfQuickshot.NOptionClick(Sender: TObject);
begin
  if fQuickshot.Showing then fQuickshot.Hide else fQuickshot.Show;
end;

procedure TfQuickshot.NHelpClick(Sender: TObject);
begin
  TrayIcon.BalloonFlags:=bfInfo;
  TrayIcon.BalloonTimeout:=10;
  TrayIcon.BalloonTitle:='Quick Shot - справка...';
  TrayIcon.BalloonHint := '1). Сделать снимок (PrtSc)' + #13 +
                          '2). Сохранить снимок (Ctrl+S);' + #13 +
                          '3). Копировать снимок (Ctrl+C);' + #13 +
                          '6). Выход (Esc).';
  TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.NAboutClick(Sender: TObject);
begin
  TrayIcon.BalloonFlags:=bfInfo;
  TrayIcon.BalloonTimeout:=15;
  TrayIcon.BalloonTitle:='Quick Shot - о программе...';
  TrayIcon.BalloonHint := 'Copyright (c) 2017 by Alex Krapka' + #13 +
                          'E-mail : alex.krapka@inbox.ru' + #13 +
                          'vk.com : alex.krapka';
  TrayIcon.ShowBalloonHint;
end;

procedure TfQuickshot.NExitClick(Sender: TObject);
begin
  Setting.Destroy;
  Application.MainForm.Close;
end;

initialization
{ Инициализация модуля }

finalization
{ Завершение работы модуля }

end.
