unit uPrtScreen;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ClipBrd, Vcl.Imaging.PNGImage,
  System.ImageList, Vcl.ImgList, Vcl.CategoryButtons, Vcl.WinXCtrls, Vcl.Buttons,
  Vcl.ButtonGroup, Vcl.StdCtrls, Vcl.Printers, System.Math, Vcl.ComCtrls,
  Vcl.ToolWin;

const
  bland_color: integer = clBlack;
  bland_persent: byte = 50;

type
  TfPrtScreen = class(TForm)
    Shape: TShape;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    ImageSplash: TImage;
    ImgFileHot: TImageList;
    ImgFile: TImageList;
    ImgFileDisable: TImageList;
    ImgEdit: TImageList;
    ImgEditHot: TImageList;
    ImgEditDisable: TImageList;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    PrintDialog: TPrintDialog;
    ImgGoogle: TImage;
    ImgHorizontal: TImage;
    ImgPrint: TImage;
    ImgCopy: TImage;
    ImgSave: TImage;
    ImgEsc: TImage;
    ImgVertical: TImage;
    ImgPen: TImage;
    ImgLine: TImage;
    ImgArrow: TImage;
    ImgRectangle: TImage;
    ImgMarker: TImage;
    ImgText: TImage;
    ImgColor: TImage;
    ImgCancel: TImage;
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ImageSplashClick(Sender: TObject);
    procedure ShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PointShapeMouseEnter(Sender: TObject);
    procedure PointShapeMouseLeave(Sender: TObject);
    procedure ImgFileMouseEnter(Sender: TObject);
    procedure ImgFileMouseLeave(Sender: TObject);
    procedure ImgFileMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImgFileMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImgEditMouseEnter(Sender: TObject);
    procedure ImgEditMouseLeave(Sender: TObject);
    procedure ImgEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImgEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImgEscClick(Sender: TObject);
    procedure ImgSaveClick(Sender: TObject);
    procedure ImgCopyClick(Sender: TObject);
    procedure ImgPrintClick(Sender: TObject);
    procedure ImgGoogleClick(Sender: TObject);
  private
    { Private declarations }
    Picture: TPicture;
    procedure PointShapeMove();
    procedure ImgPosition();
    procedure ImgVisible(key: boolean);
  public
    { Public declarations }
    ShapeMove: boolean;
    ShapeFull: boolean;
    X0, Y0: smallint;
    Xs,Ys,Ws,Hs: smallint;
  end;

var
  fPrtScreen: TfPrtScreen;

implementation

{$R *.dfm}

uses uQuickshot;

procedure PtrScToClipboard();
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Width := Screen.Width;
    Bmp.Height := Screen.Height;
    BitBlt(Bmp.Canvas.Handle, 0, 0, Screen.Width, Screen.Height, GetDC(GetDesktopWindow), 0, 0, SRCCopy);
    Clipboard.Assign(Bmp);
  finally
    FreeAndNil(Bmp);
  end;
end;

procedure BlendRectangle(Canvas: TCanvas; R: TRect; C: TColor; MixPercent: Byte);
var
  Bmp: TBitmap;
  Blend: _BLENDFUNCTION;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=1;
    Bmp.Height:=1;
    Bmp.Canvas.Pixels[0,0]:=C;
    Blend.BlendOp:=AC_SRC_OVER;
    Blend.BlendFlags:=0;
    Blend.SourceConstantAlpha:=(50+255*MixPercent) Div 100;
    Blend.AlphaFormat:=0;
    AlphaBlend(Canvas.Handle,R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top,Bmp.Canvas.Handle,0,0,1,1,Blend);
  finally
    FreeAndNil(Bmp);
  end;
end;

{$REGION ' Кнопки-действия '}

procedure TfPrtScreen.ImgEscClick(Sender: TObject);
begin
  Clipboard.Clear;
  fPrtScreen.Close;
end;

procedure TfPrtScreen.ImgSaveClick(Sender: TObject);
var
  count: byte;
  Bmp: TBitmap;
  Png: TPNGImage;
  Stream: TmemoryStream;
