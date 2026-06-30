unit uChangePwd;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.JSON, System.Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.TMSFNCButton,
  FMX.Effects, FMX.DialogService, FMX.Graphics, FMX.StdCtrls, FMX.Edit,
  FMX.Dialogs;

type
  TfChangePwd = class(TForm)
    rtlChangePwd: TRectangle;
    lytHeader: TLayout;
    btnClose: TTMSFNCButton;
    Label1: TLabel;
    sdeChangePwd: TShadowEffect;
    edtCurrentPwd: TEdit;
    Label2: TLabel;
    linChangePwd: TLine;
    lytAction: TLayout;
    btnClear: TTMSFNCButton;
    btnOK: TTMSFNCButton;
    Label3: TLabel;
    edtNewPwd: TEdit;
    Label4: TLabel;
    edtConfirmPwd: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    PasswordEditButton2: TPasswordEditButton;
    PasswordEditButton3: TPasswordEditButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure rtlChangePwdResize(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure edtCurrentPwdKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtNewPwdKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtConfirmPwdKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fChangePwd: TfChangePwd;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientCmd, uClientSet, cLogin, uClientFrmCursor;

var
  frmWidth, frmHeight: single;

procedure TfChangePwd.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfChangePwd.btnOKClick(Sender: TObject);
var
  ArrEditData: TJSONArray;
  ObjEditData: TJSONObject;
  myDecrypted, myEncrypted, Response: string;
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    fMain.CurrentGlobalData;
    if gusertype= 0 then begin
      if gmaintenance= True then begin
        TDialogService.MessageDialog('Sorry, Server is in maintenance mode.'+
          'Please try again later or contact the relevant authorities.',
          TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0,
          nil);
        Exit;
      end;
    end;
    if gusertype<> 2 then begin
      if gkick= True then begin
        TDialogService.MessageDialog('Sorry, you are temporarily banned from '+
          'this system. Please contact the relevant authorities.',
          TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0,
          nil);
        Exit;
      end;
    end;
    if edtCurrentPwd.Text= '' then begin
      TDialogService.MessageDialog('Please input your Current Password.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
      edtCurrentPwd.SetFocus;
      Exit;
    end;
    fMain.myCodec.DecryptString(myDecrypted, gpassword, TEncoding.UTF8);
    if edtCurrentPwd.Text<> myDecrypted then begin
      TDialogService.MessageDialog('Incorrect Current Password. Please try again.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
      edtCurrentPwd.SetFocus;
      Exit;
    end;
    if edtNewPwd.Text= '' then begin
      TDialogService.MessageDialog('Your New Password is empty. Please input '+
        'your New Password.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose],
        TMsgDlgBtn.mbClose, 0, nil);
      edtNewPwd.SetFocus;
      Exit;
    end;
    if edtConfirmPwd.Text= '' then begin
      TDialogService.MessageDialog('Your Confirm Password is empty. Please '+
        'input your Confirm Password.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
      edtConfirmPwd.SetFocus;
      Exit;
    end;
    if edtNewPwd.Text<> edtConfirmPwd.Text then begin
      TDialogService.MessageDialog('The Password Confirmation does not match. '+
        'Please try again', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose],
        TMsgDlgBtn.mbClose, 0, nil);
      edtConfirmPwd.SetFocus;
      Exit;
    end;
    if edtCurrentPwd.Text= edtNewPwd.Text then begin
      TDialogService.MessageDialog('The New Password can not match The Current '+
        'Password. Please try again', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose],
        TMsgDlgBtn.mbClose, 0, nil);
      edtNewPwd.SetFocus;
      Exit;
    end;
    if edtCurrentPwd.Text= myDecrypted then begin
      fMain.myCodec.EncryptString(edtConfirmPwd.Text, myEncrypted, TEncoding.UTF8);
      ArrEditData:= TJSONArray.Create;
      try
        ObjEditData:= TJSONObject.Create;
        ObjEditData.AddPair('urname', gusername.Trim);
        ObjEditData.AddPair('urpassword', myEncrypted);
        ArrEditData.AddElement(ObjEditData);
        Response:= TcLogin.UpdatePwdByUsername(ArrEditData.ToJSON);//update database with response
      finally
        FreeAndNil(ArrEditData);
      end;
      ObjEditData:= TJSONObject.ParseJSONValue(Response) as TJSONObject;
      try
        if ObjEditData.GetValue<boolean>('success')= True then begin
          TDialogService.MessageDialog(ObjEditData.GetValue<string>('message')+
            #13+ 'Affected: '+ ObjEditData.GetValue<smallint>(
            'affected').ToString+' row(s)', TMsgDlgType.mtInformation,
            [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
        gpassword:= myEncrypted;
      finally
        FreeAndNil(ObjEditData);
      end;
      Self.Close;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfChangePwd.btnClearClick(Sender: TObject);
begin
  edtCurrentPwd.Text:= '';
  edtNewPwd.Text:= '';
  edtConfirmPwd.Text:= '';
  edtCurrentPwd.SetFocus;
end;

procedure TfChangePwd.edtConfirmPwdKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnOKClick(Sender);
  end;
end;

procedure TfChangePwd.edtCurrentPwdKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtNewPwd.SetFocus;
  end;
end;

procedure TfChangePwd.edtNewPwdKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtConfirmPwd.SetFocus;
  end;
end;

procedure TfChangePwd.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfChangePwd.FormCreate(Sender: TObject);
begin
  fMain.SetrtlModal;
  frmWidth:= rtlChangePwd.Width;
  frmHeight:= rtlChangePwd.Height;
  TmClientSet.EnableDragResize(rtlChangePwd);//move and resize control
  with rtlChangePwd do begin
    Align:= TAlignLayout.None;
    Stroke.Color:= strkcolor;
    Stroke.Thickness:= strkthickness;
    if themedark= True then begin
      Fill.Color:= darkcolor;
      Fill.Kind:= TBrushKind.Solid;
    end;
  end;
  linChangePwd.Stroke.Color:= strkcolor;
  linChangePwd.Stroke.Thickness:= strkthickness;
  with sdeChangePwd do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  edtCurrentPwd.MaxLength:= 20;
  edtCurrentPwd.Password:= True;
  edtNewPwd.MaxLength:= 20;
  edtNewPwd.Password:= True;
  edtConfirmPwd.MaxLength:= 20;
  edtConfirmPwd.Password:= True;
end;

procedure TfChangePwd.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMain.lytModal);
  FreeAndNil(fMain.rtlModal);
  fMain.lytMain.Enabled:= True;
  fMain.btnMenu.SetFocus;
  fChangePwd:= nil;
end;

procedure TfChangePwd.rtlChangePwdResize(Sender: TObject);
begin
  if (frmWidth> 0) or (frmHeight> 0) then begin
  //do not resize rectangle
    with rtlChangePwd do begin
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
