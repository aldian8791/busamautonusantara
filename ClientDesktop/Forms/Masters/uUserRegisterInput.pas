unit uUserRegisterInput;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.StrUtils, System.JSON, System.Generics.Collections, FMX.Forms, FMX.Edit,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.ScrollBox,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.Memo.Types, FMX.Memo,
  FMX.DialogService, FMX.TMSFNCButton, FMX.TMSFNCTypes, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl, FMX.TMSFNCGraphics, FMX.TMSFNCPageControl,
  FMX.TMSFNCUtils, FMX.TMSFNCTabSet;

type
  TfUserRegisterInput = class(TForm)
    lytUserRegisterInput: TLayout;
    lytTool: TLayout;
    btnNew: TTMSFNCButton;
    btnCancel: TTMSFNCButton;
    btnSave: TTMSFNCButton;
    btnDelete: TTMSFNCButton;
    lblAction: TLabel;
    lblCaption: TLabel;
    lblDelete: TLabel;
    Layout1: TLayout;
    lytNew: TLayout;
    Label1: TLabel;
    Layout3: TLayout;
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
    edtDepartment: TEdit;
    Label7: TLabel;
    edtJob: TEdit;
    Label8: TLabel;
    edtFullName: TEdit;
    Label9: TLabel;
    edtUserName: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    edtPassword: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    cmbUserType: TComboBox;
    mmoNote: TMemo;
    Label12: TLabel;
    Label13: TLabel;
    chkKick: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    procedure ClearAllControls;
    procedure LoadData;
    function ValidatingData: boolean;
    procedure SaveDelete(ADelete: boolean);
    procedure SaveEdit;
    procedure SaveNew;
  public
    mynumber: string;
    procedure CommandPass(DocAction: string);
  end;

var
  fUserRegisterInput: TfUserRegisterInput;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientCmd, cUserRegister, uClientFrmCursor,
  uUserRegister;

var
  oldKick: boolean;
  oldUserType: shortint;
  oldUsername, oldPassword, oldFullName, oldJob, oldDepartment,
  oldNote: string;

procedure TfUserRegisterInput.CommandPass(DocAction: string);
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

      if gusertype= 0 then begin
        chkKick.Enabled:= False;
      end else if gusertype<> 0 then begin
        chkKick.Enabled:= True;
      end;
      cmbUserType.Enabled:= True;
      edtUserName.ReadOnly:= False;
      edtPassword.ReadOnly:= False;
      edtFullName.ReadOnly:= False;
      edtJob.ReadOnly:= False;
      edtDepartment.ReadOnly:= False;

      if gusertype= 0 then begin
        edtPassword.SetFocus;
      end else if gusertype<> 0 then begin
        chkKick.SetFocus;
      end;
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
      if gusertype= 0 then begin
        edtPassword.SetFocus;
      end else if gusertype<> 0 then begin
        chkKick.SetFocus;
      end;
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
end;

procedure TfUserRegisterInput.btnCancelClick(Sender: TObject);
begin
  ClearAllControls;
  fMain.pclMain.ActivePage.Text:= Caption;
end;

procedure TfUserRegisterInput.SaveDelete(ADelete: boolean);
var
  Response: string;
  ArrUpdateData: TJSONArray;
  ObjUpdateData: TJSONObject;
begin
  ArrUpdateData:= TJSONArray.Create;
  try
    ObjUpdateData:= TJSONObject.Create;
    ObjUpdateData.AddPair(TcUserRegister.pkid, mynumber.Trim);
    ObjUpdateData.AddPair('inactive', ADelete);
    ObjUpdateData.AddPair('edituser', gusername.Trim);
    ArrUpdateData.AddElement(ObjUpdateData);
    Response:= TcUserRegister.DeleteUserRegisterByID(ArrUpdateData.ToJSON);//update database with response
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
      fUserRegister.FindData;
    end;
  finally
    FreeAndNil(ObjUpdateData);
  end;
end;

