unit uCityInput;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.StrUtils, System.JSON, System.Generics.Collections, FMX.Edit, FMX.Forms,
  (*DBAware*)Data.Bind.Components, Data.Bind.DBScope(*DBAware*), FMX.Memo.Types,
  FMX.Controls.Presentation, VirtualTable, Data.DB, FMX.ScrollBox, FMX.StdCtrls,
  FMX.DialogService, FMX.Controls, FMX.Graphics, FMX.Layouts, FMX.Dialogs,
  FMX.Types, FMX.Memo, FMX.TMSFNCButton, FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCPageControl, FMX.TMSFNCGraphicsTypes, FMX.TMSFNCCustomControl,
  FMX.TMSFNCTabSet, FMX.TMSFNCGraphics, FMX.wwLookupComboEdit, FMX.wwComboEdit,
  FMX.wwDataGrid, FMX.wwEdit;

type
  TfCityInput = class(TForm)
    lytCityInput: TLayout;
    lytTool: TLayout;
    btnNew: TTMSFNCButton;
    btnCancel: TTMSFNCButton;
    btnSave: TTMSFNCButton;
    btnDelete: TTMSFNCButton;
    Layout1: TLayout;
    lblAction: TLabel;
    lblCaption: TLabel;
    lblDelete: TLabel;
    lytNew: TLayout;
    Layout3: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    Layout4: TLayout;
    lblNewUser: TLabel;
    lblNewDate: TLabel;
    lytNumber: TLayout;
    lytEdit: TLayout;
    Layout7: TLayout;
    Label5: TLabel;
    Label6: TLabel;
    Layout8: TLayout;
    lblEditUser: TLabel;
    lblEditDate: TLabel;
    lblNumberID: TLabel;
    edtNumberID: TEdit;
    pclInput: TTMSFNCPageControl;
    tbsGeneral: TTMSFNCPageControlContainer;
    Label4: TLabel;
    edtDescription: TEdit;
    edtCode: TEdit;
    mmoNote: TMemo;
    Label12: TLabel;
    Label13: TLabel;
    lceState: TwwLookupComboEdit;
    Label7: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure lceStateEnter(Sender: TObject);
  private
    procedure ClearAllControls;
    procedure LoadData;
    procedure LoadDataState;
    procedure SaveDelete(ADelete: boolean);
    function ValidatingData: boolean;
    procedure SaveNew;
    procedure SaveEdit;
  public
    mynumber: string;
    procedure CommandPass(DocAction: string);
  end;

var
  fCityInput: TfCityInput;

implementation

{$R *.fmx}

uses uClientCmd, cCity, uBusamAutoNusantara, uClientFrmCursor, uCity;

var
  vtbState: TVirtualtable;
  bdsState: TBindSourceDB;
  oldNote, oldCode, oldDescription, oldState:string;

procedure TfCityInput.CommandPass(DocAction: string);
begin
  ClearAllControls;
  case IndexStr(DocAction,['btnNew','btnEdit','btnView']) of
    0: begin
      lblAction.Text:= 'NEW';
      if themedark= True then begin
        lblAction.FontColor:= TAlphaColors.Lightgreen;
      end else begin
        lblAction.FontColor:= TAlphaColors.Darkgreen;
      end;
      lblDelete.Visible:= False;
      btnNew.Enabled:= False;
      btnNew.BitmapName:= 'new2_disable';
      btnCancel.Enabled:= True;
      btnCancel.BitmapName:= 'cancel_enable';
      btnSave.Enabled:= True;
      btnSave.BitmapName:= 'save_enable';
      (*btnPreview.Enabled:= False;
      btnPreview.BitmapName:= 'preview_disable';*)
      btnDelete.Enabled:= False;
      btnDelete.BitmapName:= 'delete_disable';
      mmoNote.ReadOnly:= False;

      edtCode.ReadOnly:= False;
      edtDescription.ReadOnly:= False;
      lceState.Enabled:= True;

      edtCode.SetFocus;
    end;
    1: begin
      lblAction.Text:= 'EDIT';
      if themedark= True then begin
        lblAction.FontColor:= TAlphaColors.Lightblue;
      end else begin
        lblAction.FontColor:= TAlphaColors.Darkblue;
      end;
      lytNew.Visible:= True;
      lytEdit.Visible:= True;
      lytTool.Padding.Right:= 0;
      btnNew.Enabled:= True;
      btnNew.BitmapName:= 'new2_enable';
      btnCancel.Enabled:= False;
      btnCancel.BitmapName:= 'cancel_disable';
      btnSave.Enabled:= True;
      btnSave.BitmapName:= 'save_enable';
      (*btnPreview.Enabled:= True;
      btnPreview.BitmapName:= 'preview_enable';*)
      btnDelete.Enabled:= True;
      btnDelete.BitmapName:= 'delete_enable';

      LoadData;
      edtDescription.SetFocus;
    end;
    2: begin
      lblAction.Text:= 'VIEW';
      if themedark= True then begin
        lblAction.FontColor:= TAlphaColors.White;
      end else begin
        lblAction.FontColor:= TAlphaColors.Black;
      end;
      lytNew.Visible:= True;
      lytEdit.Visible:= True;
      lytTool.Padding.Right:= 0;
      btnNew.Enabled:= True;
      btnNew.BitmapName:= 'new2_enable';
      btnCancel.Enabled:= False;
      btnCancel.BitmapName:= 'cancel_disable';
      btnSave.Enabled:= False;
      btnSave.BitmapName:= 'save_disable';
      (*btnPreview.Enabled:= True;
      btnPreview.BitmapName:= 'preview_enable';*)
      btnDelete.Enabled:= False;
      btnDelete.BitmapName:= 'delete_disable';

      LoadData;
      edtNumberID.SetFocus;
    end;
  end;
  LoadDataState;
