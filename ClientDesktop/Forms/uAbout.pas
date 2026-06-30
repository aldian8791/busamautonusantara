unit uAbout;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Effects, FMX.Layouts, FMX.ExtCtrls, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Ani;

type
  TfAbout = class(TForm)
    rtlAbout: TRectangle;
    sdeAbout: TShadowEffect;
    imgAbout: TImage;
    FloatAnimation1: TFloatAnimation;
    ShadowEffect1: TShadowEffect;
    Image1: TImage;
    ShadowEffect2: TShadowEffect;
    Label1: TLabel;
    ShadowEffect12: TShadowEffect;
    lblAboutComp: TLabel;
    ShadowEffect3: TShadowEffect;
    Label2: TLabel;
    ShadowEffect10: TShadowEffect;
    Label3: TLabel;
    ShadowEffect9: TShadowEffect;
    Label4: TLabel;
    ShadowEffect8: TShadowEffect;
    Label5: TLabel;
    ShadowEffect7: TShadowEffect;
    Label6: TLabel;
    ShadowEffect6: TShadowEffect;
    Label7: TLabel;
    ShadowEffect5: TShadowEffect;
    imgComp: TImage;
    FloatAnimation2: TFloatAnimation;
    lblVersion: TLabel;
    ShadowEffect11: TShadowEffect;
    procedure rtlAboutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rtlAboutResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAbout: TfAbout;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientSet, uClientCmd;

var
  frmWidth, frmHeight: single;

procedure TfAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfAbout.FormCreate(Sender: TObject);
begin
  fMain.SetrtlModal;
  frmWidth:= rtlAbout.Width;
  frmHeight:= rtlAbout.Height;
  TmClientSet.EnableDragResize(rtlAbout);//move and resize control
  rtlAbout.Align:= TAlignLayout.None;
  rtlAbout.Stroke.Color:= strkcolor;
  rtlAbout.Stroke.Thickness:= strkthickness;
  with sdeAbout do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  lblAboutComp.Text:= gcomp;
  imgComp.Bitmap.LoadFromStream(gmrsLogo75);
  lblVersion.Text:= 'Version '+ gversionname;
end;

procedure TfAbout.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMain.lytModal);
  FreeAndNil(fMain.rtlModal);
  fMain.lytMain.Enabled:= True;
  fMain.btnMenu.SetFocus;
  fAbout:= nil;
end;

procedure TfAbout.rtlAboutClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfAbout.rtlAboutResize(Sender: TObject);
begin
  if (frmWidth> 0) or (frmHeight> 0) then begin
  //do not resize rectangle
    with rtlAbout do begin
      if (Width< frmWidth) or (Width> frmWidth) then begin
        Width:= frmWidth;
      end;
      if (Height< frmHeight) or (Height> frmHeight) then begin
        Height:= frmHeight;
      end;
    end;
  end;
end;

end.
