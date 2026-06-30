unit uOptions;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.JSON, System.Generics.Collections, FMX.Controls.Presentation, FMX.Forms,
  (*DBAware*)Data.Bind.Components, Data.Bind.DBScope(*DBAware*), FMX.StdCtrls,
  (*VirtualTable*)Virtualtable, Data.DB(*VirtualTable*), FMX.Controls, FMX.Types,
  FMX.DialogService, FMX.Graphics, FMX.Layouts, FMX.Effects, FMX.Objects,
  FMX.Dialogs, FMX.Edit, FMX.TMSFNCButton, FMX.TMSFNCEdit, FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCPageControl, FMX.TMSFNCCustomControl, FMX.TMSFNCTabSet,
  FMX.TMSFNCHTMLImageContainer, FMX.TMSFNCTrackBar, FMX.TMSFNCSpinEdit,
  FMX.wwDataGrid, FMX.wwEdit, FMX.wwComboEdit, FMX.wwLookupComboEdit;

type
  TfOptions = class(TForm)
    rtlOptions: TRectangle;
    lytHeader: TLayout;
    btnClose: TTMSFNCButton;
    Label1: TLabel;
    lytAction: TLayout;
    btnSave: TTMSFNCButton;
    pclOptions: TTMSFNCPageControl;
    tbsGeneral: TTMSFNCPageControlContainer;
    sdeOptions: TShadowEffect;
    Label2: TLabel;
    Label3: TLabel;
    edtVATPercent: TTMSFNCEdit;
    Label4: TLabel;
    chkMaintenance: TCheckBox;
    Label5: TLabel;
    edtMessage: TEdit;
    lytVersion: TLayout;
    Label6: TLabel;
    btnCancel: TTMSFNCButton;
    Label7: TLabel;
    spePrecision: TTMSFNCSpinEdit;
    edtVersion: TTMSFNCEdit;
    lceCurrency: TwwLookupComboEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rtlOptionsResize(Sender: TObject);
    procedure chkMaintenanceKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtVATPercentKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure btnCancelClick(Sender: TObject);
    procedure spePrecisionEnter(Sender: TObject);
    procedure edtMessageKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtVersionKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure lceCurrencyKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure btnSaveClick(Sender: TObject);
    procedure lceCurrencyEnter(Sender: TObject);
  private
    procedure DisableWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure spePrecisionEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure LoadDataCurrency;
    procedure LoadData;
    procedure SaveEdit;
    function ValidatingData: boolean;
  public
    { Public declarations }
  end;

var
  fOptions: TfOptions;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientSet, uClientCmd, cOptions, uClientFrmCursor;

var
  frmWidth, frmHeight: single;
  bdsCurrency: TBindSourceDB;
  vtbCurrency: TVirtualtable;
  oldVersion: integer;
  versionid, messageid, currencyid, maintenanceid, vatpercentid, precisionid,
  oldMessage, oldCurrency: string;
  oldMaintenance: boolean;
  oldVATPercent: single;
  oldPrecision: shortint;

procedure TfOptions.LoadDataCurrency;
var
  JSONCurrecy: string;
begin
  JSONCurrecy:= TcOptions.GetCurrency;
  vtbCurrency.DisableControls;
  try
    with vtbCurrency do begin
      Active:= False;
      IndexFieldNames:= '';
      DeleteFields;
      AddField('cycode', ftString, 3, True);
      AddField('description', ftString, 50, True);
      IndexFieldNames:= 'description ASC';
      CachedUpdates:= False;
      Active:= True;
      TmClientCmd.JSONToVirtualTable(JSONCurrecy, vtbCurrency);
    end;
    with lceCurrency do begin
      bdsCurrency.DataSet:= vtbCurrency;
      LookupSource:= bdsCurrency;
      LookupField:= 'cycode';
      DropDownCount:= 6;
      Style:= wwcbsDropDownList;
      with DropDownGrid do begin
        Columns[0].Width:= 40;
        Columns[0].Title:= 'Code';
        Columns[1].Width:= 130;
        Columns[1].Title:= 'Description';
        KeyOptions:= [];
        Options:= [dgColumnResize, dgTabs, dgRowSelect, dgConfirmDelete,
          dgCancelOnExit, dgWordWrap, dgAlternatingRow, dgTitles];
        OverrideStyleSettings.Title.FontStyle:= [TFontStyle.fsBold];
      end;
      LookupValue:= Text;
    end;
  finally
    vtbCurrency.EnableControls;
  end;
end;

procedure TfOptions.btnCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfOptions.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfOptions.btnSaveClick(Sender: TObject);
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
    if ValidatingData= True then begin
      SaveEdit;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