end;

procedure TfCityInput.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfCityInput.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Caption:= 'City';
  if themedark= True then begin
    lblDelete.FontColor:= TAlphaColors.Lightpink;
  end else begin
    lblDelete.FontColor:= TAlphaColors.Darkred;
  end;
  i:= 0;
  while i< pclInput.Pages.Count do begin
    pclInput.Pages[i].UseDefaultAppearance:= False;
    TmClientCmd.TMSTabColor(pclInput.Pages[i]);
    TmClientCmd.FillTMSColor(pclInput.PageContainers[i].Fill, False, False);
    pclInput.PageContainers[i].Stroke.Width:= strkthickness;
    inc(i);
  end;
  vtbState:= TVirtualtable.Create(Self);
  bdsState:= TBindSourceDB.Create(Self);
  edtNumberID.ReadOnly:= True;
  edtNumberID.Visible:= False;
  lblNumberID.Visible:= False;

  edtCode.MaxLength:= 3;
  edtCode.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtCode.CharCase:= TEditCharCase.ecUpperCase;
  edtDescription.MaxLength:= 50;
  edtDescription.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
end;

procedure TfCityInput.FormDestroy(Sender: TObject);
begin
  FreeAndNil(bdsState);
  FreeAndNil(vtbState);
  fCityInput:= nil;
end;

procedure TfCityInput.lceStateEnter(Sender: TObject);
begin
  lceState.DropDown;
end;

procedure TfCityInput.btnCancelClick(Sender: TObject);
begin
  ClearAllControls;
  fMain.pclMain.ActivePage.Text:= Caption;
end;

procedure TfCityInput.btnDeleteClick(Sender: TObject);
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
    if btnDelete.Text= 'Delete' then begin
      TDialogService.MessageDialog('Do you want to delete '+ edtCode.Text+ //edtNumberID.Text.Trim+
        ' data?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
        TMsgDlgBtn.mbNo, 0,
        procedure(const AResult: TModalResult)
        begin
          case AResult of
            mrYes: begin
              SaveDelete(True);
              btnDelete.Text:= 'Restore';
              btnDelete.BitmapName:= 'ok_enable';
              lblDelete.Visible:= True;
              btnSave.Enabled:= False;
              btnSave.BitmapName:= 'save_disable';
              CommandPass('btnEdit');
            end;
            mrNo: Exit;
          end;
        end);
    end else if btnDelete.Text= 'Restore' then begin
      TDialogService.MessageDialog('Do you want to restore '+ edtCode.Text+ //edtNumberID.Text.Trim+
        ' data?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes,
        TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
        procedure(const AResult: TModalResult)
        begin
          case AResult of
            mrYes: begin
              SaveDelete(False);
              btnDelete.Text:= 'Delete';
              btnDelete.BitmapName:= 'delete_enable';
              lblDelete.Visible:= False;
              btnSave.Enabled:= True;
              btnSave.BitmapName:= 'save_enable';
              CommandPass('btnEdit');
            end;
            mrNo: Exit;
          end;
        end);
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCityInput.SaveDelete(ADelete: boolean);
var
  Response: string;
  ArrUpdateData: TJSONArray;
  ObjUpdateData: TJSONObject;