begin
  if (Shape.Width = 0) or (Shape.Height = 0) then
    begin
      Shape.Left := 0;
      Shape.Top := 0;
      Shape.Width := Picture.Width;
      Shape.Height := Picture.Height;
    end;
  Bmp := TBitmap.Create;
  Png := TPNGImage.Create;
  Stream := TmemoryStream.Create;
  try
    Bmp.Width := ROUND(((Shape.Left - fPrtScreen.Left) + Shape.Width) *
                (Picture.Width / fPrtScreen.Width) - (Shape.Left - fPrtScreen.Left));
    Bmp.Height := ROUND(((Shape.Top * (Picture.Height / fPrtScreen.Height)) +
                  Shape.Height * (Picture.Height / fPrtScreen.Height)) -
                 (Shape.Top * (Picture.Height / fPrtScreen.Height)));
    Bmp.Canvas.Draw(ROUND(-(Shape.Left - fPrtScreen.Left)),
                    ROUND(-(Shape.Top * (Picture.Height / fPrtScreen.Height))),Picture.Graphic);
    count := 1;
    if fQuickshot.tsIncremen.State = TToggleSwitchState.tssOn then
      while FileExists(IncludeTrailingPathDelimiter(fQuickshot.txtCatalog.Text) +
                       fQuickshot.txtFileName.Text + '_' + IntToStr(count) + '.png') do Inc(count);
    Png.Assign(Bmp);
    Png.SaveToStream(Stream);
    Stream.SaveToFile(IncludeTrailingPathDelimiter(fQuickshot.txtCatalog.Text) +
    fQuickshot.txtFileName.Text + '_' + IntToStr(count) + '.png');
  finally
    Stream.Destroy;
    FreeAndNil(Png);
    FreeAndNil(Bmp);
  end;
  fQuickshot.TrayIcon.BalloonFlags:=bfInfo;
  fQuickshot.TrayIcon.BalloonTimeout:=10;
  fQuickshot.TrayIcon.BalloonTitle:= 'Quick Shot - снимок...';
  fQuickshot.TrayIcon.BalloonHint := 'Снимок успешно сохранен в файл '+fQuickshot.txtFileName.Text + '_' + IntToStr(count) + '.png';

  if fQuickshot.tsOpenDir.State = TToggleSwitchState.tssOn then
    ShellExecute(Handle, 'open', PChar(fQuickshot.txtCatalog.Text), nil, nil, SW_SHOWNORMAL);
  if fQuickshot.tsOpenFile.State = TToggleSwitchState.tssOn then
    ShellExecute(Handle, 'open', PChar(IncludeTrailingPathDelimiter(fQuickshot.txtCatalog.Text) + fQuickshot.txtFileName.Text + '_' + IntToStr(count) + '.png'), nil, nil, SW_SHOWNORMAL);
  Clipboard.Clear;
  Close;
  if fQuickshot.stMessage.State = TToggleSwitchState.tssOn then fQuickshot.TrayIcon.ShowBalloonHint;
end;

procedure TfPrtScreen.ImgCopyClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if (Shape.Width = 0) or (Shape.Height = 0) then
    begin
      Shape.Left := 0;
      Shape.Top := 0;
      Shape.Width := Picture.Width;
      Shape.Height := Picture.Height;
    end;
  Bmp := TBitmap.Create;
  try
    Bmp.Width := ROUND(((Shape.Left - fPrtScreen.Left) + Shape.Width) *
                (Picture.Width / fPrtScreen.Width) - (Shape.Left - fPrtScreen.Left));
    Bmp.Height := ROUND(((Shape.Top * (Picture.Height / fPrtScreen.Height)) +
                  Shape.Height * (Picture.Height / fPrtScreen.Height)) -
                 (Shape.Top * (Picture.Height / fPrtScreen.Height)));
    Bmp.Canvas.Draw(ROUND(-(Shape.Left - fPrtScreen.Left)),
                    ROUND(-(Shape.Top * (Picture.Height / fPrtScreen.Height))), Picture.Graphic);
    Clipboard.Assign(Bmp);
  finally
    FreeAndNil(Bmp);
  end;
  fQuickshot.TrayIcon.BalloonFlags:=bfInfo;
  fQuickshot.TrayIcon.BalloonTimeout:=10;
  fQuickshot.TrayIcon.BalloonTitle:= 'Quick Shot - снимок...';
  fQuickshot.TrayIcon.BalloonHint := 'Снимок успешно сохранен в буфер обмена ';
  Close;
  if fQuickshot.stMessage.State = TToggleSwitchState.tssOn then fQuickshot.TrayIcon.ShowBalloonHint;