function TfOptions.ValidatingData: boolean;
begin
  if edtVersion.Text= '' then begin
    edtVersion.IntValue:= 0;
  end;
  if edtVATPercent.Text= '' then begin
    edtVATPercent.FloatValue:= 0;
  end;
  if spePrecision.Edit.Text= '' then begin
    spePrecision.Value:= 0;
  end;
  if lceCurrency.Text= '' then begin
    TDialogService.MessageDialog('The Currency is empty. Please select currency.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    lceCurrency.DropDown;
    lceCurrency.SetFocus;
    Exit(False);
  end;
  Result:= True;
end;

procedure TfOptions.SaveEdit;
var
  ArrEditData: TJSONArray;
  ObjEditData: TJSONObject;
  Response: string;
begin
  ArrEditData:= TJSONArray.Create;
  try
    if edtVersion.IntValue<> oldVersion then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', versionid);
      ObjEditData.AddPair('otvalue', edtVersion.IntValue);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    if edtMessage.Text<> oldMessage then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', messageid);
      ObjEditData.AddPair('otvalue', edtMessage.Text);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    if chkMaintenance.IsChecked<> oldMaintenance then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', maintenanceid);
      ObjEditData.AddPair('otvalue', chkMaintenance.IsChecked.ToString);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    if lceCurrency.Text<> oldCurrency then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', currencyid);
      ObjEditData.AddPair('otvalue', lceCurrency.Text);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    if edtVATPercent.FloatValue<> oldVATPercent then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', vatpercentid);
      ObjEditData.AddPair('otvalue', edtVATPercent.FloatValue);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    if spePrecision.Value<> oldPrecision then begin
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair('otcode', precisionid);
      ObjEditData.AddPair('otvalue', spePrecision.Edit.IntValue);
      ObjEditData.AddPair('edituser', gusername);
      ArrEditData.AddElement(ObjEditData);
    end;
    Response:= TcOptions.UpdateOptionsByCode(ArrEditData.ToJSON);//update database with response
  finally
    FreeAndNil(ArrEditData);
  end;
  ObjEditData:= TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    if ObjEditData.GetValue<boolean>('success')= True then begin
      TDialogService.MessageDialog(ObjEditData.GetValue<string>('message')+
        #13+ 'Affected: '+ ObjEditData.GetValue<smallint>('affected').ToString+
        ' row(s)', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbOK, 0, nil);
      gmaintenance:= chkMaintenance.IsChecked;
      fMain.lblMessage.Text:= edtMessage.Text.Trim;
    end;
  finally
    FreeAndNil(ObjEditData);
  end;
end;

procedure TfOptions.chkMaintenanceKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtMessage.SetFocus;
  end;
end;

procedure TfOptions.edtMessageKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    lceCurrency.SetFocus;
  end;
end;

procedure TfOptions.edtVATPercentKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    spePrecision.Edit.SetFocus;
  end;
end;

procedure TfOptions.edtVersionKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnSave.SetFocus;
  end;
end;

procedure TfOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfOptions.FormCreate(Sender: TObject);
var
  i: integer;
begin
  fMain.SetrtlModal;
  frmWidth:= rtlOptions.Width;
  frmHeight:= rtlOptions.Height;
  TmClientSet.EnableDragResize(rtlOptions);//move and resize control
  with rtlOptions do begin
    Align:= TAlignLayout.None;
    Stroke.Color:= strkcolor;
    Stroke.Thickness:= strkthickness;
    if themedark= True then begin
      Fill.Color:= darkcolor;
      Fill.Kind:= TBrushKind.Solid;
    end;
  end;
  with sdeOptions do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  if gusertype= 0 then begin
    lytVersion.Visible:= False;
    chkMaintenance.Enabled:= False;
    edtMessage.ReadOnly:= True;
  end else if gusertype= 1 then begin
    lytVersion.Visible:= False;
    chkMaintenance.Enabled:= True;
    edtMessage.ReadOnly:= False;
  end else if gusertype= 2 then begin
    lytVersion.Visible:= True;
    chkMaintenance.Enabled:= True;
    edtMessage.ReadOnly:= False;
  end;
  i:= 0;
  while i< pclOptions.Pages.Count do begin
    pclOptions.Pages[i].UseDefaultAppearance:= False;
    TmClientCmd.TMSTabColor(pclOptions.Pages[i]);
    if themedark= True then begin
      pclOptions.PageContainers[i].Fill.Color:= darkcolor;
      pclOptions.PageContainers[i].Fill.Kind:= gfkSolid;
    end;
    pclOptions.PageContainers[i].Stroke.Width:= strkthickness;
    inc(i);
  end;
  edtVATPercent.EditType:= etSignedFloat;
  edtVATPercent.Precision:= 2;
  edtVATPercent.TextSettings.HorzAlign:= TTextAlign.Trailing;
  spePrecision.AdaptToStyle:= True;
  spePrecision.EditFieldPrecision:= 0;
  spePrecision.Max:= 6;
  spePrecision.Min:= 0;
  spePrecision.OnMouseWheel:= DisableWheel;
  spePrecision.Edit.OnKeyDown:= spePrecisionEditKeyDown;
  edtVersion.EditType:= etNumeric;
  edtVersion.Precision:= 0;
  edtVersion.TextSettings.HorzAlign:= TTextAlign.Trailing;
  vtbCurrency:= TVirtualtable.Create(Self);
  bdsCurrency:= TBindSourceDB.Create(Self);
  LoadData;
  LoadDataCurrency;
end;

procedure TfOptions.LoadData;
var
  i: integer;
  JSONGetOptionsByCode: string;
  ArrGetOptionsByCode: TJSONArray;
  ObjGetOptionsByCode: TJSONObject;
  sltError: TStringList;
begin
  //Get JSON Array
  JSONGetOptionsByCode:= '';
  JSONGetOptionsByCode:= TcOptions.ReadOptionsByCode;
  ArrGetOptionsByCode:= TJSONObject.ParseJSONValue(JSONGetOptionsByCode) as
    TJSONArray;
  sltError:= TStringList.Create;
  try
    if ArrGetOptionsByCode.Count> 1 then begin
      i:= 0;
      while i< ArrGetOptionsByCode.Count do begin
        try
          try
            ObjGetOptionsByCode:= ArrGetOptionsByCode.Items[i] as TJSONObject;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'myversion'
            then begin
              versionid:= ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              edtVersion.IntValue:=
                ObjGetOptionsByCode.GetValue<integer>('otvalue');
              oldVersion:= ObjGetOptionsByCode.GetValue<integer>('otvalue');
            end;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'mymessage'
            then begin
              messageid:= ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              edtMessage.Text:=
                ObjGetOptionsByCode.GetValue<string>('otvalue').Trim;
              oldMessage:= ObjGetOptionsByCode.GetValue<string>('otvalue').Trim;
            end;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'maintenance'
            then begin
              maintenanceid:=
                ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              chkMaintenance.IsChecked:=
                ObjGetOptionsByCode.GetValue<string>('otvalue').ToBoolean;
              oldMaintenance:= ObjGetOptionsByCode.GetValue<boolean>('otvalue');
            end;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'currency'
            then begin
              currencyid:= ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              lceCurrency.Text:=
                ObjGetOptionsByCode.GetValue<string>('otvalue').Trim;
              oldCurrency:= ObjGetOptionsByCode.GetValue<string>('otvalue').Trim;
            end;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'vatpercent'
            then begin
              vatpercentid:= ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              edtVATPercent.FloatValue:=
                ObjGetOptionsByCode.GetValue<single>('otvalue');
              oldVATPercent:= ObjGetOptionsByCode.GetValue<single>('otvalue');
            end;
            if ObjGetOptionsByCode.GetValue<string>('otcode')= 'precisionother'
            then begin
              precisionid:= ObjGetOptionsByCode.GetValue<string>('otcode').Trim;
              spePrecision.Edit.IntValue:=
                ObjGetOptionsByCode.GetValue<shortint>('otvalue');
              oldPrecision:= ObjGetOptionsByCode.GetValue<shortint>('otvalue');
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
    if sltError.Count> 0 then begin
      TDialogService.MessageDialog(sltError.Text, TMsgDlgType.mtError,
        [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
    end;
  finally
    FreeAndNil(sltError);
    FreeAndNil(ArrGetOptionsByCode);
  end;
end;

procedure TfOptions.FormDestroy(Sender: TObject);
begin
  FreeAndNil(bdsCurrency);
  FreeAndNil(vtbCurrency);
  FreeAndNil(fMain.lytModal);
  FreeAndNil(fMain.rtlModal);
  fMain.lytMain.Enabled:= True;
  fMain.btnMenu.SetFocus;
  fOptions:= nil;
end;

procedure TfOptions.lceCurrencyEnter(Sender: TObject);
begin
  lceCurrency.DropDown;
end;

procedure TfOptions.lceCurrencyKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtVATPercent.SetFocus;
  end;
end;

procedure TfOptions.rtlOptionsResize(Sender: TObject);
begin
  if (frmWidth> 0) or (frmHeight> 0) then begin
  //do not resize rectangle
    with rtlOptions do begin
      if (Width< frmWidth) or (Width> frmWidth) then begin
        Width:= frmWidth;
      end;
      if (Height< frmHeight) or (Height> frmHeight) then begin
        Height:= frmHeight;
      end;
    end;
  end;
end;

procedure TfOptions.spePrecisionEnter(Sender: TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    //for bug tmsfncspinedit which lost focusing edit after tab from button
    begin
      spePrecision.Edit.SetFocus;
    end);
end;

procedure TfOptions.spePrecisionEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtVersion.SetFocus;
  end;
end;

procedure TfOptions.DisableWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  Handled:= True;
end;

end.
