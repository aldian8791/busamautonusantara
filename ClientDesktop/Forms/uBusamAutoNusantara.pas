unit uBusamAutoNusantara;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, System.JSON, System.DateUtils, System.Generics.Collections,
  FMX.Controls.Presentation, FMX.Graphics, FMX.Controls, (*AES*)uTPLb_Constants,
  uTPLb_CryptographicLibrary, uTPLb_Codec(*AES*), FMX.Layouts, FMX.DialogService,
  FMX.Styles, FMX.Dialogs, FMX.Objects, FMX.StdCtrls, FMX.Types, FMX.Forms,
  FMX.TMSFNCButton, FMX.TMSFNCTabSet, FMX.TMSFNCTypes, FMX.TMSFNCPageControl,
  FMX.TMSFNCCustomComponent, FMX.TMSFNCBitmapContainer, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl, FMX.TMSFNCUtils, FMX.TMSFNCGraphics;

type
  TfMain = class(TForm)
    lytMain: TLayout;
    lytStatus: TLayout;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Image1: TImage;
    imgUsername: TImage;
    lblUsername: TLabel;
    lblTime: TLabel;
    Layout4: TLayout;
    lblDate: TLabel;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Image3: TImage;
    lblServerName: TLabel;
    imgCompany: TImage;
    lblDBName: TLabel;
    lblMessage: TLabel;
    Layout8: TLayout;
    Image5: TImage;
    lytMenuBackground: TLayout;
    lytMenu: TLayout;
    lytMenuHeader: TLayout;
    vsbMenuBody: TVertScrollBox;
    rtlMenu: TRectangle;
    rtlMenuBackground: TRectangle;
    lytMenuTab: TLayout;
    btnMenu: TTMSFNCButton;
    bctMain: TTMSFNCBitmapContainer;
    lytTransaction: TLayout;
    lytMaster: TLayout;
    lytReport: TLayout;
    lytGeneral: TLayout;
    lytMenuFooter: TLayout;
    btnTransaction: TTMSFNCButton;
    btnMaster: TTMSFNCButton;
    btnReport: TTMSFNCButton;
    btnGeneral: TTMSFNCButton;
    pclMain: TTMSFNCPageControl;
    TMSFNCPageControl1Page0: TTMSFNCPageControlContainer;
    TMSFNCPageControl1Page1: TTMSFNCPageControlContainer;
    TMSFNCPageControl1Page2: TTMSFNCPageControlContainer;
    rtlMain: TRectangle;
    gytGeneral: TGridLayout;
    btnChangePwd: TTMSFNCButton;
    gytMaster: TGridLayout;
    btnCountry: TTMSFNCButton;
    btnState: TTMSFNCButton;
    btnCity: TTMSFNCButton;
    btnCurrency: TTMSFNCButton;
    btnUserRegister: TTMSFNCButton;
    gytReport: TGridLayout;
    btnPrintReport: TTMSFNCButton;
    GridLayout2: TGridLayout;
    btnOptions: TTMSFNCButton;
    btnNumberMap: TTMSFNCButton;
    GridLayout3: TGridLayout;
    btnAbout: TTMSFNCButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure rtlMenuBackgroundClick(Sender: TObject);
    procedure vsbMenuBodyMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure btnTransactionClick(Sender: TObject);
    procedure btnMasterClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnGeneralClick(Sender: TObject);
    procedure btnChangePwdClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnUserRegisterClick(Sender: TObject);
    procedure pclMainBeforeClosePage(Sender: TObject; APageIndex: Integer;
      var ACloseAction: TTMSFNCPageControlPageCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure btnOptionsClick(Sender: TObject);
    procedure btnCountryClick(Sender: TObject);
    procedure btnStateClick(Sender: TObject);
    procedure btnCityClick(Sender: TObject);
    procedure btnCurrencyClick(Sender: TObject);
    procedure btnNumberMapClick(Sender: TObject);
    procedure btnPrintReportClick(Sender: TObject);
  private
    procedure tmrServerTimer(Sender: TObject);
  public
    tmrServer: TTimer;
    lytModal: TLayout;
    rtlModal: TRectangle;
    CryptoLib: TCryptographicLibrary;
    myCodec: TCodec;
    ostheme: shortint;
    procedure CurrentGlobalData;
    procedure SetrtlModal;
  end;

var
  fMain: TfMain;

implementation

{$R *.fmx}

uses uClientCmd, uLogin, uClientSet, cLogin, uChangePwd, uAbout, uUserRegister,
  uUserRegisterInput, uClientFrmCursor, uOptions, cOptions, uCountry,
  uCountryInput, uState, uStateInput, uCity, uCityInput, uCurrency,
  uCurrencyInput, uNumberMap, uPrintReport, uUserPassword;

var
  winmaxid, osthemeid: string;

procedure TfMain.btnMenuClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  if lytMenuBackground.Visible= False then begin
    lytMenuBackground.Visible:= True;
    lytMenuBackground.Enabled:= True;
    lytMenuBackground.BringToFront;
    btnMenu.Parent:= lytMenuHeader;
    btnTransaction.SetFocus;
  end else begin
    lytMenuBackground.SendToBack;
    lytMenuBackground.Visible:= False;
    lytMenuBackground.Enabled:= False;
    btnMenu.Parent:= lytMenuTab;
    btnMenu.SetFocus;
  end;
  TmClientFrmCursor.CursorOverride:= crDefault;
end;

procedure TfMain.btnNumberMapClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fNumberMap') then begin
      fNumberMap.Close;
    end;
    fNumberMap:= TfNumberMap.Create(Self);
    with fNumberMap.rtlNumberMap do begin
      Parent:= lytModal;
      Align:= TAlignLayout.Center;
      Align:= TAlignLayout.None;
    end;
    btnMenuClick(Self);
    fNumberMap.grdList.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnOptionsClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fOptions') then begin
      fOptions.Close;
    end;
    fOptions:= TfOptions.Create(Self);
    with fOptions.rtlOptions do begin
      Parent:= lytModal;
      Align:= TAlignLayout.Center;
      Align:= TAlignLayout.None;
    end;
    btnMenuClick(Self);
    if gusertype= 0 then begin
      fOptions.lceCurrency.SetFocus;
    end else if gusertype<> 0 then begin
      fOptions.chkMaintenance.SetFocus;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnPrintReportClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fPrintReport') then begin
      pclMain.SelectTab((fPrintReport.lytPrintReport.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('PrintReport');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnPrintReport.Visible= True then begin
            Bitmaps.AddBitmapName(btnPrintReport.BitmapName);
          end;
          Text:= 'Print Report';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fPrintReport:= TfPrintReport.Create(Self);
      fPrintReport.lytPrintReport.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fPrintReport.lytPrintReport.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.CurrentGlobalData;
var
  ArrGlobalData: TJSONArray;
  ObjGlobalData: TJSONObject;
  JSONGlobalData: string;
begin
  JSONGlobalData:= '';
  JSONGlobalData:= TcLogin.GetDateTimeServer;
  ArrGlobalData:= TJSONObject.ParseJSONValue(JSONGlobalData) as TJSONArray;
  try
    if ArrGlobalData.Count> 0 then begin
      ObjGlobalData:= ArrGlobalData.Items[0] as TJSONObject;
      gdateserver:= ISO8601ToDate(ObjGlobalData.GetValue<string>('curdate'));
      gtimeserver:= StrToTime(ObjGlobalData.GetValue<string>('curtime'));
    end;
  finally
    FreeAndNil(ArrGlobalData);
  end;

  JSONGlobalData:= '';
  JSONGlobalData:= TcLogin.GetKickUser(gusername);
  ArrGlobalData:= TJSONObject.ParseJSONValue(JSONGlobalData) as TJSONArray;
  try
    if ArrGlobalData.Count> 0 then begin
      ObjGlobalData:= ArrGlobalData.Items[0] as TJSONObject;
      if gusername<> 'aldian' then begin
        gkick:= ObjGlobalData.GetValue<boolean>('kick');
      end;
    end;
  finally
    FreeAndNil(ArrGlobalData);
  end;

  JSONGlobalData:= '';
  JSONGlobalData:= TcOptions.GetOptionsMaintenance;
  ArrGlobalData:= TJSONObject.ParseJSONValue(JSONGlobalData) as TJSONArray;
  try
    if ArrGlobalData.Count> 0 then begin
      ObjGlobalData:= ArrGlobalData.Items[0] as TJSONObject;
      gmaintenance:= ObjGlobalData.GetValue<string>('otvalue').ToBoolean;
    end;
  finally
    FreeAndNil(ArrGlobalData);
  end;

  JSONGlobalData:= '';
  JSONGlobalData:= TcOptions.GetOptionsmyMessage;
  ArrGlobalData:= TJSONObject.ParseJSONValue(JSONGlobalData) as TJSONArray;
  try
    if ArrGlobalData.Count> 0 then begin
      ObjGlobalData:= ArrGlobalData.Items[0] as TJSONObject;
      lblMessage.Text:= ObjGlobalData.GetValue<string>('otvalue');
    end;
  finally
    FreeAndNil(ArrGlobalData);
  end;
end;

procedure TfMain.btnAboutClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    if TmClientCmd.IsFormOpen('fAbout') then begin
      fAbout.Close;
    end;
    fAbout:= TfAbout.Create(Self);
    with fAbout.rtlAbout do begin
      Parent:= lytModal;
      Align:= TAlignLayout.Center;
      Align:= TAlignLayout.None;
    end;
    btnMenuClick(Self);
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.tmrServerTimer(Sender: TObject);
begin
  gtimeserver:= gtimeserver + 0.0000115740740740741;
  lblDate.Text:= DateToStr(gdateserver);
  lblTime.Text:= TimeToStr(gtimeserver);
  gdatetimeserver:= gdateserver+ gtimeserver;
end;

procedure TfMain.btnChangePwdClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fChangePwd') then begin
      fChangePwd.Close;
    end;
    fChangePwd:= TfChangePwd.Create(Self);
    with fChangePwd.rtlChangePwd do begin
      Parent:= lytModal;
      Align:= TAlignLayout.Center;
      Align:= TAlignLayout.None;
    end;
    btnMenuClick(Self);
    fChangePwd.edtCurrentPwd.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnCityClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fCity') then begin
      pclMain.SelectTab((fCity.lytCity.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('CityList');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnCity.Visible= True then begin
            Bitmaps.AddBitmapName(btnCity.BitmapName);
          end;
          Text:= 'City List';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fCity:= TfCity.Create(Self);
      fCity.lytCity.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fCity.lytCity.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnCountryClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fCountry') then begin
      pclMain.SelectTab((fCountry.lytCountry.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('CountryList');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnCountry.Visible= True then begin
            Bitmaps.AddBitmapName(btnCountry.BitmapName);
          end;
          Text:= 'Country List';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fCountry:= TfCountry.Create(Self);
      fCountry.lytCountry.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fCountry.lytCountry.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnCurrencyClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fCurrency') then begin
      pclMain.SelectTab((fCurrency.lytCurrency.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('CurrencyList');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnCurrency.Visible= True then begin
            Bitmaps.AddBitmapName(btnCurrency.BitmapName);
          end;
          Text:= 'Currency List';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fCurrency:= TfCurrency.Create(Self);
      fCurrency.lytCurrency.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fCurrency.lytCurrency.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnGeneralClick(Sender: TObject);
begin
  if lytGeneral.Height= 22 then begin
    lytGeneral.Height:= 75;
    gytGeneral.Visible:= True;
  end else if lytGeneral.Height= 75 then begin
    lytGeneral.Height:= 22;
    gytGeneral.Visible:= False;
  end;
  if vsbMenuBody.ContentBounds.Height> vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 0;
  end else if vsbMenuBody.ContentBounds.Height<= vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 16;
  end;
end;

procedure TfMain.btnReportClick(Sender: TObject);
begin
  if lytReport.Height= 22 then begin
    lytReport.Height:= 75;
  end else if lytReport.Height= 75 then begin
    lytReport.Height:= 22;
  end;
  if vsbMenuBody.ContentBounds.Height> vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 0;
  end else if vsbMenuBody.ContentBounds.Height<= vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 16;
  end;
end;

procedure TfMain.btnStateClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fState') then begin
      pclMain.SelectTab((fState.lytState.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('StateList');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnState.Visible= True then begin
            Bitmaps.AddBitmapName(btnState.BitmapName);
          end;
          Text:= 'State List';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fState:= TfState.Create(Self);
      fState.lytState.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fState.lytState.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.btnMasterClick(Sender: TObject);
begin
  if lytMaster.Height= 22 then begin
    lytMaster.Height:= 75;
    gytMaster.Visible:= True;
  end else if lytMaster.Height= 75 then begin
    lytMaster.Height:= 22;
    gytMaster.Visible:= False;
  end;
  if vsbMenuBody.ContentBounds.Height> vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 0;
  end else if vsbMenuBody.ContentBounds.Height<= vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 16;
  end;
end;

procedure TfMain.btnTransactionClick(Sender: TObject);
begin
  if lytTransaction.Height= 22 then begin
    lytTransaction.Height:= 200;
  end else if lytTransaction.Height= 200 then begin
    lytTransaction.Height:= 22;
  end;
  if vsbMenuBody.ContentBounds.Height> vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 0;
  end else if vsbMenuBody.ContentBounds.Height<= vsbMenuBody.Height then begin
    vsbMenuBody.Padding.Right:= 16;
  end;
end;

procedure TfMain.btnUserRegisterClick(Sender: TObject);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    CurrentGlobalData;
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
    if TmClientCmd.IsFormOpen('fUserRegister') then begin
      pclMain.SelectTab((fUserRegister.lytUserRegister.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      with pclMain do begin
        AddPage('UserRegisterList');
        SelectTab(Pages.Count- 1);
        TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
        with Pages.Tabs[Pages.Count- 1] do begin
          if btnUserRegister.Visible= True then begin
            Bitmaps.AddBitmapName(btnUserRegister.BitmapName);
          end;
          Text:= 'UserRegister List';
        end;
        with PageContainers[Pages.Count- 1] do begin
          TmClientCmd.FillTMSColor(Fill, False, False);
          Stroke.Width:= strkthickness;
        end;
      end;
      fUserRegister:= TfUserRegister.Create(Self);
      fUserRegister.lytUserRegister.Parent:=
        pclMain.PageContainers[pclMain.Pages.Count- 1];
    end;
    btnMenuClick(Self);
    fUserRegister.lytUserRegister.SetFocus;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: integer;
  ArrUpdateData: TJSONArray;
  ObjUpdateData: TJSONObject;
begin
  ArrUpdateData:= TJSONArray.Create;
  try
    if gusername= '' then begin
      gusername:= 'system';
    end;
    {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64))}
    if WindowState= TWindowState.wsNormal then begin
      if winmax= 1 then begin
        ObjUpdateData:= TJSONObject.Create;
        ObjUpdateData.AddPair('riftendesc', winmaxid);
        ObjUpdateData.AddPair('riftenvalue', 0);
        ObjUpdateData.AddPair('edituser', gusername);
        ArrUpdateData.AddElement(ObjUpdateData);
      end;
    end;
    if WindowState= TWindowState.wsMaximized then begin
      if winmax= 0 then begin
        ObjUpdateData:= TJSONObject.Create;
        ObjUpdateData.AddPair('riftendesc', winmaxid);
        ObjUpdateData.AddPair('riftenvalue', 1);
        ObjUpdateData.AddPair('edituser', gusername);
        ArrUpdateData.AddElement(ObjUpdateData);
      end;
    end;
    {$ENDIF}
    if curtheme<> ostheme then begin
      ObjUpdateData:= TJSONObject.Create;
      ObjUpdateData.AddPair('riftendesc', osthemeid);
      ObjUpdateData.AddPair('riftenvalue', curtheme);
      ObjUpdateData.AddPair('edituser', gusername);
      ArrUpdateData.AddElement(ObjUpdateData);
    end;
    TmClientSet.UpdateriftensetBydesc(ArrUpdateData.ToJSON);
  finally
    FreeAndNil(ArrUpdateData);
  end;

  i:= Screen.FormCount- 1;
  while i>= 0 do begin
  //close all forms except mainform
    if Screen.Forms[i]<> Application.MainForm then begin
      Screen.Forms[i].Close;
    end;
    dec(i);
  end;
end;

procedure TfMain.SetrtlModal;//Make modal form in form for all OS
begin
  if TmClientCmd.IsFormOpen('fLogin')= False then begin
    rtlModal:= TRectangle.Create(Self);
    with rtlModal do begin
      Parent:= Self;
      Align:= TAlignLayout.Contents;
      TmClientCmd.FillBrushColor(rtlModal.Fill, True, True, False);
      Opacity:= 0.15;
    end;
  end;
  lytModal:= TLayout.Create(Self);
  with lytModal do begin
    Parent:= Self;
    Align:= TAlignLayout.Contents;
    BringToFront;
  end;
  lytMain.Enabled:= False;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  i: integer;
  JSONGetriftensetBydesc: string;
  ArrGetriftensetBydesc: TJSONArray;
  ObjGetriftensetBydesc: TJSONObject;
  sltError: TStringList;
begin
  winmax:= 0;
  rtlMenu.Stroke.Color:= strkcolor;
  rtlMenu.Stroke.Thickness:= strkthickness;
  lytMain.Visible:= False;
  gmrsLogo22:= TMemoryStream.Create;
  gmrsLogo75:= TMemoryStream.Create;
  mrsIcon:= TMemoryStream.Create;
  tmrServer:= TTimer.Create(self);
  CryptoLib:= TCryptographicLibrary.Create(self);
  myCodec:= TCodec.Create(self);
  with myCodec do begin
    CryptoLibrary:= CryptoLib;
    StreamCipherId:= BlockCipher_ProgId;
    BlockCipherId:= Format(AES_ProgId, [256]);
    ChainModeId:= ECB_ProgId;
    Password:= aeskey;
  end;
  tmrServer.Enabled:= False;
  tmrServer.OnTimer:= tmrServerTimer;
  with pclMain do begin
    AdaptToStyle:= True;
    Pages.Clear;
    TabAppearance.Font.Size:= 12;
    TabAppearance.ShowFocus:= True;
    Interaction.Reorder:= True;
    Interaction.CloseTabWithKeyboard:= False;
    Interaction.InsertTabWithKeyboard:= False;
    Interaction.SelectTabOnScroll:= False;
    Options.CloseMode:= TTMSFNCTabSetCloseMode.tcmTab;
    Options.CloseAction:= TTMSFNCTabSetTabCloseAction.ttcaFree;
    TabSize.Margins.Bottom:= 0;
    TabSize.Margins.Left:= 0;
    TabSize.Margins.Right:= 0;
    TabSize.Margins.Top:= 0;
  end;
  {i:= 0;
  while i< ComponentCount do begin
    if Components[i] is TTMSFNCButton then begin
      TTMSFNCButton(Components[i]).Opacity:= btnopacity;
    end;
    inc(i);
  end;}
  btnNumberMap.Visible:= False;

  lytTransaction.Height:= 22;
  lytMaster.Height:= 22;
  lytReport.Height:= 22;
  lytGeneral.Height:= 22;
  btnTransaction.Opacity:= 0.2;
  btnMaster.Opacity:= 0.2;
  btnReport.Opacity:= 0.2;
  btnGeneral.Opacity:= 0.2;
  gytMaster.Visible:= False;
  gytGeneral.Visible:= False;

  //Get JSON Array
  JSONGetriftensetBydesc:= '';
  JSONGetriftensetBydesc:= TmClientSet.ReadriftensetBydesc;
  ArrGetriftensetBydesc:= TJSONObject.ParseJSONValue(JSONGetriftensetBydesc) as
    TJSONArray;
  sltError:= TStringList.Create;
  try
    if ArrGetriftensetBydesc.Count> 1 then begin
      i:= 0;
      while i< ArrGetriftensetBydesc.Count do begin
        try
          try
            ObjGetriftensetBydesc:= ArrGetriftensetBydesc.Items[i] as TJSONObject;
            if ObjGetriftensetBydesc.GetValue<string>('riftendesc')= 'windowmode'
            then begin
              winmaxid:= ObjGetriftensetBydesc.GetValue<string>('riftendesc');
              winmax:= ObjGetriftensetBydesc.GetValue<shortint>('riftenvalue');
            end;
            if ObjGetriftensetBydesc.GetValue<string>('riftendesc')= 'ostheme'
            then begin
              osthemeid:= ObjGetriftensetBydesc.GetValue<string>('riftendesc');
              ostheme:= ObjGetriftensetBydesc.GetValue<shortint>('riftenvalue');
            end;
          except
            on E: Exception do
              sltError.Add(Format('Line %d: %s', [i, E.Message]));
          end;
        finally
          inc(i);
        end;
      end;
    end;
    {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64))}
    if winmax= 0 then begin
      WindowState:= TWindowState.wsNormal;
    end else if winmax= 1 then begin
      {$IF (DEFINED(LINUX64))}
      TThread.ForceQueue(nil,
      procedure
      begin
        WindowState:= TWindowState.wsMaximized;
      end);
      {$ENDIF}
      {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(OSX64))}
        WindowState:= TWindowState.wsMaximized;
      {$ENDIF}
    end;
    {$ENDIF}
    if sltError.Count> 0 then begin
      TDialogService.MessageDialog(sltError.Text, TMsgDlgType.mtError,
        [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    end;
  finally
    FreeAndNil(sltError);
    FreeAndNil(ArrGetriftensetBydesc);
  end;

  gcolorpoint0:= 4294177779;
  gcolorpoint1:= 4294177779;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CryptoLib);
  FreeAndNil(myCodec);
  FreeAndNil(tmrServer);
  FreeAndNil(gmrsLogo22);
  FreeAndNil(gmrsLogo75);
  FreeAndNil(mrsIcon);
  fMain:= nil
end;

procedure TfMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkF10 then begin
    btnMenuClick(Sender);
  end;
end;

procedure TfMain.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkEscape then begin
    rtlMenuBackgroundClick(Sender);
  end;
  if Key= vkTab then begin
    if pclMain.Pages.Count<= 0 then begin
      pclMain.TabStop:= False;
    end else if pclMain.Pages.Count> 0 then begin
      pclMain.TabStop:= True;
    end;
  end;
end;

procedure TfMain.FormResize(Sender: TObject);
begin
  if Active= True then begin
    if ClientHeight< 600 then begin
      ClientHeight:= 600;
    end;
    if ClientWidth< 600 then begin
      ClientWidth:= 600;
    end;
  end;
  if TmClientCmd.IsFormOpen('fLogin')= True then begin
    with fLogin do begin
      rtlLogin.Align:= TAlignlayout.Center;
      rtlLogin.Align:= TAlignlayout.None;
      rtlmyVersion.Align:= TAlignlayout.Center;
      rtlmyVersion.Align:= TAlignlayout.None;
    end;
  end;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  if TmClientCmd.IsFormOpen('fLogin')= True then begin
    fLogin.Close;
  end;
  fLogin:= TfLogin.Create(self);
  fLogin.rtlLogin.Parent:= lytModal;
  fLogin.rtlLogin.Align:= TAlignLayout.Center;
  fLogin.rtlLogin.Align:= TAlignLayout.None;
  fLogin.rtlmyVersion.Parent:= lytModal;
  fLogin.rtlmyVersion.Align:= TAlignLayout.Center;
  fLogin.rtlmyVersion.Align:= TAlignLayout.None;
  fLogin.edtUsername.SetFocus;
end;

procedure TfMain.pclMainBeforeClosePage(Sender: TObject; APageIndex: Integer;
  var ACloseAction: TTMSFNCPageControlPageCloseAction);
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    if TmClientCmd.IsFormOpen('fUserRegisterInput')= True then begin
      if APageIndex=
        (fUserRegisterInput.lytUserRegisterInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fUserRegisterInput.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCountryInput')= True then begin
      if APageIndex=
        (fCountryInput.lytCountryInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCountryInput.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fStateInput')= True then begin
      if APageIndex= (fStateInput.lytStateInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fStateInput.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCityInput')= True then begin
      if APageIndex= (fCityInput.lytCityInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCityInput.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCurrencyInput')= True then begin
      if APageIndex= (fCurrencyInput.lytCurrencyInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCurrencyInput.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fUserRegister')= True then begin
      if APageIndex= (fUserRegister.lytUserRegister.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fUserRegister.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCountry')= True then begin
      if APageIndex= (fCountry.lytCountry.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCountry.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fState')= True then begin
      if APageIndex= (fState.lytState.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fState.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCity')= True then begin
      if APageIndex= (fCity.lytCity.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCity.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fCurrency')= True then begin
      if APageIndex= (fCurrency.lytCurrency.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fCurrency.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

    if TmClientCmd.IsFormOpen('fPrintReport')= True then begin
      if APageIndex= (fPrintReport.lytPrintReport.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex then begin
        fPrintReport.Close;
        ACloseAction:= TTMSFNCPageControlPageCloseAction.ttcaFree;
      end;
    end;

  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfMain.vsbMenuBodyMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
const
  ScrollStep= 22;
var
  NewY: Single;
begin
  NewY:= vsbMenuBody.ViewportPosition.Y;
  if WheelDelta> 0 then begin
    NewY:= NewY - ScrollStep;
  end else begin
    NewY:= NewY + ScrollStep;
  end;
  vsbMenuBody.ViewportPosition:= PointF(vsbMenuBody.ViewportPosition.X, NewY);
  Handled:= True;
end;

procedure TfMain.rtlMenuBackgroundClick(Sender: TObject);
begin
  if lytMenuBackground.Visible= True then begin
    lytMenuBackground.SendToBack;
    lytMenuBackground.Visible:= False;
    lytMenuBackground.Enabled:= False;
    btnMenu.Parent:= lytMenuTab;
    btnMenu.SetFocus;
  end;
end;

end.