end;

procedure TfPrtScreen.ImgPrintClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if (Shape.Width = 0) or (Shape.Height = 0) then
    begin
      Shape.Left := 0;
      Shape.Top := 0;
      Shape.Width := Picture.Width;
      Shape.Height := Picture.Height;
    end;
  Bmp := TBitmap.Create;
  try
    Bmp.Width := ROUND(((Shape.Left - fPrtScreen.Left) + Shape.Width) *
                (Picture.Width / fPrtScreen.Width) - (Shape.Left - fPrtScreen.Left));
    Bmp.Height := ROUND(((Shape.Top * (Picture.Height / fPrtScreen.Height)) +
                  Shape.Height * (Picture.Height / fPrtScreen.Height)) -
                 (Shape.Top * (Picture.Height / fPrtScreen.Height)));
    Bmp.Canvas.Draw(ROUND(-(Shape.Left - fPrtScreen.Left)),
        ROUND(-(Shape.Top * (Picture.Height / fPrtScreen.Height))),Picture.Graphic);
    fPrtScreen.Hide;
    printer.BeginDoc;
    Printer.Title:='Quickshot';
    Printer.Canvas.StretchDraw(Rect(10*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height),
                                    10*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height),
                                    Bmp.Width*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height)-
                                    5*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height),
                                    Bmp.Height*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height)-
                                    5*Min(Printer.PageWidth div Bmp.Width,Printer.PageHeight div Bmp.Height)),Bmp);
    printer.EndDoc;
  finally
    FreeAndNil(Bmp);
  end;
  fQuickshot.TrayIcon.BalloonFlags:=bfInfo;
  fQuickshot.TrayIcon.BalloonTimeout:=10;
  fQuickshot.TrayIcon.BalloonTitle:= 'Quick Shot - снимок...';
  fQuickshot.TrayIcon.BalloonHint := 'Снимок успешно отправлен на печать...';
  Close;
  if fQuickshot.stMessage.State = TToggleSwitchState.tssOn then fQuickshot.TrayIcon.ShowBalloonHint;
end;

procedure TfPrtScreen.ImgGoogleClick(Sender: TObject);
begin
   //
end;

{$ENDREGION}

{$REGION ' Кнопки-картинки '}

procedure TfPrtScreen.ImgVisible(key: boolean);
var
  i: smallint;
begin
  for i:=0 to ComponentCount-1 do
    if (Components[i] is TImage) then
      if (Components[i] as TImage).Name <> 'ImageSplash' then
        (Components[i] as TImage).Visible:=key;
end;

