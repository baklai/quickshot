{******************************************************************************}
{                                                                              }
{                    Copyright (c) 2010-2017 Alex Krapka                       }
{                                                                              }
{******************************************************************************}
unit uHint;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, System.Classes,
  System.Math, Vcl.Graphics, Vcl.Themes;

type
  THintWindow = class(Vcl.Controls.THintWindow)
  private
  { Cекция частных объявлений }
    FBitmap: TBitmap;
    FRegion: THandle;
    FGradientColorStart: TColor;
    FGradientColorEnd: TColor;
    FBorderColor: TColor;
    FTextColor: TColor;
    procedure FreeRegion;
  protected
  { Cекция защищенных объявлений }
    procedure CreateParams (var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Erase(var Message: TMessage); message WM_ERASEBKGND;
  public
  { Cекция общих объявлений }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateHint(Rect: TRect; const AHint: String); Override;
  published
  { Cекция опубликованных объявлений }
  end;

implementation

{ THintWindow }

procedure DrawGradient(Canvas: TCanvas; Rect: TRect; FromColor, ToColor: TColor);
var
  i,Y:Integer;
  R,G,B:Byte;
begin
  i:=0;
  for Y:=Rect.Top to Rect.Bottom-1 do
    begin
      R:=GetRValue(FromColor)+Ceil(((GetRValue(ToColor)-GetRValue(FromColor))/Rect.Bottom-Rect.Top)*i);
      G:=GetGValue(FromColor)+Ceil(((GetGValue(ToColor)-GetGValue(FromColor))/Rect.Bottom-Rect.Top)*i);
      B:=GetBValue(FromColor)+Ceil(((GetBValue(ToColor)-GetBValue(FromColor))/Rect.Bottom-Rect.Top)*i);
      Canvas.Pen.Color:=RGB(R,G,B);
      Canvas.MoveTo(Rect.Left,Y);
      Canvas.LineTo(Rect.Right,Y);
      Inc(i);
    end;
end;

procedure THintWindow.ActivateHint(Rect: TRect; const AHint: String);
begin
  inherited;
  Caption:=AHint;
  Canvas.Font:=Screen.HintFont;
  FBitmap.Canvas.Font:=Screen.HintFont;
  DrawText(Canvas.Handle,PChar(Caption),Length(Caption),Rect,DT_CALCRECT or DT_NOPREFIX);
  Width:=(Rect.Right-Rect.Left)+16;
  Height:=(Rect.Bottom-Rect.Top)+10;
  FBitmap.Width:=Width;
  FBitmap.Height:=Height;
  Left:=Rect.Left;
  Top:=Rect.Top;
  FreeRegion;
  With Rect do
    FRegion:=CreateRoundRectRgn(1,1,(Rect.Right-Rect.Left)+16,(Rect.Bottom-Rect.Top)+10,3,3);
  If FRegion<>0 then
    SetWindowRgn(Handle,FRegion,True);
  AnimateWindowProc(Handle,300,AW_BLEND);
  SetWindowPos(Handle,HWND_TOPMOST,Left,Top,0,0,SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE);
end;

constructor THintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmap:=TBitmap.Create;
  FBitmap.PixelFormat:=pf24bit;
  FGradientColorStart:=RGB(255,255,255);
  FGradientColorEnd:=RGB(229,229,240);
  FBorderColor:=RGB(118,118,118);
  FTextColor:=clGray;
end;

procedure THintWindow.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $20000;
begin
  inherited;
  Params.Style:=Params.Style-WS_BORDER;
  Params.WindowClass.Style:=Params.WindowClass.style or CS_DROPSHADOW;
end;

destructor THintWindow.Destroy;
begin
  FBitmap.Free;
  FreeRegion;
  inherited;
end;

procedure THintWindow.Erase(var Message: TMessage);
begin
  Message.Result:=0;
end;

procedure THintWindow.FreeRegion;
begin
  if FRegion <> 0 then
    begin
      SetWindowRgn(Handle,0,True);
      DeleteObject(FRegion);
      FRegion:=0;
    end;
end;

procedure THintWindow.Paint;
var
  CaptionRect:TRect;
begin
  inherited;
  DrawGradient(FBitmap.Canvas,GetClientRect,FGradientColorStart,FGradientColorEnd);
  With FBitmap.Canvas do
    begin
      Font.Color:=FTextColor;
      Brush.Style:=bsClear;
      Pen.Color:=FBorderColor;
      RoundRect(1,1,Width-1,Height-1,6,6);
      RoundRect(1,1,Width-1,Height-1,3,3);
    end;
  CaptionRect:=Rect(8,5,Width,Height);
  DrawText(FBitmap.Canvas.Handle,PChar(Caption),Length(Caption),CaptionRect,DT_WORDBREAK or DT_NOPREFIX);
  BitBlt(Canvas.Handle,0,0,Width,Height,FBitmap.Canvas.Handle,0,0,SRCCOPY);
end;

initialization
{ Инициализация модуля }

  HintWindowClass:=THintWindow;

finalization
{ Завершение работы модуля }

end.
