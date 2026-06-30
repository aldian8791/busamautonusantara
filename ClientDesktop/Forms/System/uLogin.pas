unit uLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, System.JSON, System.Generics.Collections, System.NetEncoding,
  FMX.Controls.Presentation, FMX.DialogService, FMX.ListBox, FMX.Edit, FMX.Forms,
  (*DBAware*)Uni, Data.DB, DBAccess(*DBAware*), FMX.StdCtrls, FMX.Ani, FMX.Types,
  (*DBAware*)Data.Bind.Components, Data.Bind.DBScope(*DBAware*), VirtualTable,
  (*Adapter*)FMX.TMSFNCCustomComponent, FMX.TMSFNCDataGridDatabaseAdapter(*Adapter*),
  FMX.Graphics, FMX.Controls, FMX.Effects, FMX.Layouts, FMX.Objects, FMX.Dialogs,
  FMX.Styles, FMX.TMSFNCEdit, FMX.TMSFNCButton, FMX.TMSFNCDataGrid, System.Rtti,
  FMX.TMSFNCDataGridRenderer, FMX.TMSFNCGraphicsTypes, FMX.TMSFNCCustomControl,
  FMX.TMSFNCDataGridCell, FMX.TMSFNCDataGridBase, FMX.TMSFNCDataGridCore,
  FMX.TMSFNCDataGridData, FMX.TMSFNCGraphics, FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.wwComboEdit, FMX.wwLookupComboEdit, FMX.wwEdit, FMX.wwDataGrid;