procedure TfPrtScreen.ImgPosition();
begin
  if (Shape.Width = fPrtScreen.Width) and (Shape.Height = fPrtScreen.Height) then
    begin
      ImgHorizontal.Left:=abs(Shape.Left+(Shape.Width-ImgHorizontal.Width))-5;
      ImgHorizontal.Top:=Shape.Top+Shape.Height-ImgHorizontal.Height-5;
      ImgVertical.Left:=Shape.Left+Shape.Width-ImgVertical.Width-5;
      ImgVertical.Top:=abs(Shape.Top+(Shape.Height-ImgVertical.Height))-ImgHorizontal.Height-15;
    end
  else
    if ((Shape.Left+Shape.Width+10) < fPrtScreen.Width) and
       ((Shape.Top+Shape.Height+10) < fPrtScreen.Height)  then
      begin
        ImgHorizontal.Left:=abs(Shape.Left+(Shape.Width-ImgHorizontal.Width));
        ImgHorizontal.Top:=Shape.Top+Shape.Height+5;
        ImgVertical.Left:=Shape.Left+Shape.Width+5;
        ImgVertical.Top:=abs(Shape.Top+(Shape.Height-ImgVertical.Height));
      end
    else
      begin
        ImgHorizontal.Left:=abs(Shape.Left+(Shape.Width-ImgHorizontal.Width))-5;
        ImgHorizontal.Top:=Shape.Top+Shape.Height-ImgHorizontal.Height-5;
        ImgVertical.Left:=Shape.Left+Shape.Width-ImgVertical.Width-5;
        ImgVertical.Top:=abs(Shape.Top+(Shape.Height-ImgVertical.Height))-ImgHorizontal.Height-15;
      end;
  ImgGoogle.Top:=ImgHorizontal.Top+4;
  ImgGoogle.Left:=ImgHorizontal.Left+8;
  ImgPrint.Top:=ImgHorizontal.Top+4;
  ImgPrint.Left:=ImgGoogle.Left+ImgGoogle.Width+6;
  ImgCopy.Top:=ImgHorizontal.Top+4;
  ImgCopy.Left:=ImgPrint.Left+ImgPrint.Width+6;
  ImgSave.Top:=ImgHorizontal.Top+4;
  ImgSave.Left:=ImgCopy.Left+ImgCopy.Width+6;
  ImgEsc.Top:=ImgHorizontal.Top+4;
  ImgEsc.Left:=ImgSave.Left+ImgSave.Width+12;
  ImgPen.Top:=ImgVertical.Top+8;
  ImgPen.Left:=ImgVertical.Left+4;
  ImgLine.Top:=ImgPen.Top+ImgPen.Height+4;
  ImgLine.Left:=ImgVertical.Left+4;
  ImgArrow.Top:=ImgLine.Top+ImgLine.Height+4;
  ImgArrow.Left:=ImgVertical.Left+4;
  ImgRectangle.Top:=ImgArrow.Top+ImgArrow.Height+4;
  ImgRectangle.Left:=ImgVertical.Left+4;
  ImgMarker.Top:=ImgRectangle.Top+ImgRectangle.Height+4;
  ImgMarker.Left:=ImgVertical.Left+4;
  ImgText.Top:=ImgMarker.Top+ImgMarker.Height+4;
  ImgText.Left:=ImgVertical.Left+4;
  ImgColor.Top:=ImgText.Top+ImgText.Height+4;
  ImgColor.Left:=ImgVertical.Left+4;
  ImgCancel.Top:=ImgColor.Top+ImgColor.Height+10;
  ImgCancel.Left:=ImgVertical.Left+4;
  if fQuickshot.tsButton.State = TToggleSwitchState.tssOn then
    if (Shape.Height <> 0) and (Shape.Width <> 0) then ImgVisible(true);
end;

procedure TfPrtScreen.ImgFileMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImgFileDisable.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgFileMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImgFileHot.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgFileMouseEnter(Sender: TObject);
begin
  ImgFileHot.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgFileMouseLeave(Sender: TObject);
begin
  ImgFile.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImgEditDisable.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgEditMouseEnter(Sender: TObject);
begin
  ImgEditHot.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgEditMouseLeave(Sender: TObject);
begin
  ImgEdit.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

procedure TfPrtScreen.ImgEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImgEditHot.GetBitmap((Sender as TImage).Tag,(Sender as TImage).Picture.Bitmap);
  (Sender as TImage).Repaint;
end;

{$ENDREGION}

procedure TfPrtScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Picture);
end;

procedure TfPrtScreen.FormCreate(Sender: TObject);
begin
  ShapeMove:=false;
  ShapeFull:=false;
  Shape.Width:=0;
  Shape.Height:=0;
  Clipboard.Clear;
  PtrScToClipboard();
  try
    Picture:=TPicture.Create;
    if Clipboard.HasFormat(CF_BITMAP) then Picture.Bitmap.Assign(Clipboard);
    ImageSplash.Align:=TAlign.alClient;
  finally
    Clipboard.Clear;
    ImgVisible(false);
  end;
end;

procedure TfPrtScreen.FormShow(Sender: TObject);
begin
  fPrtScreen.Left:=0;
  fPrtScreen.Top:=0;
  fPrtScreen.ClientHeight:=Screen.Height;
  fPrtScreen.ClientWidth:=Screen.Width;
  fPrtScreen.FormStyle := fsStayOnTop;
