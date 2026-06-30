unit uState;

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
  TfState = class(TForm)
    lytState: TLayout;
    lytTool: TLayout;
    btnNew: TTMSFNCButton;
    btnFind: TTMSFNCButton;
    btnRefresh: TTMSFNCButton;
    btnView: TTMSFNCButton;
    btnEdit: TTMSFNCButton;
    grdList: TTMSFNCDataGrid;
    rtlFind: TRectangle;
    lytHeader: TLayout;
    btnClose: TTMSFNCButton;
    Label1: TLabel;
    lytAction: TLayout;
    btnClear: TTMSFNCButton;
    btnOK: TTMSFNCButton;
    sdeFind: TShadowEffect;
    Label4: TLabel;
    Label5: TLabel;
    edtCode: TEdit;
    edtDescription: TEdit;
    Label3: TLabel;
    edtCountry: TEdit;
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
    procedure edtCodeKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtDescriptionKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtCountryKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure lblCaptionClick(Sender: TObject);
  private
    procedure HidertlFind;
    procedure LoadData;
    procedure AdapterSortData(Sender: TObject);
    procedure LoadGrid;
    procedure AddPageForm;
    procedure ClearAllControls;
  public
    procedure Refresh;
    procedure FindData;
  end;

var
  fState: TfState;

implementation

{$R *.fmx}

uses uClientSet, uClientCmd, cState, uClientFrmCursor, uBusamAutoNusantara,
  uStateInput;

var
  vtbState: TVirtualTable;
  dtsState: TUniDataSource;
  adtState: TTMSFNCDataGridDatabaseAdapter;
  FSortColumn, FocusID: string;
  FSortAsc: boolean;
  FocusCol: integer;
  rtlFindWidth, rtlFindHeight: single;

procedure TfState.AddPageForm;
begin
  fStateInput:= TfStateInput.Create(fMain);
  with fMain.pclMain do begin
    AddPage('State');
    SelectTab(Pages.Count- 1);
    TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
    with Pages.Tabs[Pages.Count- 1] do begin
      if fMain.btnState.Visible= True then begin
        Bitmaps.AddBitmapName(fMain.btnState.BitmapName);
      end;
      Text:= 'State';
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
  fStateInput.lytStateInput.Parent:=
    fMain.pclMain.PageContainers[fMain.pclMain.Pages.Count- 1];
end;

procedure TfState.btnClearClick(Sender: TObject);
begin
  ClearAllControls;
end;