begin
  ArrUpdateData:= TJSONArray.Create;
  try
    ObjUpdateData:= TJSONObject.Create;
    ObjUpdateData.AddPair(TcCity.pkid, mynumber.Trim);
    ObjUpdateData.AddPair('inactive', ADelete);
    ObjUpdateData.AddPair('edituser', gusername.Trim);
    ArrUpdateData.AddElement(ObjUpdateData);
    Response:= TcCity.DeleteCityByID(ArrUpdateData.ToJSON);//update database with response
  finally
    FreeAndNil(ArrUpdateData);
  end;
  ObjUpdateData:= TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    if ObjUpdateData.GetValue<boolean>('success')= True then begin
      TDialogService.MessageDialog(ObjUpdateData.GetValue<string>('message')+
        #13+ 'Affected: '+ ObjUpdateData.GetValue<smallint>('affected').ToString+
        ' row(s)', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK,
        0, nil);
      fCity.FindData;
    end;
  finally
    FreeAndNil(ObjUpdateData);
  end;
end;

procedure TfCityInput.btnNewClick(Sender: TObject);
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
    fMain.pclMain.ActivePage.Text:= 'New '+ Caption;
    CommandPass('btnNew');
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCityInput.btnSaveClick(Sender: TObject);
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
      if lblAction.Text= 'NEW' then begin
        SaveNew;
      end else if lblAction.Text= 'EDIT' then begin
        SaveEdit;
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

function TfCityInput.ValidatingData: boolean;
var
  JSONCodeByCode, JSONCodeByOtherID: string;
  ObjCodeByCode, ObjCodeByOtherID: TJSONObject;
  ArrCodeByCode, ArrCodeByOtherID: TJSONArray;