end;

procedure TfPrtScreen.FormPaint(Sender: TObject);
var
  x, y: integer;
  R: TRect;
begin
  x:=0; y:=0;
  while y < fPrtScreen.Height do
    begin
      while x < fPrtScreen.Width do
        begin
          fPrtScreen.Canvas.Draw(x, y, Picture.Graphic);
          x:=x + Picture.Width;
        end;
      x:=0;
      y:=y + Picture.Height;
    end;

  r.Left:=0;
  r.Top:=0;
  R.Width:=Shape.Left;
  r.Height:=fPrtScreen.Height;
  BlendRectangle(fPrtScreen.Canvas,r,bland_color,bland_persent);

  r.Left:=Shape.Left;
  r.Top:=0;
  R.Width:=Shape.Width;
  r.Height:=Shape.top;
  BlendRectangle(fPrtScreen.Canvas,r,bland_color,bland_persent);

  r.Left:=Shape.Left;
  r.Top:=Shape.Top+Shape.Height;
  R.Width:=Shape.Width;
  r.Height:=fPrtScreen.Height;
  BlendRectangle(fPrtScreen.Canvas,r,bland_color,bland_persent);

  r.Left:=Shape.Left+Shape.Width;
  r.Top:=0;
  R.Width:=fPrtScreen.Width;
  r.Height:=fPrtScreen.Height;
  BlendRectangle(fPrtScreen.Canvas,r,bland_color,bland_persent);
end;

procedure TfPrtScreen.ImageSplashClick(Sender: TObject);
begin
  ImageSplash.Visible:=false;
  FreeAndNil(ImageSplash);
end;

procedure TfPrtScreen.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then fPrtScreen.ImgEscClick(Sender);
end;

procedure TfPrtScreen.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('S')) then fPrtScreen.ImgSaveClick(Sender);;
  if (ssCtrl in Shift) and (Key = Ord('C')) then fPrtScreen.ImgCopyClick(Sender);;
  if (ssCtrl in Shift) and (Key = Ord('P')) then fPrtScreen.ImgPrintClick(Sender);;
  if (ssCtrl in Shift) and (Key = Ord('G')) then fPrtScreen.ImgGoogleClick(Sender);;
end;

procedure TfPrtScreen.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft:
      begin
        X0 := X;
        Y0 := Y;
        Shape.Height := 0;
        Shape.Width := 0;
      end;
    mbRight:
      begin
        X0 := 0;
        Y0 := 0;
        Shape.Left := 0;
        Shape.Top := 0;
        Shape.Height := 0;
        Shape.Width := 0;
      end;
  end;
  ImgVisible(false);
  PointShapeMove;
end;

procedure TfPrtScreen.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fPrtScreen.Refresh;
  ImgPosition();
end;

procedure TfPrtScreen.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) then
    begin
      if (X < X0) then
        begin
          Shape.Left := X;
          Shape.Width := (X0 - Shape.Left);
        end
      else
        begin
          Shape.Left := X0;
          Shape.Width := (X - Shape.Left);
        end;
      if (Y < Y0) then
        begin
          Shape.Top := Y;
          Shape.Height := (Y0 - Shape.Top);
        end
      else
        begin
          Shape.Top := Y0;
          Shape.Height := (Y - Shape.Top);
        end;
      Shape.Hint := '[' + IntToStr(Shape.Width) + ' x ' + IntToStr(Shape.Height) + ']';
      PointShapeMove;
    end;
end;

{$REGION 'Point Shape'}