procedure TfState.btnCloseClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfState.btnEditClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fStateInput')= True then begin
      tabstate:= fStateInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fStateInput.lblAction.Text<> 'EDIT' then begin
        TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+' state. To open Edit Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fStateInput.lblAction.Text= 'EDIT' then begin
        if vtbState.FieldByName(TcState.pkid).AsString<>
          fStateInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+' state at number '+
            fStateInput.mynumber+ '. To open Edit Tab, please close the '+
            'exiting tab first for your '+
            vtbState.FieldByName(TcState.pkid).AsString.Trim+ ' tab.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fStateInput.lytStateInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fStateInput do begin
        mynumber:=
          vtbState.FieldByName(TcState.pkid).AsString.Trim;
        CommandPass(btnEdit.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfState.btnFindClick(Sender: TObject);
begin
  if rtlFind.Visible= False then begin
    rtlFind.Visible:= True;
    rtlFind.BringToFront;
    //edtNumFrom.SetFocus;
    edtCode.SetFocus;
  end else begin
    HidertlFind;
    btnFind.SetFocus;
  end;
end;

procedure TfState.btnNewClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fStateInput')= True then begin
      tabstate:= fStateInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fStateInput.lblAction.Text<> 'NEW' then begin
        TDialogService.MessageDialog('Sorry, New Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open New Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end;
      fMain.pclMain.SelectTab((
        fStateInput.lytStateInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      fStateInput.CommandPass(btnNew.Name);
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfState.btnOKClick(Sender: TObject);
begin
  FindData;
end;

procedure TfState.FindData;
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
  FSortColumn:= 'stcode';
  FSortAsc:= True;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbState.Locate(TcState.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  grdList.Sort(1, gsdNone);
end;

procedure TfState.btnRefreshClick(Sender: TObject);
begin
  HidertlFind;
  Refresh;
end;

procedure TfState.Refresh;
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
  FSortColumn:= 'stcode';
  FSortAsc:= True;
  ClearAllControls;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbState.Locate(TcState.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  grdList.Sort(1, gsdNone);
end;

procedure TfState.rtlFindResize(Sender: TObject);
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

procedure TfState.ClearAllControls;
begin
  (*cmbLocation.Text:= gserverloc.Trim;
  edtNumFrom.Text:= '';
  edtNumTo.Text:= '';*)
  edtCode.Text:= '';
  edtDescription.Text:= '';
  edtCountry.Text:= '';
end;

procedure TfState.edtCodeKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtDescription.SetFocus;
  end;
end;

procedure TfState.edtCountryKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnOK.SetFocus;
  end;
end;

procedure TfState.edtDescriptionKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtCountry.SetFocus;
  end;
end;

procedure TfState.btnViewClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fStateInput')= True then begin
      tabstate:= fStateInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fStateInput.lblAction.Text<> 'VIEW' then begin
        TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open View Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fStateInput.lblAction.Text= 'VIEW' then begin
        if vtbState.FieldByName(TcState.pkid).AsString<>
          fStateInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+ ' state at number '+
            fStateInput.mynumber+ '. To open View Tab, please close the '+
            'exiting tab first for your '+
            vtbState.FieldByName(TcState.pkid).AsString.Trim+' tab.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fStateInput.lytStateInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fStateInput do begin
        mynumber:= vtbState.FieldByName(TcState.pkid).AsString.Trim;
        CommandPass(btnView.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfState.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfState.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  grdList.OnExit:= nil;
  grdList.OnEnter:= nil;
  grdList.OnCellClick:= nil;
end;

procedure TfState.FormCreate(Sender: TObject);
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
  HidertlFind;
  vtbState:= TVirtualTable.Create(Self);
  dtsState:= TUniDataSource.Create(Self);
  adtState:= TTMSFNCDataGridDatabaseAdapter.Create(Self);
  (*cmbLocation.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  cmbLocation.CharCase:= TEditCharCase.ecUpperCase;
  cmbLocation.Text:= gserverloc.ToUpper;
  edtNumFrom.FilterChar:= '0123456789';
  edtNumFrom.TextAlign:= TTextAlign.Trailing;
  edtNumTo.FilterChar:= '0123456789';
  edtNumTo.TextAlign:= TTextAlign.Trailing;*)

  edtCode.MaxLength:= 2;
  edtCode.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtCode.CharCase:= TEditCharCase.ecUpperCase;
  edtDescription.MaxLength:= 50;
  edtDescription.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtCountry.MaxLength:= 50;
  edtCountry.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
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
  FSortColumn:= 'stcode';
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
      FocusID:= vtbState.FieldByName(TcState.pkid).AsString.Trim;
      FocusCol:= FocusedCell.Column;
    end;
  end;
end;

procedure TfState.LoadData;
var
  JSONState(*, JSONNumberLoc*): string;
  (*ObjNumberLoc: TJSONObject;
  ArrNumberLoc: TJSONArray;
  i: integer;*)
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    (*JSONNumberLoc:= '';
    JSONNumberLoc:= TcState.GetNumberLoc;
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
    JSONState:= '';
    JSONState:= TcState.IndexState(FSortColumn, FSortAsc,
      (*cmbLocation.Text.Trim, edtNumFrom.Text.Trim, edtNumTo.Text.Trim,*)
      edtCode.Text.Trim, edtDescription.Text.Trim, edtCountry.Text.Trim);
    with vtbState do begin
      DisableControls;
      try
        Active:= False;
        IndexFieldNames:= '';
        DeleteFields;
        AddField(TcState.pkid, ftString, 50, True);
        //AddField('myid', ftString, 50, True);
        AddField('stcode', ftString, 2, True);
        AddField('description', ftString, 50, True);
        AddField('country', ftString, 50, True);
        AddField('inactive', ftBoolean, 0, True);
        AddField('edituser', ftString, 20, True);
        AddField('editdate', ftString, 20, True);
        IndexFieldNames:= '';
        CachedUpdates:= False;
        Active:= True;
        TmClientCmd.JSONToVirtualTable(JSONState, vtbState);
      finally
        EnableControls;
      end;
    end;
    dtsState.DataSet:= vtbState;
    with adtState do begin
      OnSortData:= AdapterSortData;
      LoadMode:= almBuffered;
      DataSource:= dtsState;
      Columns.Clear;
      AddAllFields;
      Active:= True;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfState.LoadGrid;
begin
  with grdList do begin
    Columns.Clear;
    ColumnCount:= adtState.Columns.Count;
    Adapter:= adtState;
    Columns[0].Width:= 0;
    Columns[0].Visible:= False;
    (*Columns[1].Width:= 125;

    Columns[2].Width:= 60;
    Columns[3].Width:= 170;
    Columns[4].Width:= 70;

    Columns[5].Width:= 60;
    Columns[6].Width:= 60;
    Columns[7].Width:= 130;*)
    Columns[1].Width:= 60;
    Columns[2].Width:= 170;
    Columns[3].Width:= 70;

    Columns[4].Width:= 60;
    Columns[5].Width:= 60;
    Columns[6].Width:= 130;
  end;
end;

procedure TfState.AdapterSortData(Sender: TObject);
begin
  TmClientCmd.AdapterSorting(grdList, adtState);
end;

procedure TfState.HidertlFind;
begin
  if rtlFind.Visible= True then begin
    rtlFind.SendToBack;
    rtlFind.Visible:= False;
  end;
end;

procedure TfState.lblCaptionClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfState.FormDestroy(Sender: TObject);
begin
  FreeAndNil(adtState);
  FreeAndNil(dtsState);
  FreeAndNil(vtbState);
  fState:= nil;
end;

procedure TfState.grdListBeforeSortColumn(Sender: TObject; AColumn: Integer;
  var ACanSort: Boolean);
var
  ColName: string;
begin
  //stop sort builtin grid
  ACanSort:= False;

  case AColumn of
    0: ColName:= TcState.pkid;
    (*1: ColName:= 'myid';
    2: ColName:= 'stcode';
    3: ColName:= 'description';
    4: ColName:= 'country';
    5: ColName:= 'inactive';
    6: ColName:= 'edituser';
    7: ColName:= 'editdate';*)
    1: ColName:= 'stcode';
    2: ColName:= 'description';
    3: ColName:= 'country';
    4: ColName:= 'inactive';
    5: ColName:= 'edituser';
    6: ColName:= 'editdate';
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
      if vtbState.Locate(TcState.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
end;

procedure TfState.grdListCellClick(Sender: TObject; AColumn, ARow: Integer);
begin
  if grdList.RowCount> 1 then begin
  //Save Grid Focus;
    FocusID:= vtbState.FieldByName(TcState.pkid).AsString.Trim;
    FocusCol:= grdList.FocusedCell.Column;
  end;
end;

procedure TfState.grdListClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfState.grdListEnter(Sender: TObject);
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

procedure TfState.grdListGetCellClass(Sender: TObject; AColumn, ARow: Integer;
  var ACellClass: TTMSFNCDataGridCellClass);
begin
  if ARow> 0 then begin
    case AColumn of
      //5: ACellClass:= TTMSFNCDataGridCheckBoxCell;
      4: ACellClass:= TTMSFNCDataGridCheckBoxCell;
    end;
  end;
end;

procedure TfState.grdListGetCellData(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
begin
  if ACell.Row= 0 then begin
    case ACell.Column of
      (*1: AData:= 'Number';
      2: AData:= 'Code';
      3: AData:= 'Description';
      4: AData:= 'Country';
      5: AData:= 'Deleted';
      6: AData:= 'EditUser';
      7: AData:= 'EditDate';*)
      1: AData:= 'Code';
      2: AData:= 'Description';
      3: AData:= 'Country';
      4: AData:= 'Deleted';
      5: AData:= 'EditUser';
      6: AData:= 'EditDate';
    end;
  end;
end;

procedure TfState.grdListGetCellLayout(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    with ACell.Layout do begin
      //if grdList.Booleans[5, ACell.Row]= True then begin
      if grdList.Booleans[4, ACell.Row]= True then begin
        if themedark= True then begin
          Fill.Color:= darkcolor;
        end else begin
          Fill.Color:= lightcolor;
        end;
      end;
      case ACell.Column of
        (*1, 2, 3, 4, 6: TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
        7: TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;*)
        0, 1, 2, 3, 5: TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
        6: TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;
      end;
    end;
  end;
end;

procedure TfState.grdListGetCellProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    case ACell.Column of
      //5: begin
      4: begin
        ACell.AsCheckBoxCell.ControlPosition:= gcpCenterCenter;
        ACell.AsCheckBoxCell.CheckBox.Enabled:= False;
      end;
    end;
  end;
end;

procedure TfState.grdListGetInplaceEditorProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; AInplaceEditor: TTMSFNCDataGridInplaceEditor;
  AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
begin
  if ACell.Row> 0 then begin
    case ACell.Column of
      //1, 2, 3, 4, 6, 7: begin
      0, 1, 2, 3, 5, 6: begin
        with AInplaceEditor do begin
          AsEdit.ReadOnly:= True;
          if themedark= True then begin
            AsEdit.FontColor:= TAlphaColors.White;
          end else begin
            AsEdit.FontColor:= TAlphaColors.Black;
          end;
        end;
      end;
      //5: begin
      4: begin
        AInplaceEditor.AsComboBox.Enabled:= False;
      end;
    end;
  end;
end;

end.