type
  TfLogin = class(TForm)
    rtlLogin: TRectangle;
    sdeLogin: TShadowEffect;
    edtUsername: TEdit;
    edtPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    imgCompany: TImage;
    lblCompany: TLabel;
    Label4: TLabel;
    ShadowEffect1: TShadowEffect;
    cmbOSTheme: TComboBox;
    btnPassword: TPasswordEditButton;
    fanimgComp: TFloatAnimation;
    ShadowEffect2: TShadowEffect;
    rtlmyVersion: TRectangle;
    lytmyVersion: TLayout;
    btnClose: TTMSFNCButton;
    btnLogin: TTMSFNCButton;
    grdmyVersion: TTMSFNCDataGrid;
    linLogin: TLine;
    Label3: TLabel;
    lceFullName: TwwLookupComboEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cmbOSThemeChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure imgCompanyClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure grdmyVersionGetCellLayout(Sender: TObject;
      ACell: TTMSFNCDataGridCell);
    procedure grdmyVersionGetCellData(Sender: TObject;
      ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
    procedure grdmyVersionGetInplaceEditorProperties(Sender: TObject;
      ACell: TTMSFNCDataGridCellCoord;
      AInplaceEditor: TTMSFNCDataGridInplaceEditor;
      AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
    procedure grdmyVersionEnter(Sender: TObject);
    procedure adtReadmyVersionSortData(Sender: TObject);
    procedure rtlLoginResize(Sender: TObject);
    procedure cmbOSThemeClosePopup(Sender: TObject);
    procedure edtUsernameEnter(Sender: TObject);
    procedure lceFullNameClosePopup(Sender: TObject);
    procedure lceFullNameEnter(Sender: TObject);
    procedure edtUsernameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtPasswordKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure lceFullNameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
  private
    procedure Loadgrid;
    procedure GetmyData;
    procedure myData;
  public
  end;

var
  fLogin: TfLogin;

implementation

{$R *.fmx}

uses uClientCmd, uClientSet, uClientOS, uBusamAutoNusantara, cLogin,
  uClientFrmCursor, cOptions;

var
  adtReadmyVersion: TTMSFNCDataGridDatabaseAdapter;
  dtsReadmyVersion: TUniDatasource;
  bdsFullName: TBindSourceDB;
  vtbGetmyriften, vtbFullName: TVirtualTable;
  srmDefLogo22, srmDefLogo75: TMemoryStream;
  frmWidth, frmHeight: single;

procedure TfLogin.btnCloseClick(Sender: TObject);
begin
  if rtlmyVersion.Visible= True then begin
    rtlmyVersion.Visible:= False;
  end;
  if rtlLogin.Visible= False then begin
    rtlLogin.Visible:= True;
    with grdmyVersion do begin
      if RowCount> 1 then begin
        FocusedCell:= MakeCell(FocusedCell.Column, FocusedCell.Row);
      end;
    end;
  end;
  rtlLogin.BringToFront;
  edtUsername.SetFocus;
end;

procedure TfLogin.btnLoginClick(Sender: TObject);
var
  JSONAppVersion: string;
  ArrAppVersion: TJSONArray;
  ObjAppVersion: TJSONObject;
begin
  JSONAppVersion:= '';
  JSONAppVersion:= TcOptions.GetOptionsmyVersion;
  ArrAppVersion:= TJSONObject.ParseJSONValue(JSONAppVersion) as TJSONArray;
  try
    if ArrAppVersion.Count> 0 then begin
      ObjAppVersion:= ArrAppVersion.Items[0] as TJSONObject;
      if ObjAppVersion.GetValue<integer>('otvalue')> gversion then begin
        TDialogService.MessageDialog('Sorry, your version is outdated. Please '+
          'download and install latest patch (Version: '+
          ObjAppVersion.GetValue<string>('otvalue')+') at https://10.1.1.88',
          TMsgDlgType.mtError, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
        Exit;
      end;
    end;
  finally
    FreeAndNil(ArrAppVersion);
  end;
  if edtUsername.Text= '' then begin
    TDialogService.MessageDialog('Please input your Username.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    edtUsername.SetFocus;
    Exit;
  end;
  if edtPassword.Text= '' then begin
    TDialogService.MessageDialog('Please input your Password.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    edtPassword.SetFocus;
    Exit;
  end;
  if lceFullName.Text= '' then begin
    TDialogService.MessageDialog('Please select your Fullname.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    lceFullName.DropDown;
    lceFullName.SetFocus;
    Exit;
  end;
  if lceFullName.Text<> '' then begin
    if edtUsername.Text= 'aldian' then begin
      if lceFullName.Text= 'programmer' then begin
        gusername:= 'aldian';
        GetmyData;
      end else if lceFullName.Text<> 'programmer' then begin
        TDialogService.MessageDialog('Your Fullname is incorrect. Please change '+
          'it to match your username or retype your username correctly.',
          TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
        lceFullName.SetFocus;
        Exit;
      end;
    end else if edtUsername.Text<> 'aldian' then begin
      if gusername<> edtUsername.Text.Trim then begin
        TDialogService.MessageDialog('Your Fullname is incorrect. Please change '+
          'it to match your username or retype your username correctly.',
          TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
        lceFullName.DropDown;
        lceFullName.SetFocus;
        Exit;
      end else if gusername= edtUsername.Text.Trim then begin
        GetmyData;
      end;
    end;
  end;
end;

procedure TfLogin.GetmyData;
var
  ArrGetUserData: TJSONArray;
  ObjGetUserData: TJSONObject;
  JSONGetUserData, myDecrypted: string;
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  JSONGetUserData:= '';
  JSONGetUserData:= TcLogin.ReadUserData(gusername);
  ArrGetUserData:= TJSONObject.ParseJSONValue(JSONGetUserData) as TJSONArray;
  try
    if ArrGetUserData.Count> 0 then begin
      ObjGetUserData:= ArrGetUserData.Items[0] as TJSONObject;
      gusertype:= ObjGetUserData.GetValue<smallint>('urtype');
      gpassword:= ObjGetUserData.GetValue<string>('urpassword');
      gfullname:= ObjGetUserData.GetValue<string>('urfullname');
      gjbcode:= ObjGetUserData.GetValue<string>('jbcode');
      gdmcode:= ObjGetUserData.GetValue<string>('dmcode');
      gkick:= ObjGetUserData.GetValue<boolean>('kick');
      fMain.myCodec.DecryptString(myDecrypted, gpassword, TEncoding.UTF8);
      if gusertype<> 2 then begin
        if gkick= True then begin
          TDialogService.MessageDialog('Sorry, you are temporarily banned from '+
            'this system. Please contact the relevant authorities.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0,
            nil);
          Exit;
        end else begin
          if myDecrypted<> edtPassword.Text.Trim then begin
            TDialogService.MessageDialog('Your Password is incorrect. Please '+
              'change it to match your username or retype your username '+
              'correctly.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose],
              TMsgDlgBtn.mbClose, 0, nil);
            edtPassword.SetFocus;
            Exit;
          end else if myDecrypted= edtPassword.Text.Trim then begin
            myData;
          end;
        end;
      end else if gusertype= 2 then begin
        if myDecrypted<> edtPassword.Text.Trim then begin
          TDialogService.MessageDialog('Your Password is incorrect. Please '+
            'change it to match your username or retype your username '+
            'correctly.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose],
            TMsgDlgBtn.mbClose, 0, nil);
          edtPassword.SetFocus;
          Exit;
        end else if myDecrypted= edtPassword.Text.Trim then begin
          myData;
        end;
      end;
    end;
  finally
    FreeAndNil(ArrGetUserData);
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfLogin.myData;
begin
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
  fMain.lblUsername.Text:= gusername.Trim;
  fMain.lblDate.Text:= DateToStr(gdateserver);
  fMain.lblTime.Text:= TimeToStr(gtimeserver);
  fMain.tmrServer.Enabled:= True;
  fMain.lblDBName.Text:= gdbname.ToUpper.Trim;
  fMain.lblServerName.Text:= gservername.Trim;
  fMain.imgCompany.Bitmap.LoadFromStream(gmrsLogo22);
  fMain.btnMenu.Parent:= fMain.lytMenuTab;
  if gusertype= 2 then begin
    fMain.btnNumberMap.Visible:= True;
  end;
  fMain.lytMenuBackground.Visible:= False;
  fMain.lytMain.Visible:= True;
  Self.Close;
end;

procedure TfLogin.cmbOSThemeChange(Sender: TObject);
begin
  if cmbOSTheme.ItemIndex= 0 then begin
    if TmClientOS.OSDarkMode= False then begin
      with TStyleManager do begin
        {$IF DEFINED(MSWINDOWS)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Win.style'));
        TmClientOS.SetDarkModeTitleBar(fMain, False);
        {$ENDIF}
        {$IF DEFINED(LINUX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Linux.style'));
        {$ENDIF}
        {$IF DEFINED(OSX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Mac.style'));
        {$ENDIF}
        {$IF DEFINED(IOS64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_iOS.style'));
        {$ENDIF}
        {$IF DEFINED(ANDROID)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Android.style'));
        {$ENDIF}
      end;
      themedark:= False;
    end else begin
      with TStyleManager do begin
        {$IF DEFINED(MSWINDOWS)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Win.style'));
        TmClientOS.SetDarkModeTitleBar(fMain, True);
        {$ENDIF}
        {$IF DEFINED(LINUX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Linux.style'));
        {$ENDIF}
        {$IF DEFINED(OSX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Mac.style'));
        {$ENDIF}
        {$IF DEFINED(IOS64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_iOS.style'));
        {$ENDIF}
        {$IF DEFINED(ANDROID)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Android.style'));
        {$ENDIF}
      end;
      themedark:= True;
    end;
    curtheme:= 0;
  end;
  if cmbOSTheme.ItemIndex= 1 then begin
    with TStyleManager do begin
      {$IF DEFINED(MSWINDOWS)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Win.style'));
      TmClientOS.SetDarkModeTitleBar(fMain, False);
      {$ENDIF}
      {$IF DEFINED(LINUX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Linux.style'));
      {$ENDIF}
      {$IF DEFINED(OSX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Mac.style'));
      {$ENDIF}
      {$IF DEFINED(IOS64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_iOS.style'));
      {$ENDIF}
      {$IF DEFINED(ANDROID)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Android.style'));
      {$ENDIF}
    end;
    themedark:= False;
    curtheme:= 1;
  end;
  if cmbOSTheme.ItemIndex= 2 then begin
    with TStyleManager do begin
      {$IF DEFINED(MSWINDOWS)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Win.style'));
      TmClientOS.SetDarkModeTitleBar(fMain, True);
      {$ENDIF}
      {$IF DEFINED(LINUX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Linux.style'));
      {$ENDIF}
      {$IF DEFINED(OSX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Mac.style'));
      {$ENDIF}
      {$IF DEFINED(IOS64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_iOS.style'));
      {$ENDIF}
      {$IF DEFINED(ANDROID)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Android.style'));
      {$ENDIF}
    end;
    themedark:= True;
    curtheme:= 2;
  end;
  with TmClientCmd do begin
    GridAppearance(grdmyVersion);
    FillTMSColor(grdmyVersion.Fill, False, False);
    FillBrushColor(rtlLogin.Fill, False, False, False);
    FillBrushColor(rtlmyVersion.Fill, False, False, False);
    FillBrushColor(fMain.Fill, False, False, False);
    FillBrushColor(fMain.rtlMenu.Fill, False, False, False);
  end;
end;

procedure TfLogin.cmbOSThemeClosePopup(Sender: TObject);
begin
  edtUsername.SetFocus;
end;

procedure TfLogin.edtPasswordKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    lceFullName.SetFocus;
  end;
end;

procedure TfLogin.edtUsernameEnter(Sender: TObject);
var
  JSONFullName: string;
begin
  JSONFullName:= TcLogin.GetFullName;
  vtbFullName.DisableControls;
  try
    with vtbFullName do begin
      Active:= False;
      IndexFieldNames:= '';
      DeleteFields;
      AddField('urfullname', ftString, 50, True);
      AddField('urname', ftString, 20, True);
      IndexFieldNames:= 'urfullname ASC';
      CachedUpdates:= False;
      Active:= True;
      TmClientCmd.JSONToVirtualTable(JSONFullName, vtbFullName);
      First;
    end;
    with lceFullName do begin
      bdsFullName.DataSet:= vtbFullName;
      LookupSource:= bdsFullName;
      LookupField:= 'urname';
      DropDownCount:= 2;
      with DropDownGrid do begin
        Columns[0].Width:= trunc(lceFullName.Width)- 5;
        Columns[0].Title:= 'Full Name';
        Columns[1].Visible:= False;
        KeyOptions:= [];
        Options:= [dgColumnResize, dgTabs, dgRowSelect, dgConfirmDelete,
          dgCancelOnExit, dgWordWrap, dgAlternatingRow];
        OverrideStyleSettings.Title.FontStyle:= [TFontStyle.fsBold];
      end;
    end;
  finally
    vtbFullName.EnableControls;
  end;
end;

procedure TfLogin.edtUsernameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtPassword.SetFocus;
  end;
end;

procedure TfLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfLogin.FormCreate(Sender: TObject);
var
  JSONGetmyriften, lostmyriften, myDecrypted, B64: string;
  ArrGetmyriften: TJSONArray;
  ObjGetmyriften: TJSONObject;
  Bytes: TBytes;
  i: integer;
begin
  fMain.SetrtlModal;
  frmWidth:= rtlLogin.Width;
  frmHeight:= rtlLogin.Height;
  btnLogin.Enabled:= False;
  btnLogin.BitmapName:= 'login_disable';
  btnLogin.Opacity:= btnopacity;
  TmClientSet.EnableDragResize(rtlLogin);//move and resize control
  vtbGetmyriften:= TVirtualTable.Create(self);
  vtbFullName:= TVirtualTable.Create(self);
  dtsReadmyVersion:= TUniDataSource.Create(self);
  adtReadmyVersion:= TTMSFNCDataGridDatabaseAdapter.Create(self);
  bdsFullName:= TBindSourceDB.Create(Self);
  srmDefLogo22:= TMemoryStream.Create;
  srmDefLogo75:= TMemoryStream.Create;
  rtlLogin.Align:= TAlignLayout.None;
  rtlLogin.Stroke.Color:= strkcolor;
  rtlLogin.Stroke.Thickness:= strkthickness;
  linLogin.Stroke.Color:= strkcolor;
  linLogin.Stroke.Thickness:= strkthickness;
  with sdeLogin do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  with fanimgComp do begin
    Duration:= 10;
    Loop:= True;
    PropertyName:= 'RotationAngle';
    StopValue:= 360;
    Trigger:= 'IsMouseOver=true';
  end;
  with rtlmyVersion do begin
    Stroke.Color:= strkcolor;
    Stroke.Thickness:= strkthickness;
    Visible:= False;
  end;
  edtUsername.MaxLength:= 20;
  edtUsername.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtUsername.CharCase:= TEditCharCase.ecLowerCase;
  edtPassword.MaxLength:= 20;
  edtPassword.Password:= True;
  lceFullName.MaxLength:= 50;
  lceFullName.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if fMain.ostheme= 0 then begin
    if themedark= False then begin
      with TStyleManager do begin
        {$IF DEFINED(MSWINDOWS)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Win.style'));
        TmClientOS.SetDarkModeTitleBar(fMain, False);
        {$ENDIF}
        {$IF DEFINED(LINUX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Linux.style'));
        {$ENDIF}
        {$IF DEFINED(OSX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Mac.style'));
        {$ENDIF}
        {$IF DEFINED(IOS64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_iOS.style'));
        {$ENDIF}
        {$IF DEFINED(ANDROID)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Light_Android.style'));
        {$ENDIF}
      end;
    end else begin
      with TStyleManager do begin
        {$IF DEFINED(MSWINDOWS)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Win.style'));
        TmClientOS.SetDarkModeTitleBar(fMain, True);
        {$ENDIF}
        {$IF DEFINED(LINUX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Linux.style'));
        {$ENDIF}
        {$IF DEFINED(OSX64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Mac.style'));
        {$ENDIF}
        {$IF DEFINED(IOS64)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_iOS.style'));
        {$ENDIF}
        {$IF DEFINED(ANDROID)}
        SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
          'Dark_Android.style'));
        {$ENDIF}
      end;
    end;
    cmbOSTheme.ItemIndex:= 0;
  end;
  if fMain.ostheme= 1 then begin
    with TStyleManager do begin
      {$IF DEFINED(MSWINDOWS)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Win.style'));
      TmClientOS.SetDarkModeTitleBar(fMain, False);
      {$ENDIF}
      {$IF DEFINED(LINUX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Linux.style'));
      {$ENDIF}
      {$IF DEFINED(OSX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Mac.style'));
      {$ENDIF}
      {$IF DEFINED(IOS64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_iOS.style'));
      {$ENDIF}
      {$IF DEFINED(ANDROID)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Light_Android.style'));
      {$ENDIF}
    end;
    cmbOSTheme.ItemIndex:= 1;
  end;
  if fMain.ostheme= 2 then begin
    with TStyleManager do begin
      {$IF DEFINED(MSWINDOWS)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Win.style'));
      TmClientOS.SetDarkModeTitleBar(fMain, True);
      {$ENDIF}
      {$IF DEFINED(LINUX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Linux.style'));
      {$ENDIF}
      {$IF DEFINED(OSX64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Mac.style'));
      {$ENDIF}
      {$IF DEFINED(IOS64)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_iOS.style'));
      {$ENDIF}
      {$IF DEFINED(ANDROID)}
      SetStyleFromFile(System.IOUtils.TPath.Combine(appfolder,
        'Dark_Android.style'));
      {$ENDIF}
    end;
    cmbOSTheme.ItemIndex:= 2;
  end;
  JSONGetmyriften:= '';
  JSONGetmyriften:= TmClientSet.ComparemyVersion(lostmyriften);
  if lostmyriften<> '' then begin
    TDialogService.MessageDialog(lostmyriften, TMsgDlgType.mtError,
      [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    Application.Terminate;
  end else if lostmyriften= '' then begin
    ArrGetmyriften:= TJSONObject.ParseJSONValue(JSONGetmyriften) as TJSONArray;
    try
      if ArrGetmyriften.Count> 0 then begin
        ObjGetmyriften:= ArrGetmyriften.Items[0] as TJSONObject;
        gversion:= ObjGetmyriften.GetValue<integer>('myversionid');
        gversionname:= ObjGetmyriften.GetValue<string>('myversionname');
      end;
    finally
      FreeAndNil(ArrGetmyriften);
    end;

    JSONGetmyriften:= '';
    JSONGetmyriften:= TmClientSet.GetdbloginByUsername('myriften');
    ArrGetmyriften:= TJSONObject.ParseJSONValue(JSONGetmyriften) as TJSONArray;
    try
      if ArrGetmyriften.Count> 0 then begin
        ObjGetmyriften:= ArrGetmyriften.Items[0] as TJSONObject;
        gdbusername:= ObjGetmyriften.GetValue<string>('usernames');
        fMain.myCodec.DecryptString(myDecrypted,
          ObjGetmyriften.GetValue<string>('passwords'), TEncoding.UTF8);
        gdbpassword:= myDecrypted.Trim;
        srmDefLogo22.Clear;
        srmDefLogo22.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('logo22');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        srmDefLogo22.WriteBuffer(Bytes[0], Length(Bytes));
        srmDefLogo22.Position:= 0;
        srmDefLogo75.Clear;
        srmDefLogo75.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('logo75');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        srmDefLogo75.WriteBuffer(Bytes[0], Length(Bytes));
        srmDefLogo75.Position:= 0;
        imgCompany.Bitmap.LoadFromStream(srmDefLogo75);
        mrsIcon.Clear;
        mrsIcon.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('icon');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        mrsIcon.WriteBuffer(Bytes[0], Length(Bytes));
        mrsIcon.Position:= 0;
        {$IF DEFINED(MSWINDOWS)}
        TmClientOS.ChangeFormIcon(fMain);
        {$ENDIF}
        gcolorpoint0:= ObjGetmyriften.GetValue<largeint>('colorpoint0');
        gcolorpoint1:= ObjGetmyriften.GetValue<largeint>('colorpoint1');
      end;
    finally
      FreeAndNil(ArrGetmyriften);
    end;

    JSONGetmyriften:= '';
    JSONGetmyriften:= TmClientSet.GetdbmasterByServername('Balikpapan');
    ArrGetmyriften:= TJSONObject.ParseJSONValue(JSONGetmyriften) as TJSONArray;
    try
      if ArrGetmyriften.Count> 0 then begin
        ObjGetmyriften:= ArrGetmyriften.Items[0] as TJSONObject;
        gservername:= ObjGetmyriften.GetValue<string>('servername');
        gserverip:= ObjGetmyriften.GetValue<string>('serverip');
        gserverloc:= ObjGetmyriften.GetValue<string>('location');
      end;
    finally
      FreeAndNil(ArrGetmyriften);
    end;

    JSONGetmyriften:= '';
    JSONGetmyriften:= TmClientSet.GetdbdetailBydbname('busamautonusantara');
    ArrGetmyriften:= TJSONObject.ParseJSONValue(JSONGetmyriften) as TJSONArray;
    try
      if ArrGetmyriften.Count> 0 then begin
        ObjGetmyriften:= ArrGetmyriften.Items[0] as TJSONObject;
        gheadcompany:= ObjGetmyriften.GetValue<boolean>('headcompany');
        gdbname:= ObjGetmyriften.GetValue<string>('dbname');
        gdbport:= ObjGetmyriften.GetValue<smallint>('myport');
        gcomp:= ObjGetmyriften.GetValue<string>('company');
        lblCompany.Text:= ObjGetmyriften.GetValue<string>('company');
        fMain.Caption:= lblCompany.Text;
        gmrsLogo22.Clear;
        gmrsLogo22.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('logo22');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        gmrsLogo22.WriteBuffer(Bytes[0], Length(Bytes));
        gmrsLogo22.Position:= 0;
        gmrsLogo75.Clear;
        gmrsLogo75.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('logo75');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        gmrsLogo75.WriteBuffer(Bytes[0], Length(Bytes));
        gmrsLogo75.Position:= 0;
        imgCompany.Bitmap.LoadFromStream(gmrsLogo75);
        mrsIcon.Clear;
        mrsIcon.Position:= 0;
        B64:= ObjGetmyriften.GetValue<string>('icon');
        Bytes:= TNetEncoding.Base64.DecodeStringToBytes(B64);
        mrsIcon.WriteBuffer(Bytes[0], Length(Bytes));
        mrsIcon.Position:= 0;
        {$IF DEFINED(MSWINDOWS)}
        TmClientOS.ChangeFormIcon(fMain);
        {$ENDIF}
        gcolorpoint0:= ObjGetmyriften.GetValue<largeint>('colorpoint0');
        gcolorpoint1:= ObjGetmyriften.GetValue<largeint>('colorpoint1');

        with fMain.rtlMain.Fill do begin
          with Gradient do begin
            Points.Clear;
            i:= 0;
            while i<= 1 do begin
              Points.Add;
              inc(i);
            end;
            Points.Points[0].Offset:= 0.000000000000000000;
            Points.Points[1].Color:= gcolorpoint1;
            Points.Points[0].Color:= gcolorpoint0;
            Points.Points[1].Offset:= 1.000000000000000000;
            StartPosition.Y:= 0.500000000000000000;
            StopPosition.X:= 1.000000000000000000;
            StopPosition.Y:= 0.500000000000000000;
          end;
          Kind:= TBrushKind.Gradient;
        end;

      end;
    finally
      FreeAndNil(ArrGetmyriften);
    end;

    JSONGetmyriften:= '';
    JSONGetmyriften:= TmClientSet.GetbusinessBydbnameLoc(gdbname, gserverloc);
    ArrGetmyriften:= TJSONObject.ParseJSONValue(JSONGetmyriften) as TJSONArray;
    try
      if ArrGetmyriften.Count> 0 then begin
        ObjGetmyriften:= ArrGetmyriften.Items[0] as TJSONObject;
        gcompaddress:= ObjGetmyriften.GetValue<string>('address');
      end;
    finally
      FreeAndNil(ArrGetmyriften);
    end;

    JSONGetmyriften:= '';
    JSONGetmyriften:= TmClientSet.GetmyVersion;
    with vtbGetmyriften do begin
      DisableControls;
      try
        Active:= False;
        IndexFieldNames:= '';
        DeleteFields;
        AddField('myversionid', ftInteger, 0, True);
        AddField('myversionname', ftString, 30, True);
        AddField('description', ftString, 255, False);
        IndexFieldNames:= 'myversionid DESC';
        CachedUpdates:= False;
        Active:= True;
        TmClientCmd.JSONToVirtualTable(JSONGetmyriften, vtbGetmyriften);
      finally
        EnableControls;
      end;
    end;
    dtsReadmyVersion.DataSet:= vtbGetmyriften;
    with adtReadmyVersion do begin
      OnSortData:= adtReadmyVersionSortData;
      LoadMode:= almBuffered;
      DataSource:= dtsReadmyVersion;
      Columns.Clear;
      AddAllFields;
      Active:= True;
    end;
    with grdmyVersion do begin
      AdaptToStyle:= True;
      (*Options.Keyboard.TabKeyDirectEdit:= True; //For editing
      Options.Editing.DirectDropDown:= True; //For editing
      Options.Mouse.DirectEdit:= True; //For editing*)
      if RowCount> 1 then begin
      //For browsing
        Options.Sorting.Enabled:= True;
      end;
      RowCount:= 0;
      ColumnCount:= 0;
      TmClientCmd.GridAppearance(grdmyVersion);
    end;
    Loadgrid;
    with grdmyVersion do begin
      if (RowCount)> 1 then begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
    with TmClientCmd do begin
      FillTMSColor(grdmyVersion.Fill, False, False);
      FillBrushColor(rtlLogin.Fill, False, False, False);
      FillBrushColor(rtlmyVersion.Fill, False, False, False);
      FillBrushColor(fMain.Fill, False, False, False);
      FillBrushColor(fMain.rtlMenu.Fill, False, True, True);
    end;
  end;
end;

procedure TfLogin.Loadgrid;
begin
  with grdmyVersion do begin
    Columns.Clear;
    ColumnCount:= adtReadmyVersion.Columns.Count;
    Adapter:= adtReadmyVersion;
    Columns[0].Width:= 0;
    Columns[0].Visible:= False;
    Columns[1].Width:= 60;
    Columns[2].Width:= 500;
    AutoSizeRows; //For grid version
  end;
end;

procedure TfLogin.rtlLoginResize(Sender: TObject);
begin
  if (frmWidth> 0) or (frmHeight> 0) then begin
  //do not resize rectangle
    with rtlLogin do begin
      if (Width< frmWidth) or (Width> frmWidth) then begin
        Width:= frmWidth;
      end;
      if (Height< frmHeight) or (Height> frmHeight) then begin
        Height:= frmHeight;
      end;
    end;
  end;
end;

procedure TfLogin.adtReadmyVersionSortData(Sender: TObject);
begin
  TmClientCmd.AdapterSorting(grdmyVersion, adtReadmyVersion);
end;

procedure TfLogin.FormDestroy(Sender: TObject);
begin
  FreeAndNil(srmDefLogo75);
  FreeAndNil(srmDefLogo22);
  FreeAndNil(vtbGetmyriften);
  FreeAndNil(vtbFullName);
  FreeAndNil(adtReadmyVersion);
  FreeAndNil(dtsReadmyVersion);
  FreeAndNil(bdsFullName);
  FreeAndNil(fMain.lytModal);
  fMain.lytMain.Enabled:= True;
  fMain.btnMenu.SetFocus;
  fLogin:= nil;
end;

procedure TfLogin.grdmyVersionEnter(Sender: TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    //for bug tmsfncdatagrid which lost focusing cell after tab from button
    begin
      with grdmyVersion do begin
        if RowCount> 1 then begin
          SelectCell(MakeCell(FocusedCell.Column, FocusedCell.Row));
        end;
        SetFocus;
      end;
    end);
end;

procedure TfLogin.grdmyVersionGetCellData(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
begin
  if ACell.Row= 0 then begin
    case ACell.Column of
      0: AData:= 'Release';
      1: AData:= 'Version';
      2: AData:= 'Description';
    end;
  end;
end;

procedure TfLogin.grdmyVersionGetCellLayout(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    with ACell.Layout do begin
      case ACell.Column of
        0: TextAlign:= TTMSFNCGraphicsTextAlign.gtaTrailing;
        1: TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;
        2: begin
          TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
          WordWrapping:= True;
        end;
      end;
    end;
  end;
end;

procedure TfLogin.grdmyVersionGetInplaceEditorProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; AInplaceEditor: TTMSFNCDataGridInplaceEditor;
  AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
begin
  if ACell.Row> 0 then begin
    with AInplaceEditor do begin
      AsEdit.ReadOnly:= True;
      if themedark= True then begin
        AsEdit.FontColor:= TAlphaColors.White;
      end else begin
        AsEdit.FontColor:= TAlphaColors.Black;
      end;
      case ACell.Column of
        2: AsEdit.TextSettings.WordWrap:= True;
      end;
    end;
  end;
end;

procedure TfLogin.imgCompanyClick(Sender: TObject);
begin
  if rtlLogin.Visible= True then begin
    rtlLogin.Visible:= False;
  end;
  with rtlmyVersion do begin
    Position.X:= rtlLogin.Position.X;
    Position.Y:= rtlLogin.Position.Y;
    if Visible= False then begin
      Visible:= True;
    end;
    BringToFront;
  end;
  with grdmyVersion do begin
    if (RowCount)> 1 then begin
      SelectCell(MakeCell(FocusedCell.Column, FocusedCell.Row));
    end;
  end;
end;

procedure TfLogin.lceFullNameClosePopup(Sender: TObject);
begin
  gusername:= lceFullName.LookupValue.Trim;
end;

procedure TfLogin.lceFullNameEnter(Sender: TObject);
begin
  if (edtUsername.Text<> '') and (edtPassword.Text<> '') then begin
    lceFullName.DropDown;
    btnLogin.Enabled:= True;
    btnLogin.BitmapName:= 'login_enable';
  end;
end;

procedure TfLogin.lceFullNameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnLogin.SetFocus;
  end;
end;

end.