procedure TfUserRegisterInput.btnDeleteClick(Sender: TObject);
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
      TDialogService.MessageDialog('Do you want to delete '+ edtUserName.Text+ //edtNumberID.Text.Trim+
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
      TDialogService.MessageDialog('Do you want to restore '+ edtUserName.Text+ //edtNumberID.Text.Trim+
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

procedure TfUserRegisterInput.btnNewClick(Sender: TObject);
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

procedure TfUserRegisterInput.btnSaveClick(Sender: TObject);
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

function TfUserRegisterInput.ValidatingData: boolean;
var
  JSONUsernameByUsername, JSONUsernameByOtherID: string;
  ObjUsernameByUsername, ObjUsernameByOtherID: TJSONObject;
  ArrUsernameByUsername, ArrUsernameByOtherID: TJSONArray;
begin
  if edtUserName.Text= '' then begin
    TDialogService.MessageDialog('The Username is empty. Please input Username.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    edtUserName.SetFocus;
    Exit(False);
  end;
  if edtPassword.Text= '' then begin
    TDialogService.MessageDialog('The Password is empty. Please input Password.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    edtPassword.SetFocus;
    Exit(False);
  end;
  if edtFullName.Text= '' then begin
    TDialogService.MessageDialog('The Fullname is empty. Please input Fullname.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    edtFullName.SetFocus;
    Exit(False);
  end;
  if lblAction.Text= 'NEW' then begin
    JSONUsernameByUsername:= '';
    JSONUsernameByUsername:=
      TcUserRegister.CheckUsernameByUsername(edtUserName.Text);
    ArrUsernameByUsername:=
      TJSONObject.ParseJSONValue(JSONUsernameByUsername) as TJSONArray;
    try
      if ArrUsernameByUsername.Count> 0 then begin
        ObjUsernameByUsername:=
          ArrUsernameByUsername.Items[0] as TJSONObject;
        if edtUserName.Text= ObjUsernameByUsername.GetValue<string>('urname')
          then begin
          TDialogService.MessageDialog('Username already exist. Please input '+
            'another one.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          edtUserName.SetFocus;
          Exit(False);
        end;
      end;
    finally
      FreeAndNil(ArrUsernameByUsername);
    end;
  end else if lblAction.Text= 'EDIT' then begin
    JSONUsernameByOtherID:= '';
    JSONUsernameByOtherID:=
      TcUserRegister.CheckUsernameByOtherID(mynumber, edtUserName.Text);
    ArrUsernameByOtherID:=
      TJSONObject.ParseJSONValue(JSONUsernameByOtherID) as TJSONArray;
    try
      if ArrUsernameByOtherID.Count> 0 then begin
        ObjUsernameByOtherID:=
          ArrUsernameByOtherID.Items[0] as TJSONObject;
        if edtUserName.Text= ObjUsernameByOtherID.GetValue<string>('urname')
          then begin
          TDialogService.MessageDialog('Username already exist. Please input '+
            'another one.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          edtUserName.SetFocus;
          Exit(False);
        end;
      end;
    finally
      FreeAndNil(ArrUsernameByOtherID);
    end;
  end;
  Result:= True;
end;

procedure TfUserRegisterInput.SaveNew;
var
  Response, myEncrypted: string;
  ArrNewData: TJSONArray;
  ObjNewData: TJSONObject;
begin
  fMain.myCodec.EncryptString(edtPassword.Text, myEncrypted, TEncoding.UTF8);
  ArrNewData:= TJSONArray.Create;
  try
    ObjNewData:= TJSONObject.Create;
    ObjNewData.AddPair('newuser', gusername.Trim);
    ObjNewData.AddPair('edituser', gusername.Trim);
    ObjNewData.AddPair('note', mmoNote.Text);

    ObjNewData.AddPair('urtype', cmbUserType.ItemIndex);
    ObjNewData.AddPair('urname', edtUserName.Text.Trim);
    ObjNewData.AddPair('urpassword', myEncrypted);
    ObjNewData.AddPair('urfullname', edtFullName.Text.Trim);
    ObjNewData.AddPair('kick', chkKick.IsChecked);

    ObjNewData.AddPair('location', gserverloc.Trim);
    ArrNewData.AddElement(ObjNewData);
    Response:= TcUserRegister.CreateUserRegister(ArrNewData.ToJSON, gserverloc);//update database with response
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
      if TmClientCmd.IsFormOpen('fUserRegister') then begin
        fUserRegister.Refresh;
      end;
      fMain.pclMain.ActivePage.Text:= 'Edit UserRegister';
      CommandPass('btnEdit');
    end;
  finally
    FreeAndNil(ObjNewData);
  end;
end;

procedure TfUserRegisterInput.SaveEdit;
var
  Response, myEncrypted: string;
  ArrEditData: TJSONArray;
  ObjEditData: TJSONObject;
  Modified: boolean;
  {vtbMasterEdit: TVirtualtable;
  Modified: boolean;
  JSONUserRegisterByID, Response, myEncrypted: string;
  ObjSave, ObjUserRegisterByID: TJSONObject;
  ArrUserRegisterByID: TJSONArray;}
begin
  Modified:= False;
  fMain.myCodec.EncryptString(edtPassword.Text, myEncrypted, TEncoding.UTF8);
  if mmoNote.Text<> oldNote then Modified:= True;
  if cmbUserType.ItemIndex<> oldUserType then Modified:= True;
  if edtUserName.Text<> oldUsername then Modified:= True;
  if myEncrypted<> oldPassword then Modified:= True;
  if edtFullName.Text<> oldFullName then Modified:= True;
  if chkKick.IsChecked<> oldKick then Modified:= True;
  if Modified= True then begin
    ArrEditData:= TJSONArray.Create;
    try
      ObjEditData:= TJSONObject.Create;
      ObjEditData.AddPair(TcUserRegister.pkid, mynumber.Trim);
      ObjEditData.AddPair('edituser', gusername.Trim);
      ObjEditData.AddPair('note', mmoNote.Text);

      ObjEditData.AddPair('urtype', cmbUserType.ItemIndex);
      ObjEditData.AddPair('urname', edtUserName.Text.Trim);
      ObjEditData.AddPair('urpassword', myEncrypted);
      ObjEditData.AddPair('urfullname', edtFullName.Text.Trim);
      ObjEditData.AddPair('kick', chkKick.IsChecked);
      ArrEditData.AddElement(ObjEditData);
      Response:= TcUserRegister.UpdateUserRegisterByID(ArrEditData.ToJSON);//update database with response
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
        if TmClientCmd.IsFormOpen('fUserRegister') then begin
          fUserRegister.FindData;
        end;
        CommandPass('btnEdit');
      end;
    finally
      FreeAndNil(ObjEditData);
    end;
  end;

  {vtbMasterEdit:= TVirtualtable.Create(Self);
  try
    vtbMasterEdit.DisableControls;
    Modified:= False;
    JSONUserRegisterByID:= '';
    JSONUserRegisterByID:= TcUserRegister.GetUserRegisterByID(mynumber);
    ArrUserRegisterByID:=
      TJSONObject.ParseJSONValue(JSONUserRegisterByID) as TJSONArray;
    try
      if ArrUserRegisterByID.Count> 0 then begin
        ObjUserRegisterByID:= ArrUserRegisterByID.Items[0] as TJSONObject;
        if mmoNote.Text<> ObjUserRegisterByID.GetValue<string>('note') then
          Modified:= True;
        if cmbUserType.ItemIndex<>
          ObjUserRegisterByID.GetValue<shortint>('urtype') then Modified:= True;
        fMain.myCodec.EncryptString(edtPassword.Text, myEncrypted, TEncoding.UTF8);
        if myEncrypted<> ObjUserRegisterByID.GetValue<string>('urpassword')
          then Modified:= True;
        if edtFullName.Text<> ObjUserRegisterByID.GetValue<string>('urfullname').Trim
          then Modified:= True;
        if chkKick.IsChecked<> ObjUserRegisterByID.GetValue<boolean>('kick') then
          Modified:= True;
        if Modified= True then begin
          with vtbMasterEdit do begin
            Active:= False;
            IndexFieldNames:= '';
            DeleteFields;
            AddField('urid', ftString, 50, True);
            AddField('edituser', ftString, 20, True);
            AddField('note', ftMemo, 0, False);
            AddField('urtype', ftShortInt, 0, True);
            AddField('urpassword', ftString, 400, True);
            AddField('urfullname', ftString, 50, True);
            AddField('kick', ftBoolean, 0, True);
            AddField('is_new', ftBoolean, 0, False);
            AddField('is_changed', ftBoolean, 0, False);
            AddField('is_deleted', ftBoolean, 0, False);
            IndexFieldNames:= '';
            CachedUpdates:= False;
            Active:= True;
            Edit;
            FieldByName('urid').AsString:= mynumber.Trim;
            FieldByName('edituser').AsString:= gusername.Trim;
            FieldByName('note').AsString:= mmoNote.Text;
            FieldByName('urtype').AsInteger:= cmbUserType.ItemIndex;
            FieldByName('urpassword').AsString:= myEncrypted;
            FieldByName('urfullname').AsString:= edtFullName.Text.Trim;
            FieldByName('kick').AsBoolean:= chkKick.IsChecked;
            FieldByName('is_changed').AsBoolean:= True;
            Post;
          end;
        end;
      end;
    finally
      FreeAndNil(ArrUserRegisterByID);
    end;
    if Modified= True then begin
      Response:= TcUserRegister.UpdateUserRegisterByID(
        TmClientCmd.VirtualTableChangesToJSON(vtbMasterEdit));//update database with response
      ObjSave:= TJSONObject.ParseJSONValue(Response) as TJSONObject;
      try
        if ObjSave.GetValue<boolean>('success')= True then begin
          TDialogService.MessageDialog(ObjSave.GetValue<string>('message')+ #13+
            'Affected: '+ ObjSave.GetValue<smallint>('affected').ToString+' row(s)',
            TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
            nil);
          fUserRegister.FindData;
        end;
      finally
        FreeAndNil(ObjSave);
      end;
    end;
  finally
    vtbMasterEdit.EnableControls;
    FreeAndNil(vtbMasterEdit);
  end;}
end;

procedure TfUserRegisterInput.ClearAllControls;
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

  chkKick.IsChecked:= False;
  cmbUserType.ItemIndex:= 0;
  edtUserName.Text:= '';
  edtPassword.Text:= '';
  edtFullName.Text:= '';
  edtJob.Text:= '';
  edtDepartment.Text:= '';

  chkKick.Enabled:= False;
  cmbUserType.Enabled:= False;
  edtUserName.ReadOnly:= True;
  edtPassword.ReadOnly:= True;
  edtFullName.ReadOnly:= True;
  edtJob.ReadOnly:= True;
  edtDepartment.ReadOnly:= True;
end;

procedure TfUserRegisterInput.LoadData;
var
  JSONUserRegisterByID, myDecrypted: string;
  ObjUserRegisterByID: TJSONObject;
  ArrUserRegisterByID: TJSONArray;
begin
  JSONUserRegisterByID:= '';
  JSONUserRegisterByID:= TcUserRegister.ReadUserRegisterByID(mynumber);
  ArrUserRegisterByID:=
    TJSONObject.ParseJSONValue(JSONUserRegisterByID) as TJSONArray;
  try
    if ArrUserRegisterByID.Count> 0 then begin
      ObjUserRegisterByID:= ArrUserRegisterByID.Items[0] as TJSONObject;
      if ObjUserRegisterByID.GetValue<boolean>('inactive')= True then begin
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

        chkKick.Enabled:= False;
        cmbUserType.Enabled:= False;
        edtUserName.ReadOnly:= True;
        edtPassword.ReadOnly:= True;
        edtFullName.ReadOnly:= True;
        edtJob.ReadOnly:= True;
        edtDepartment.ReadOnly:= True;
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

          chkKick.Enabled:= False;
          cmbUserType.Enabled:= False;
          edtUserName.ReadOnly:= True;
          edtPassword.ReadOnly:= True;
          edtFullName.ReadOnly:= True;
          edtJob.ReadOnly:= True;
          edtDepartment.ReadOnly:= True;
        end else if lblAction.Text= 'EDIT' then begin
          btnSave.Enabled:= True;
          btnSave.BitmapName:= 'save_enable';
          mmoNote.ReadOnly:= False;

          chkKick.Enabled:= True;
          cmbUserType.Enabled:= True;
          if gusertype= 2 then begin
            edtUserName.ReadOnly:= False;
          end else if gusertype<> 2 then begin
            edtUserName.ReadOnly:= True;
          end;
          edtPassword.ReadOnly:= False;
          edtFullName.ReadOnly:= False;
          edtJob.ReadOnly:= False;
          edtDepartment.ReadOnly:= False;
        end;
      end;
      lblNewUser.Text:= ObjUserRegisterByID.GetValue<string>('newuser').Trim;
      lblNewDate.Text:= DateTimeToStr(TmClientCmd.JSONDateTimeToDateTime(
        ObjUserRegisterByID.GetValue<string>('newdate')));
      lblEditUser.Text:= ObjUserRegisterByID.GetValue<string>('edituser').Trim;
      lblEditDate.Text:= DateTimeToStr(TmClientCmd.JSONDateTimeToDateTime(
        ObjUserRegisterByID.GetValue<string>('editdate')));
      edtNumberID.Text:= TmClientCmd.FormatNumDoc(
        ObjUserRegisterByID.GetValue<string>(TcUserRegister.pkid).Trim);
      mmoNote.Lines.Add(ObjUserRegisterByID.GetValue<string>('note'));

      chkKick.IsChecked:= ObjUserRegisterByID.GetValue<boolean>('kick');
      cmbUserType.ItemIndex:= ObjUserRegisterByID.GetValue<shortint>('urtype');
      edtUserName.Text:= ObjUserRegisterByID.GetValue<string>('urname').Trim;
      fMain.myCodec.DecryptString(myDecrypted,
        ObjUserRegisterByID.GetValue<string>('urpassword'), TEncoding.UTF8);
      edtPassword.Text:= myDecrypted.Trim;
      edtFullName.Text:=
        ObjUserRegisterByID.GetValue<string>('urfullname').Trim;
      edtJob.Text:= ObjUserRegisterByID.GetValue<string>('jbcode').Trim;
      edtDepartment.Text:= ObjUserRegisterByID.GetValue<string>('dmcode').Trim;

      oldNote:= ObjUserRegisterByID.GetValue<string>('note');

      oldKick:= ObjUserRegisterByID.GetValue<boolean>('kick');
      oldUserType:= ObjUserRegisterByID.GetValue<shortint>('urtype');
      oldUsername:= ObjUserRegisterByID.GetValue<string>('urname');
      oldPassword:= ObjUserRegisterByID.GetValue<string>('urpassword');
      oldFullName:= ObjUserRegisterByID.GetValue<string>('urfullname').Trim;
      oldJob:= ObjUserRegisterByID.GetValue<string>('jbcode').Trim;
      oldDepartment:= ObjUserRegisterByID.GetValue<string>('dmcode').Trim;
    end;
  finally
    FreeAndNil(ArrUserRegisterByID);
  end;
end;

procedure TfUserRegisterInput.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfUserRegisterInput.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Caption:= 'UserRegister';
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
  edtNumberID.ReadOnly:= True;
  edtNumberID.Visible:= False;
  lblNumberID.Visible:= False;
  with cmbUserType do begin
    Clear;
    Items.Add('user');
    if gusertype<> 0 then begin
      Items.Add('administrator');
    end;
    if gusertype= 2 then begin
      Items.Add('programmer');
    end;
  end;
  edtUserName.MaxLength:= 20;
  edtUserName.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtUserName.CharCase:= TEditCharCase.ecLowerCase;
  edtPassword.MaxLength:= 20;
  edtPassword.Password:= True;
  edtFullName.MaxLength:= 50;
  edtFullName.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
end;

procedure TfUserRegisterInput.FormDestroy(Sender: TObject);
begin
  fUserRegisterInput:= nil;
end;

end.
