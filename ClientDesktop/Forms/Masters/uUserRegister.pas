unit uUserRegister;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.JSON, System.Generics.Collections, FMX.Dialogs, FMX.Types, FMX.Controls,
  (*Adapter*)FMX.TMSFNCCustomComponent, FMX.TMSFNCDataGridDatabaseAdapter(*Adapter*),
  (*DBAware*)Uni, Data.DB, DBAccess(*DBAware*), FMX.DialogService, FMX.ComboEdit,
  FMX.Controls.Presentation, VirtualTable, FMX.Effects, FMX.Layouts, FMX.Objects,
  FMX.Forms, FMX.Edit, FMX.Graphics, FMX.StdCtrls, FMX.TMSFNCPageControl,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCDataGridRenderer, FMX.TMSFNCCustomControl, FMX.TMSFNCDataGridCell,
  FMX.TMSFNCDataGridData, FMX.TMSFNCDataGridBase, FMX.TMSFNCDataGridCore,
  FMX.TMSFNCDataGrid, System.Rtti, FMX.TMSFNCButton;

type
  TfUserRegister = class(TForm)
    lytUserRegister: TLayout;
    lytTool: TLayout;
    btnNew: TTMSFNCButton;
    btnFind: TTMSFNCButton;
    btnRefresh: TTMSFNCButton;
    btnView: TTMSFNCButton;
    btnEdit: TTMSFNCButton;
    grdList: TTMSFNCDataGrid;
    rtlFind: TRectangle;
    lytHeader: TLayout;
    lytAction: TLayout;
    btnClose: TTMSFNCButton;
    Label1: TLabel;
    btnClear: TTMSFNCButton;
    btnOK: TTMSFNCButton;
    sdeFind: TShadowEffect;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtUserName: TEdit;
    edtFullName: TEdit;
    edtJob: TEdit;
    edtDepartment: TEdit;
    cmbUserType: TComboEdit;
    lblCaption: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure grdListGetCellClass(Sender: TObject; AColumn, ARow: Integer;
      var ACellClass: TTMSFNCDataGridCellClass);
    procedure grdListGetCellProperties(Sender: TObject;
      ACell: TTMSFNCDataGridCell);
    procedure grdListGetCellData(Sender: TObject;
      ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
    procedure grdListBeforeSortColumn(Sender: TObject; AColumn: Integer;
      var ACanSort: Boolean);
    procedure grdListGetInplaceEditorProperties(Sender: TObject;
      ACell: TTMSFNCDataGridCellCoord;
      AInplaceEditor: TTMSFNCDataGridInplaceEditor;
      AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
    procedure grdListGetCellLayout(Sender: TObject; ACell: TTMSFNCDataGridCell);
    procedure grdListEnter(Sender: TObject);
    procedure grdListClick(Sender: TObject);
    procedure grdListCellClick(Sender: TObject; AColumn, ARow: Integer);
    procedure btnCloseClick(Sender: TObject);
    procedure rtlFindResize(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cmbUserTypeKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtUserNameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtFullNameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtJobKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtDepartmentKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure lblCaptionClick(Sender: TObject);
  private
    procedure AddPageForm;
    procedure LoadGrid;
    procedure AdapterSortData(Sender: TObject);
    procedure LoadData;
    procedure ClearAllControls;
  public
    procedure Refresh;
    procedure HidertlFind;
    procedure FindData;
  end;

var
  fUserRegister: TfUserRegister;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientCmd, uUserRegisterInput, cUserRegister,
  uClientSet, uClientFrmCursor;

var
  vtbUserRegister: TVirtualTable;
  dtsUserRegister: TUniDataSource;
  adtUserRegister: TTMSFNCDataGridDatabaseAdapter;
  FSortColumn, FocusID: string;
  FSortAsc: boolean;
  FocusCol: integer;
  rtlFindWidth, rtlFindHeight: single;

procedure TfUserRegister.AddPageForm;
begin
  fUserRegisterInput:= TfUserRegisterInput.Create(fMain);
  with fMain.pclMain do begin
    AddPage('UserRegister');
    SelectTab(Pages.Count- 1);
    TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
    with Pages.Tabs[Pages.Count- 1] do begin
      if fMain.btnUserRegister.Visible= True then begin
        Bitmaps.AddBitmapName(fMain.btnUserRegister.BitmapName);
      end;
      Text:= 'UserRegister';
      if btnNew.IsPressed= True then begin
        Text:= 'New '+ Text;
      end else if btnEdit.IsPressed= True then begin
        Text:= 'Edit '+ Text;
      end else if btnView.IsPressed= True then begin
        Text:= 'View '+ Text;
      end;
    end;
    with PageContainers[Pages.Count- 1] do begin
      TmClientCmd.FillTMSColor(Fill, False, False);
      Stroke.Width:= strkthickness;
    end;
  end;
  fUserRegisterInput.lytUserRegisterInput.Parent:=
    fMain.pclMain.PageContainers[fMain.pclMain.Pages.Count- 1];
end;

procedure TfUserRegister.ClearAllControls;
begin
  (*cmbLocation.Text:= gserverloc.Trim;
  edtNumFrom.Text:= '';
  edtNumTo.Text:= '';*)
  cmbUserType.Text:= '';
  edtUserName.Text:= '';
  edtFullName.Text:= '';
  edtJob.Text:= '';
  edtDepartment.Text:= '';
end;

procedure TfUserRegister.cmbUserTypeKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtUserName.SetFocus;
  end;
end;

procedure TfUserRegister.edtDepartmentKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnOK.SetFocus;
  end;
end;

procedure TfUserRegister.edtFullNameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtJob.SetFocus;
  end;
end;

procedure TfUserRegister.edtJobKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtDepartment.SetFocus;
  end;
end;

procedure TfUserRegister.edtUserNameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtFullName.SetFocus;
  end;
end;

procedure TfUserRegister.btnClearClick(Sender: TObject);
begin
  ClearAllControls;
end;

procedure TfUserRegister.btnCloseClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfUserRegister.btnEditClick(Sender: TObject);
var
  tabstate: string;
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
    HidertlFind;
    if TmClientCmd.IsFormOpen('fUserRegisterInput')= True then begin
      tabstate:= fUserRegisterInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fUserRegisterInput.lblAction.Text<> 'EDIT' then begin
        TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+' state. To open Edit Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fUserRegisterInput.lblAction.Text= 'EDIT' then begin
        if vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString<>
          fUserRegisterInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+' state at number '+
            fUserRegisterInput.mynumber+ '. To open Edit Tab, please close the '+
            'exiting tab first for your '+
            vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim+
            ' tab.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK,
            0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fUserRegisterInput.lytUserRegisterInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fUserRegisterInput do begin
        mynumber:=
          vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim;
        CommandPass(btnEdit.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfUserRegister.btnFindClick(Sender: TObject);
begin
  if rtlFind.Visible= False then begin
    rtlFind.Visible:= True;
    rtlFind.BringToFront;
    //edtNumFrom.SetFocus;
    cmbUserType.SetFocus;
  end else begin
    HidertlFind;
    btnFind.SetFocus;
  end;
end;

procedure TfUserRegister.btnNewClick(Sender: TObject);
var
  tabstate: string;
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
    HidertlFind;
    if TmClientCmd.IsFormOpen('fUserRegisterInput')= True then begin
      tabstate:= fUserRegisterInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fUserRegisterInput.lblAction.Text<> 'NEW' then begin
        TDialogService.MessageDialog('Sorry, New Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open New Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end;
      fMain.pclMain.SelectTab((
        fUserRegisterInput.lytUserRegisterInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      fUserRegisterInput.CommandPass(btnNew.Name);
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfUserRegister.btnOKClick(Sender: TObject);
begin
  FindData;
end;

procedure TfUserRegister.btnRefreshClick(Sender: TObject);
begin
  HidertlFind;
  Refresh;
end;

procedure TfUserRegister.btnViewClick(Sender: TObject);
var
  tabstate: string;
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
    HidertlFind;
    if TmClientCmd.IsFormOpen('fUserRegisterInput')= True then begin
      tabstate:= fUserRegisterInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fUserRegisterInput.lblAction.Text<> 'VIEW' then begin
        TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open View Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fUserRegisterInput.lblAction.Text= 'VIEW' then begin
        if vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString<>
          fUserRegisterInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+ ' state at number '+
            fUserRegisterInput.mynumber+ '. To open View Tab, please close the '+
            'exiting tab first for your '+
            vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim+
            ' tab.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK,
            0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fUserRegisterInput.lytUserRegisterInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fUserRegisterInput do begin
        mynumber:= vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim;
        CommandPass(btnView.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfUserRegister.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfUserRegister.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  grdList.OnExit:= nil;
  grdList.OnEnter:= nil;
  grdList.OnCellClick:= nil;
end;

procedure TfUserRegister.AdapterSortData(Sender: TObject);
begin
  TmClientCmd.AdapterSorting(grdList, adtUserRegister);
end;

procedure TfUserRegister.HidertlFind;
begin
  if rtlFind.Visible= True then begin
    rtlFind.SendToBack;
    rtlFind.Visible:= False;
  end;
end;

procedure TfUserRegister.lblCaptionClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfUserRegister.FormCreate(Sender: TObject);
begin
  rtlFindWidth:= rtlFind.Width;
  rtlFindHeight:= rtlFind.Height;
  TmClientSet.EnableDragResize(rtlFind);//move and resize control
  rtlFind.Stroke.Color:= strkcolor;
  rtlFind.Stroke.Thickness:= strkthickness;
  with sdeFind do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  with cmbUserType do begin
    Clear;
    Items.Add('user');
    Items.Add('administrator');
    if gusertype= 2 then begin
      Items.Add('programmer');
    end;
  end;
  HidertlFind;
  vtbUserRegister:= TVirtualTable.Create(Self);
  dtsUserRegister:= TUniDataSource.Create(Self);
  adtUserRegister:= TTMSFNCDataGridDatabaseAdapter.Create(Self);
  (*cmbLocation.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  cmbLocation.CharCase:= TEditCharCase.ecUpperCase;
  cmbLocation.Text:= gserverloc.ToUpper;
  edtNumFrom.FilterChar:= '0123456789';
  edtNumFrom.TextAlign:= TTextAlign.Trailing;
  edtNumTo.FilterChar:= '0123456789';
  edtNumTo.TextAlign:= TTextAlign.Trailing;*)

  edtUserName.MaxLength:= 20;
  edtUsername.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtUsername.CharCase:= TEditCharCase.ecLowerCase;
  edtFullName.MaxLength:= 50;
  edtFullName.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  with grdList do begin
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
    TmClientCmd.GridAppearance(grdList);
  end;
  FSortColumn:= 'urname';
  FSortAsc:= True;
  LoadData;
  LoadGrid;
  (*FSortColumn:= 'myid';
  FSortAsc:= False;*)
  with TmClientCmd do begin
    FillTMSColor(grdList.Fill, False, False);
    if themedark then begin
      FillBrushColor(rtlFind.Fill, False, False, False);
    end;
  end;
  with grdList do begin
    if (RowCount)> 1 then begin
      SelectCell(MakeCell(1, 1));
    //Save Grid Focus;
      FocusID:= vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim;
      FocusCol:= FocusedCell.Column;
    end;
  end;
end;

procedure TfUserRegister.LoadData;
var
  wrongusertype, JSONUserRegister(*, JSONNumberLoc*): string;
  (*ObjNumberLoc: TJSONObject;
  ArrNumberLoc: TJSONArray;
  i: integer;*)
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    (*JSONNumberLoc:= '';
    JSONNumberLoc:= TcUserRegister.GetNumberLoc;
    ArrNumberLoc:= TJSONObject.ParseJSONValue(JSONNumberLoc) as TJSONArray;
    try
      cmbLocation.Clear;
      if ArrNumberLoc.Count> 0 then begin
        i:= 0;
        while i< ArrNumberLoc.Count do begin
          if ArrNumberLoc.Items[i] is TJSONObject then begin
            ObjNumberLoc:= ArrNumberLoc.Items[i] as TJSONObject;
            cmbLocation.Items.Add(ObjNumberLoc.GetValue<string>('numberloc').Trim);
          end;
          inc(i);
        end;
      end;
    finally
      FreeAndNil(ArrNumberLoc);
    end;*)
    JSONUserRegister:= '';
    JSONUserRegister:= TcUserRegister.IndexUserRegister(wrongusertype, gusertype,
      FSortColumn, FSortAsc, (*cmbLocation.Text.Trim, edtNumFrom.Text.Trim,
      edtNumTo.Text.Trim,*) cmbUserType.Text.Trim, edtUserName.Text.Trim,
      edtFullName.Text.Trim, edtJob.Text.Trim, edtDepartment.Text.Trim);
    if wrongusertype<> '' then begin
      TDialogService.MessageDialog(wrongusertype, TMsgDlgType.mtError,
        [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0, nil);
      cmbUserType.Text:= '';
      cmbUserType.SetFocus;
      cmbUserType.DropDown;
    end;
    with vtbUserRegister do begin
      DisableControls;
      try
        Active:= False;
        IndexFieldNames:= '';
        DeleteFields;
        AddField(TcUserRegister.pkid, ftString, 50, True);
        //AddField('myid', ftString, 50, True);
        AddField('urtype', ftString, 20, True);
        AddField('urname', ftString, 20, True);
        AddField('urfullname', ftString, 50, True);
        AddField('jbcode', ftString, 3, False);
        AddField('dmcode', ftString, 3, False);
        AddField('kick', ftBoolean, 0, True);
        AddField('inactive', ftBoolean, 0, True);
        AddField('edituser', ftString, 20, True);
        AddField('editdate', ftString, 20, True);
        IndexFieldNames:= '';
        CachedUpdates:= False;
        Active:= True;
        TmClientCmd.JSONToVirtualTable(JSONUserRegister, vtbUserRegister);
      finally
        EnableControls;
      end;
    end;
    dtsUserRegister.DataSet:= vtbUserRegister;
    with adtUserRegister do begin
      OnSortData:= AdapterSortData;
      LoadMode:= almBuffered;
      DataSource:= dtsUserRegister;
      Columns.Clear;
      AddAllFields;
      Active:= True;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfUserRegister.LoadGrid;
begin
  with grdList do begin
    Columns.Clear;
    ColumnCount:= adtUserRegister.Columns.Count;
    Adapter:= adtUserRegister;
    Columns[0].Width:= 0;
    Columns[0].Visible:= False;
    (*Columns[1].Width:= 125;

    Columns[2].Width:= 80;
    Columns[3].Width:= 80;
    Columns[4].Width:= 120;
    Columns[5].Width:= 60;
    Columns[6].Width:= 60;
    Columns[7].Width:= 60;

    Columns[8].Width:= 60;
    Columns[9].Width:= 60;
    Columns[10].Width:= 130;*)
    Columns[1].Width:= 80;
    Columns[2].Width:= 80;
    Columns[3].Width:= 120;
    Columns[4].Width:= 60;
    Columns[5].Width:= 60;
    Columns[6].Width:= 60;

    Columns[7].Width:= 60;
    Columns[8].Width:= 60;
    Columns[9].Width:= 130;
  end;
end;

procedure TfUserRegister.Refresh;
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
  if gusertype<> 2 then begin
    if gkick= True then begin
      TDialogService.MessageDialog('Sorry, you are temporarily banned from '+
        'this system. Please contact the relevant authorities.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0,
        nil);
      Exit;
    end;
  end;
  (*FSortColumn:= 'myid';
  FSortAsc:= False;*)
  FSortColumn:= 'urname';
  FSortAsc:= True;
  ClearAllControls;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbUserRegister.Locate(TcUserRegister.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  grdList.Sort(1, gsdNone);
end;

procedure TfUserRegister.FindData;
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
  if gusertype<> 2 then begin
    if gkick= True then begin
      TDialogService.MessageDialog('Sorry, you are temporarily banned from '+
        'this system. Please contact the relevant authorities.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbClose], TMsgDlgBtn.mbClose, 0,
        nil);
      Exit;
    end;
  end;
  (*FSortColumn:= 'myid';
  FSortAsc:= False;*)
  FSortColumn:= 'urname';
  FSortAsc:= True;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbUserRegister.Locate(TcUserRegister.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  //grdList.Sort(1, gsdNone);
  grdList.Sort(2, gsdNone);
end;

procedure TfUserRegister.rtlFindResize(Sender: TObject);
begin
  if (rtlFindWidth> 0) or (rtlFindHeight> 0) then begin
    with rtlFind do begin
      if (Width< rtlFindWidth) or (Width> rtlFindWidth) then begin
        Width:= rtlFindWidth;
      end;
      if (Height< rtlFindHeight) or (Height> rtlFindHeight) then begin
        Height:= rtlFindHeight;
      end;
    end;
  end;
end;

procedure TfUserRegister.FormDestroy(Sender: TObject);
begin
  FreeAndNil(adtUserRegister);
  FreeAndNil(dtsUserRegister);
  FreeAndNil(vtbUserRegister);
  fUserRegister:= nil;
end;

procedure TfUserRegister.grdListBeforeSortColumn(Sender: TObject;
  AColumn: Integer; var ACanSort: Boolean);
var
  ColName: string;
begin
  //stop sort builtin grid
  ACanSort:= False;

  case AColumn of
    0: ColName:= TcUserRegister.pkid;
    (*1: ColName:= 'myid';
    2: ColName:= 'urtype';
    3: ColName:= 'urname';
    4: ColName:= 'urfullname';
    5: ColName:= 'jbcode';
    6: ColName:= 'dmcode';
    7: ColName:= 'kick';
    8: ColName:= 'inactive';
    9: ColName:= 'edituser';
    10: ColName:= 'editdate';*)
    1: ColName:= 'urtype';
    2: ColName:= 'urname';
    3: ColName:= 'urfullname';
    4: ColName:= 'jbcode';
    5: ColName:= 'dmcode';
    6: ColName:= 'kick';
    7: ColName:= 'inactive';
    8: ColName:= 'edituser';
    9: ColName:= 'editdate';
  end;

  //save clicked column
  FSortColumn:= ColName;

  //change direction when clicking
  FSortAsc:= not FSortAsc;
  if FSortAsc= True then begin
    grdList.Sort(AColumn, gsdAscending);
  end else begin
    grdList.Sort(AColumn, gsdDescending);
  end;

  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus
      if vtbUserRegister.Locate(TcUserRegister.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
end;

procedure TfUserRegister.grdListCellClick(Sender: TObject; AColumn,
  ARow: Integer);
begin
  if grdList.RowCount> 1 then begin
  //Save Grid Focus;
    FocusID:= vtbUserRegister.FieldByName(TcUserRegister.pkid).AsString.Trim;
    FocusCol:= grdList.FocusedCell.Column;
  end;
end;

procedure TfUserRegister.grdListClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfUserRegister.grdListEnter(Sender: TObject);
begin
  TThread.ForceQueue(nil,
    procedure
    //for bug tmsfncdatagrid which lost focusing cell after tab from button
    begin
      if grdList.RowCount> 1 then begin
        grdList.SetFocus;
      end;
    end);
end;

procedure TfUserRegister.grdListGetCellClass(Sender: TObject; AColumn,
  ARow: Integer; var ACellClass: TTMSFNCDataGridCellClass);
begin
  if ARow> 0 then begin
    case AColumn of
      //7, 8: ACellClass:= TTMSFNCDataGridCheckBoxCell;
      6, 7: ACellClass:= TTMSFNCDataGridCheckBoxCell;
    end;
  end;
end;

procedure TfUserRegister.grdListGetCellData(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
begin
  if ACell.Row= 0 then begin
    case ACell.Column of
      (*1: AData:= 'Number';
      2: AData:= 'UserType';
      3: AData:= 'Username';
      4: AData:= 'Fullname';
      5: AData:= 'Job';
      6: AData:= 'Dept';
      7: AData:= 'Kicked';
      8: AData:= 'Deleted';
      9: AData:= 'EditUser';
      10: AData:= 'EditDate';*)
      1: AData:= 'UserType';
      2: AData:= 'Username';
      3: AData:= 'Fullname';
      4: AData:= 'Job';
      5: AData:= 'Dept';
      6: AData:= 'Kicked';
      7: AData:= 'Deleted';
      8: AData:= 'EditUser';
      9: AData:= 'EditDate';
    end;
  end;
end;

procedure TfUserRegister.grdListGetCellLayout(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    with ACell.Layout do begin
      //if grdList.Booleans[8, ACell.Row]= True then begin
      if grdList.Booleans[7, ACell.Row]= True then begin
        if themedark= True then begin
          Fill.Color:= darkcolor;
        end else begin
          Fill.Color:= lightcolor;
        end;
      end;
      case ACell.Column of
        (*1, 2, 3, 4, 5, 6, 9: TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
        10: TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;*)
        0, 1, 2, 3, 4, 5, 8: TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
        9: TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;
      end;
    end;
  end;
end;

procedure TfUserRegister.grdListGetCellProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    case ACell.Column of
      //7, 8: begin
      6, 7: begin
        ACell.AsCheckBoxCell.ControlPosition:= gcpCenterCenter;
        ACell.AsCheckBoxCell.CheckBox.Enabled:= False;
      end;
    end;
  end;
end;

procedure TfUserRegister.grdListGetInplaceEditorProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; AInplaceEditor: TTMSFNCDataGridInplaceEditor;
  AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
begin
  if ACell.Row> 0 then begin
    case ACell.Column of
      (*1, 2, 3, 4, 5, 6, 9, 10: begin
        with AInplaceEditor do begin
          AsEdit.ReadOnly:= True;
          if themedark= True then begin
            AsEdit.FontColor:= TAlphaColors.White;
          end else begin
            AsEdit.FontColor:= TAlphaColors.Black;
          end;
        end;
      end;
      7, 8: begin
        AInplaceEditor.AsComboBox.Enabled:= False;
      end;*)
      0, 1, 2, 3, 4, 5, 8, 9: begin
        with AInplaceEditor do begin
          AsEdit.ReadOnly:= True;
          if themedark= True then begin
            AsEdit.FontColor:= TAlphaColors.White;
          end else begin
            AsEdit.FontColor:= TAlphaColors.Black;
          end;
        end;
      end;
      6, 7: begin
        AInplaceEditor.AsComboBox.Enabled:= False;
      end;
    end;
  end;
end;

end.