begin
  if edtCode.Text= '' then begin
    TDialogService.MessageDialog('The Code is empty. Please input Code.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    edtCode.SetFocus;
    Exit(False);
  end;
  if edtDescription.Text= '' then begin
    TDialogService.MessageDialog('The Description is empty. Please input '+
      'Description.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK,
      0, nil);
    edtDescription.SetFocus;
    Exit(False);
  end;
  if lceState.Text= '' then begin
    TDialogService.MessageDialog('The State Code is empty. Please select '+
      'State Code.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK,
      0, nil);
    lceState.SetFocus;
    lceState.DropDown;
    Exit(False);
  end;
  if lblAction.Text= 'NEW' then begin
    JSONCodeByCode:= '';
    JSONCodeByCode:=
      TcCity.CheckCodeByCode(edtCode.Text);
    ArrCodeByCode:=
      TJSONObject.ParseJSONValue(JSONCodeByCode) as TJSONArray;
    try
      if ArrCodeByCode.Count> 0 then begin
        ObjCodeByCode:=
          ArrCodeByCode.Items[0] as TJSONObject;
        if edtCode.Text= ObjCodeByCode.GetValue<string>('ctcode')
          then begin
          TDialogService.MessageDialog('Code already exist. Please input '+
            'another one.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK],
            TMsgDlgBtn.mbOK, 0, nil);
          edtCode.SetFocus;
          Exit(False);
        end;
      end;
    finally
      FreeAndNil(ArrCodeByCode);
    end;
  end else if lblAction.Text= 'EDIT' then begin
    JSONCodeByOtherID:= '';
    JSONCodeByOtherID:=
      TcCity.CheckCodeByOtherID(mynumber, edtCode.Text);
    ArrCodeByOtherID:=
      TJSONObject.ParseJSONValue(JSONCodeByOtherID) as TJSONArray;
    try
      if ArrCodeByOtherID.Count> 0 then begin
        ObjCodeByOtherID:=
          ArrCodeByOtherID.Items[0] as TJSONObject;
        if edtCode.Text= ObjCodeByOtherID.GetValue<string>('ctcode')
          then begin
          TDialogService.MessageDialog('Code already exist. Please input '+
            'another one.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK],
            TMsgDlgBtn.mbOK, 0, nil);
          edtCode.SetFocus;
          Exit(False);
        end;
      end;
    finally
      FreeAndNil(ArrCodeByOtherID);
    end;
  end;
  Result:= True;
end;

procedure TfCityInput.SaveNew;
var
  Response: string;
  ArrNewData: TJSONArray;
  ObjNewData: TJSONObject;
begin
  ArrNewData:= TJSONArray.Create;
  try
    ObjNewData:= TJSONObject.Create;
    ObjNewData.AddPair('newuser', gusername.Trim);
    ObjNewData.AddPair('edituser', gusername.Trim);
    ObjNewData.AddPair('note', mmoNote.Text);

    ObjNewData.AddPair('ctcode', edtCode.Text.Trim);
    ObjNewData.AddPair('description', edtDescription.Text.Trim);
    ObjNewData.AddPair('stid',
      bdsState.DataSet.FieldByName('stid').AsString.Trim);

    ObjNewData.AddPair('location', gserverloc.Trim);
    ArrNewData.AddElement(ObjNewData);
    Response:= TcCity.CreateCity(ArrNewData.ToJSON, gserverloc);//update database with response
  finally
    FreeAndNil(ArrNewData);
  end;
  ObjNewData:= TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    if ObjNewData.GetValue<boolean>('success')= True then begin
      TDialogService.MessageDialog(ObjNewData.GetValue<string>('message')+ #13+
        'Affected: '+ ObjNewData.GetValue<smallint>('affected').ToString+
        ' row(s)'+ #13+ 'New Record: '+ TmClientCmd.FormatNumDoc(
        ObjNewData.GetValue<string>('new_id')), TMsgDlgType.mtInformation,
        [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      myNumber:= ObjNewData.GetValue<string>('new_id');
      if TmClientCmd.IsFormOpen('fCity') then begin
        fCity.Refresh;
      end;
      fMain.pclMain.ActivePage.Text:= 'Edit State';
      CommandPass('btnEdit');
    end;
  finally
    FreeAndNil(ObjNewData);
  end;
end;

procedure TfCityInput.SaveEdit;
var
  Response: string;
  ArrEditData: TJSONArray;
  ObjEditData: TJSONObject;
  Modified: boolean;
begin
  Modified:= False;
  if mmoNote.Text<> oldNote then Modified:= True;
  if edtCode.Text<> oldCode then Modified:= True;
  if edtDescription.Text<> oldDescription then Modified:= True;
  if lceState.Text<> oldState then Modified:= True;
  if Modified= True then begin
    ArrEditData:= TJSONArray.Create;
    try
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair(TcCity.pkid, mynumber.Trim);
      ObjEditData.AddPair('edituser', gusername.Trim);
      ObjEditData.AddPair('note', mmoNote.Text);

      ObjEditData.AddPair('ctcode', edtCode.Text.Trim);
      ObjEditData.AddPair('description', edtDescription.Text);
      ObjEditData.AddPair('stid',
        bdsState.DataSet.FieldByName('stid').AsString);
      ArrEditData.AddElement(ObjEditData);
      Response:= TcCity.UpdateCityByID(ArrEditData.ToJSON);//update database with response
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
        if TmClientCmd.IsFormOpen('fCity') then begin
          fCity.FindData;
        end;
        CommandPass('btnEdit');
      end;
    finally
      FreeAndNil(ObjEditData);
    end;
  end;
end;

procedure TfCityInput.ClearAllControls;
begin
  lblAction.Text:= '';
  lblDelete.Visible:= False;
  lblNewUser.Text:= gusername.Trim;
  lblNewDate.Text:= gdatetimeserver.ToString;
  lblEditUser.Text:= gusername.Trim;
  lblEditDate.Text:= gdatetimeserver.ToString;
  lytNew.Visible:= False;
  lytEdit.Visible:= False;
  lytTool.Padding.Right:= 177;
  btnNew.Enabled:= True;
  btnNew.BitmapName:= 'new2_enable';
  btnDelete.Text:= 'Delete';
  btnDelete.Enabled:= False;
  btnDelete.BitmapName:= 'delete_disable';
  btnSave.Enabled:= False;
  btnSave.BitmapName:= 'save_disable';
  (*btnPreview.Enabled:= False;
  btnPreview.BitmapName:= 'preview_disable';*)
  edtNumberID.Text:= '';
  mmoNote.ReadOnly:= True;
  mmoNote.Lines.Clear;

  edtCode.Text:= '';
  edtDescription.Text:= '';
  lceState.Text:= '';

  edtCode.ReadOnly:= True;
  edtDescription.ReadOnly:= True;
  lceState.Enabled:= False;
end;

procedure TfCityInput.LoadData;
var
  JSONCityByID: string;
  ObjCityByID: TJSONObject;
  ArrCityByID: TJSONArray;
begin
  JSONCityByID:= '';
  JSONCityByID:= TcCity.ReadCityByID(mynumber);
  ArrCityByID:= TJSONObject.ParseJSONValue(JSONCityByID) as TJSONArray;
  try
    if ArrCityByID.Count> 0 then begin
      ObjCityByID:= ArrCityByID.Items[0] as TJSONObject;
      if ObjCityByID.GetValue<boolean>('inactive')= True then begin
        lblDelete.Visible:= True;
        btnDelete.Text:= 'Restore';
        if btnDelete.Enabled= True then begin
          btnDelete.BitmapName:= 'ok_enable';
        end else begin
          btnDelete.BitmapName:= 'ok_disable';
        end;
        btnSave.Enabled:= False;
        btnSave.BitmapName:= 'save_disable';
        mmoNote.ReadOnly:= True;

        edtCode.ReadOnly:= True;
        edtDescription.ReadOnly:= True;
        lceState.Enabled:= False;
      end else begin
        lblDelete.Visible:= False;
        btnDelete.Text:= 'Delete';
        if btnDelete.Enabled= True then begin
          btnDelete.BitmapName:= 'delete_enable';
        end else begin
          btnDelete.BitmapName:= 'delete_disable';
        end;
        if lblAction.Text= 'VIEW' then begin
          btnSave.Enabled:= False;
          btnSave.BitmapName:= 'save_disable';
          mmoNote.ReadOnly:= True;

          edtCode.ReadOnly:= True;
          edtDescription.ReadOnly:= True;
          lceState.Enabled:= False;
        end else if lblAction.Text= 'EDIT' then begin
          btnSave.Enabled:= True;
          btnSave.BitmapName:= 'save_enable';
          mmoNote.ReadOnly:= False;

          if gusertype= 2 then begin
            edtCode.ReadOnly:= False;
          end else if gusertype<> 2 then begin
            edtCode.ReadOnly:= True;
          end;
          edtDescription.ReadOnly:= False;
          lceState.Enabled:= True;
        end;
      end;
      lblNewUser.Text:= ObjCityByID.GetValue<string>('newuser').Trim;
      lblNewDate.Text:= DateTimeToStr(TmClientCmd.JSONDateTimeToDateTime(
        ObjCityByID.GetValue<string>('newdate')));
      lblEditUser.Text:= ObjCityByID.GetValue<string>('edituser').Trim;
      lblEditDate.Text:= DateTimeToStr(TmClientCmd.JSONDateTimeToDateTime(
        ObjCityByID.GetValue<string>('editdate')));
      edtNumberID.Text:= TmClientCmd.FormatNumDoc(
        ObjCityByID.GetValue<string>(TcCity.pkid).Trim);
      mmoNote.Lines.Add(ObjCityByID.GetValue<string>('note'));

      edtCode.Text:= ObjCityByID.GetValue<string>('ctcode').Trim;
      edtDescription.Text:= ObjCityByID.GetValue<string>('description').Trim;
      lceState.Text:= ObjCityByID.GetValue<string>('stcode').Trim;

      oldNote:= ObjCityByID.GetValue<string>('note');

      oldCode:= ObjCityByID.GetValue<string>('ctcode');
      oldDescription:= ObjCityByID.GetValue<string>('description');
      oldState:= ObjCityByID.GetValue<string>('stcode').Trim;
    end;
  finally
    FreeAndNil(ArrCityByID);
  end;
end;

procedure TfCityInput.LoadDataState;
var
  JSONState: string;
begin
  JSONState:= TcCity.GetState;
  vtbState.DisableControls;
  try
    with vtbState do begin
      Active:= False;
      IndexFieldNames:= '';
      DeleteFields;
      AddField('stcode', ftString, 2, True);
      AddField('description', ftString, 50, True);
      AddField('stid', ftString, 50, True);
      IndexFieldNames:= 'description ASC';
      CachedUpdates:= False;
      Active:= True;
      TmClientCmd.JSONToVirtualTable(JSONState, vtbState);
    end;
    with lceState do begin
      bdsState.DataSet:= vtbState;
      LookupSource:= bdsState;
      LookupField:= 'stcode';
      DropDownCount:= 6;
      Style:= wwcbsDropDownList;
      with DropDownGrid do begin
        Columns[0].Width:= 40;
        Columns[0].Title:= 'Code';
        Columns[1].Width:= 130;
        Columns[1].Title:= 'Description';
        Columns[2].Width:= 0;
        Columns[2].Visible:= False;
        KeyOptions:= [];
        Options:= [dgColumnResize, dgTabs, dgRowSelect, dgConfirmDelete,
          dgCancelOnExit, dgWordWrap, dgAlternatingRow, dgTitles];
        OverrideStyleSettings.Title.FontStyle:= [TFontStyle.fsBold];
      end;
      LookupValue:= Text;
    end;
  finally
    vtbState.EnableControls;
  end;
end;

end.