procedure TfPrtScreen.PointShapeMove;
begin
  if (Shape.Width = 0) and (Shape.Height = 0) then
    begin
      Shape1.Visible:=false;  Shape5.Visible:=false;
      Shape2.Visible:=false;  Shape6.Visible:=false;
      Shape3.Visible:=false;  Shape7.Visible:=false;
      Shape4.Visible:=false;  Shape8.Visible:=false;
    end
  else
    begin
      Shape1.Visible:=true;  Shape5.Visible:=true;
      Shape2.Visible:=true;  Shape6.Visible:=true;
      Shape3.Visible:=true;  Shape7.Visible:=true;
      Shape4.Visible:=true;  Shape8.Visible:=true;
    end;
  Shape1.Left:=Shape.Left-ROUND(Shape1.Width/2)+1;
  Shape1.Top:=Shape.Top-ROUND(Shape1.Height/2)+1;
  Shape2.Left:=Shape.Left+ROUND(Shape.Width/2)-ROUND(Shape2.Width/2)+1;
  Shape2.Top:=Shape.Top-ROUND(Shape2.Height/2)+1;
  Shape3.Left:=Shape.Left+Shape.Width-ROUND(Shape3.Width/2);
  Shape3.Top:=Shape.Top-ROUND(Shape3.Height/2)+1;
  Shape4.Left:=Shape.Left+Shape.Width-ROUND(Shape4.Width/2);
  Shape4.Top:=Shape.Top+ROUND(Shape.Height/2)-ROUND(Shape4.Height/2)+1;
  Shape5.Left:=Shape.Left+Shape.Width-ROUND(Shape5.Width/2);
  Shape5.Top:=Shape.Top+Shape.Height-ROUND(Shape5.Height/2);
  Shape6.Left:=Shape.Left+ROUND(Shape.Width/2)-ROUND(Shape6.Width/2)+1;
  Shape6.Top:=Shape.Top+Shape.Height-ROUND(Shape6.Height/2);
  Shape7.Left:=Shape.Left-ROUND(Shape7.Width/2)+1;
  Shape7.Top:=Shape.Top+Shape.Height-ROUND(Shape7.Height/2);
  Shape8.Left:=Shape.Left-ROUND(Shape7.Width/2)+1;
  Shape8.Top:=Shape.Top+ROUND(Shape.Height/2)-ROUND(Shape7.Height/2)+1;
end;

procedure TfPrtScreen.PointShapeMouseEnter(Sender: TObject);
begin
  if (Sender is TShape) then
    (Sender as TShape).Brush.Color:=clRed;
end;

procedure TfPrtScreen.PointShapeMouseLeave(Sender: TObject);
begin
  if (Sender is TShape) then
    (Sender as TShape).Brush.Color:=clBlack;
end;

{$ENDREGION}

{$REGION 'Main Shape'}

procedure TfPrtScreen.ShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ImgVisible(false);
  if (ssDouble in Shift) then
    begin
      if ShapeFull then
        begin
          Shape.Left:=Xs;
          Shape.Top:=Ys;
          Shape.Width:=Ws;
          Shape.Height:=Hs;
          ShapeFull:=not ShapeFull;
        end
      else
        begin
          Xs:=Shape.Left;
          Ys:=Shape.Top;
          Ws:=Shape.Width;
          Hs:=Shape.Height;
          Shape.Left:=0;
          Shape.Top:=0;
          Shape.Width:=Screen.Width;
          Shape.Height:=Screen.Height;
          ShapeFull:=not ShapeFull;
        end;
      PointShapeMove;
    end;
  if (ssLeft in Shift) then
    begin
      ShapeMove := true;
      x0 := x;
      y0 := y;
    end;
end;

procedure TfPrtScreen.ShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Left, Top: smallint;
begin
 if ShapeMove then
   begin
     Left := Shape.Left + X - X0;
     Top := Shape.top + Y - Y0;
     if Left<fPrtScreen.Left then Left:=fPrtScreen.Left;
     if Top<fPrtScreen.top then Top:=fPrtScreen.top;
     if Left+Shape.Width>fPrtScreen.Left+fPrtScreen.Width then Left:=fPrtScreen.Left+fPrtScreen.Width-Shape.Width;
     if Top+Shape.Height>fPrtScreen.top+fPrtScreen.Height then Top:=fPrtScreen.top+fPrtScreen.Height-Shape.Height;
     Shape.Left := Left;
     Shape.top  := Top;
   end;
  PointShapeMove;
end;

procedure TfPrtScreen.ShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShapeMove := false;
  ImgPosition;
end;

{$ENDREGION}

initialization
{ Инициализация модуля }

finalization
{ Завершение работы модуля }

end.
