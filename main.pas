unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Media, FMX.Platform, System.Actions,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    btnTakeFront: TSpeedButton;
    btnTakeBack: TSpeedButton;
    btnSharePhoto: TSpeedButton;
    CameraBack: TCameraComponent;
    CameraFront: TCameraComponent;
    imgBack: TImage;
    imgFront: TImage;
    imgPhoto: TImage;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    procedure FormResize(Sender: TObject);
    procedure CameraBackSampleBufferReady(Sender: TObject; const ATime: Int64);
    procedure CameraFrontSampleBufferReady(Sender: TObject; const ATime: Int64);
    procedure FormCreate(Sender: TObject);
    procedure TakePhoto(Sender: TObject);
    procedure SwitchCamera(Sender: TObject);
    procedure ShowShareSheetAction1BeforeExecute(Sender: TObject);
  private
    { Private declarations }
    bmp : TBitmap;
    function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

function TForm1.AppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  case AAppEvent of
    TApplicationEvent.WillBecomeInactive,
    TApplicationEvent.EnteredBackground,
    TApplicationEvent.WillTerminate:
    begin
      CameraBack.Active := False;
      CameraFront.Active := False;
    end;
    TApplicationEvent.BecameActive:
    begin
      CameraBack.Active := True;
    end;
  end;
end;

procedure TForm1.CameraBackSampleBufferReady(Sender: TObject;
  const ATime: Int64);
begin
  CameraBack.SampleBufferToBitmap(imgBack.Bitmap, True);
end;

procedure TForm1.CameraFrontSampleBufferReady(Sender: TObject;
  const ATime: Int64);
begin
  CameraFront.SampleBufferToBitmap(imgFront.Bitmap, True);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  AppEventSvc: IFMXApplicationEventService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEventSvc)) then
    AppEventSvc.SetApplicationEventHandler(AppEvent);
  bmp := TBitmap.Create;
  bmp.SetSize(trunc(imgPhoto.Width), trunc(imgPhoto.Height));
  CameraBack.Active := True;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Layout1.Height := (Form1.Height-Label1.Height)/2;
  Layout3.Width := Form1.Width/2;
end;

procedure TForm1.ShowShareSheetAction1BeforeExecute(Sender: TObject);
begin
  ShowShareSheetAction1.Bitmap.Assign(imgPhoto.Bitmap);
end;

procedure TForm1.SwitchCamera(Sender: TObject);
begin
  if Sender=imgBack then
  begin
    CameraFront.Active := False;
    CameraBack.Active := True;
    imgBack.Opacity := 1;
    imgFront.Opacity := 0.5;
  end
  else
  begin
    CameraBack.Active := False;
    CameraFront.Active := True;
    imgFront.Opacity := 1;
    imgBack.Opacity := 0.5;
  end;
end;

procedure TForm1.TakePhoto(Sender: TObject);
begin
  if Sender=btnTakeBack then
  begin
    if CameraBack.Active then
      CameraBack.Active := False;
    bmp.Canvas.BeginScene();
    bmp.Canvas.DrawBitmap(imgBack.Bitmap, RectF(0,0,imgBack.Bitmap.Width, imgBack.Bitmap.Height), RectF(0, 0, bmp.Width/2, bmp.Height), 1, True);
    bmp.Canvas.EndScene;
    imgBack.Opacity := 0.5;
  end
  else
  begin
    if CameraFront.Active then
      CameraFront.Active := False;
    bmp.Canvas.BeginScene();
    bmp.Canvas.DrawBitmap(imgFront.Bitmap, RectF(0,0,imgFront.Bitmap.Width, imgFront.Bitmap.Height), RectF(bmp.Width/2, 0, bmp.Width, bmp.Height), 1, True);
    bmp.Canvas.EndScene;
    imgFront.Opacity := 0.5;
  end;
  imgPhoto.Bitmap.Assign(bmp);
end;

end.
