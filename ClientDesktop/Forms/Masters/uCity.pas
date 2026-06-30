unit uCity;

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
  TfCity = class(TForm)
    lytCity: TLayout;
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
    edtState: TEdit;
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
    procedure edtStateKeyDown(Sender: TObject; var Key: Word;
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
  fCity: TfCity;

implementation

{$R *.fmx}

uses uClientSet, uClientCmd, cCity, uClientFrmCursor, uBusamAutoNusantara,
  uCityInput;

var
  vtbCity: TVirtualTable;
  dtsCity: TUniDataSource;
  adtCity: TTMSFNCDataGridDatabaseAdapter;
  FSortColumn, FocusID: string;
  FSortAsc: boolean;
  FocusCol: integer;
  rtlFindWidth, rtlFindHeight: single;

procedure TfCity.AddPageForm;
begin
  fCityInput:= TfCityInput.Create(fMain);
  with fMain.pclMain do begin
    AddPage('City');
    SelectTab(Pages.Count- 1);
    TmClientCmd.TMSTabColor(Pages.Tabs[Pages.Count- 1]);
    with Pages.Tabs[Pages.Count- 1] do begin
      if fMain.btnState.Visible= True then begin
        Bitmaps.AddBitmapName(fMain.btnState.BitmapName);
      end;
      Text:= 'City';
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
  fCityInput.lytCityInput.Parent:=
    fMain.pclMain.PageContainers[fMain.pclMain.Pages.Count- 1];
end;

procedure TfCity.btnClearClick(Sender: TObject);
begin
  ClearAllControls;
end;

procedure TfCity.btnCloseClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfCity.btnEditClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fCityInput')= True then begin
      tabstate:= fCityInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fCityInput.lblAction.Text<> 'EDIT' then begin
        TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+' state. To open Edit Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fCityInput.lblAction.Text= 'EDIT' then begin
        if vtbCity.FieldByName(TcCity.pkid).AsString<>
          fCityInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, Edit Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+' state at number '+
            fCityInput.mynumber+ '. To open Edit Tab, please close the '+
            'exiting tab first for your '+
            vtbCity.FieldByName(TcCity.pkid).AsString.Trim+ ' tab.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fCityInput.lytCityInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fCityInput do begin
        mynumber:=
          vtbCity.FieldByName(TcCity.pkid).AsString.Trim;
        CommandPass(btnEdit.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCity.btnFindClick(Sender: TObject);
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

procedure TfCity.btnNewClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fCityInput')= True then begin
      tabstate:= fCityInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fCityInput.lblAction.Text<> 'NEW' then begin
        TDialogService.MessageDialog('Sorry, New Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open New Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end;
      fMain.pclMain.SelectTab((
        fCityInput.lytCityInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      fCityInput.CommandPass(btnNew.Name);
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCity.btnOKClick(Sender: TObject);
begin
  FindData;
end;

procedure TfCity.FindData;
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
  FSortColumn:= 'ctcode';
  FSortAsc:= True;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbCity.Locate(TcCity.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  grdList.Sort(1, gsdNone);
end;

procedure TfCity.btnRefreshClick(Sender: TObject);
begin
  HidertlFind;
  Refresh;
end;

procedure TfCity.Refresh;
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
  FSortColumn:= 'ctcode';
  FSortAsc:= True;
  ClearAllControls;
  LoadData;
  LoadGrid;
  with grdList do begin
    if RowCount> 1 then begin
      //Restore Grid Focus col (-1 to protecting moving focus column)
      if vtbCity.Locate(TcCity.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol- 1, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
  grdList.Sort(1, gsdNone);
end;

procedure TfCity.rtlFindResize(Sender: TObject);
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

procedure TfCity.ClearAllControls;
begin
  (*cmbLocation.Text:= gserverloc.Trim;
  edtNumFrom.Text:= '';
  edtNumTo.Text:= '';*)
  edtCode.Text:= '';
  edtDescription.Text:= '';
  edtState.Text:= '';
end;

procedure TfCity.edtCodeKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtDescription.SetFocus;
  end;
end;

procedure TfCity.edtDescriptionKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    edtState.SetFocus;
  end;
end;

procedure TfCity.edtStateKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key= vkReturn then begin
    btnOK.SetFocus;
  end;
end;

procedure TfCity.btnViewClick(Sender: TObject);
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
    if TmClientCmd.IsFormOpen('fCityInput')= True then begin
      tabstate:= fCityInput.lblAction.Text;
      if tabstate= '' then begin
        tabstate:= 'CANCEL';
      end;
      if fCityInput.lblAction.Text<> 'VIEW' then begin
        TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
          'it is already active in '+ tabstate.Trim+ ' state. To open View Tab, '+
          'please close the existing tab first.', TMsgDlgType.mtWarning,
          [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end else if fCityInput.lblAction.Text= 'VIEW' then begin
        if vtbCity.FieldByName(TcCity.pkid).AsString<>
          fCityInput.mynumber then begin
          TDialogService.MessageDialog('Sorry, View Tab cannot be opened because '+
            'it is already active in '+ tabstate.Trim+ ' state at number '+
            fCityInput.mynumber+ '. To open View Tab, please close the '+
            'exiting tab first for your '+
            vtbCity.FieldByName(TcCity.pkid).AsString.Trim+' tab.',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
      end;
      fMain.pclMain.SelectTab((fCityInput.lytCityInput.GetParentComponent as
        TTMSFNCPageControlContainer).PageIndex);
    end else begin
      AddPageForm;
      with fCityInput do begin
        mynumber:= vtbCity.FieldByName(TcCity.pkid).AsString.Trim;
        CommandPass(btnView.Name);
      end;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCity.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfCity.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  grdList.OnExit:= nil;
  grdList.OnEnter:= nil;
  grdList.OnCellClick:= nil;
end;

procedure TfCity.HidertlFind;
begin
  if rtlFind.Visible= True then begin
    rtlFind.SendToBack;
    rtlFind.Visible:= False;
  end;
end;

procedure TfCity.lblCaptionClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfCity.FormCreate(Sender: TObject);
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
  vtbCity:= TVirtualTable.Create(Self);
  dtsCity:= TUniDataSource.Create(Self);
  adtCity:= TTMSFNCDataGridDatabaseAdapter.Create(Self);
  (*cmbLocation.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  cmbLocation.CharCase:= TEditCharCase.ecUpperCase;
  cmbLocation.Text:= gserverloc.ToUpper;
  edtNumFrom.FilterChar:= '0123456789';
  edtNumFrom.TextAlign:= TTextAlign.Trailing;
  edtNumTo.FilterChar:= '0123456789';
  edtNumTo.TextAlign:= TTextAlign.Trailing;*)

  edtCode.MaxLength:= 3;
  edtCode.FilterChar:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtCode.CharCase:= TEditCharCase.ecUpperCase;
  edtDescription.MaxLength:= 50;
  edtDescription.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  edtState.MaxLength:= 50;
  edtState.FilterChar:= ' .abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
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
  FSortColumn:= 'ctcode';
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
      FocusID:= vtbCity.FieldByName(TcCity.pkid).AsString.Trim;
      FocusCol:= FocusedCell.Column;
    end;
  end;
end;

procedure TfCity.LoadData;
var
  JSONCity(*, JSONNumberLoc*): string;
  (*ObjNumberLoc: TJSONObject;
  ArrNumberLoc: TJSONArray;
  i: integer;*)
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    (*JSONNumberLoc:= '';
    JSONNumberLoc:= TcCity.GetNumberLoc;
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
    JSONCity:= '';
    JSONCity:= TcCity.IndexCity(FSortColumn, FSortAsc,
      (*cmbLocation.Text.Trim, edtNumFrom.Text.Trim, edtNumTo.Text.Trim,*)
      edtCode.Text.Trim, edtDescription.Text.Trim, edtState.Text.Trim);
    with vtbCity do begin
      DisableControls;
      try
        Active:= False;
        IndexFieldNames:= '';
        DeleteFields;
        AddField(TcCity.pkid, ftString, 50, True);
        //AddField('myid', ftString, 50, True);
        AddField('ctcode', ftString, 3, True);
        AddField('description', ftString, 50, True);
        AddField('state', ftString, 50, True);
        AddField('inactive', ftBoolean, 0, True);
        AddField('edituser', ftString, 20, True);
        AddField('editdate', ftString, 20, True);
        IndexFieldNames:= '';
        CachedUpdates:= False;
        Active:= True;
        TmClientCmd.JSONToVirtualTable(JSONCity, vtbCity);
      finally
        EnableControls;
      end;
    end;
    dtsCity.DataSet:= vtbCity;
    with adtCity do begin
      OnSortData:= AdapterSortData;
      LoadMode:= almBuffered;
      DataSource:= dtsCity;
      Columns.Clear;
      AddAllFields;
      Active:= True;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfCity.LoadGrid;
begin
  with grdList do begin
    Columns.Clear;
    ColumnCount:= adtCity.Columns.Count;
    Adapter:= adtCity;
    Columns[0].Width:= 0;
    Columns[0].Visible:= False;
    (*Columns[1].Width:= 125;

    Columns[2].Width:= 60;
    Columns[3].Width:= 170;
    Columns[4].Width:= 170;

    Columns[5].Width:= 60;
    Columns[6].Width:= 60;
    Columns[7].Width:= 130;*)
    Columns[1].Width:= 60;
    Columns[2].Width:= 170;
    Columns[3].Width:= 170;

    Columns[4].Width:= 60;
    Columns[5].Width:= 60;
    Columns[6].Width:= 130;
  end;
end;

procedure TfCity.AdapterSortData(Sender: TObject);
begin
  TmClientCmd.AdapterSorting(grdList, adtCity);
end;

procedure TfCity.FormDestroy(Sender: TObject);
begin
  FreeAndNil(adtCity);
  FreeAndNil(dtsCity);
  FreeAndNil(vtbCity);
  fCity:= nil;
end;

procedure TfCity.grdListBeforeSortColumn(Sender: TObject; AColumn: Integer;
  var ACanSort: Boolean);
var
  ColName: string;
begin
  //stop sort builtin grid
  ACanSort:= False;

  case AColumn of
    0: ColName:= TcCity.pkid;
    (*1: ColName:= 'myid';
    2: ColName:= 'ctcode';
    3: ColName:= 'description';
    4: ColName:= 'state';
    5: ColName:= 'inactive';
    6: ColName:= 'edituser';
    7: ColName:= 'editdate';*)
    1: ColName:= 'ctcode';
    2: ColName:= 'description';
    3: ColName:= 'state';
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
      if vtbCity.Locate(TcCity.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
end;

procedure TfCity.grdListCellClick(Sender: TObject; AColumn, ARow: Integer);
begin
  if grdList.RowCount> 1 then begin
  //Save Grid Focus;
    FocusID:= vtbCity.FieldByName(TcCity.pkid).AsString.Trim;
    FocusCol:= grdList.FocusedCell.Column;
  end;
end;

procedure TfCity.grdListClick(Sender: TObject);
begin
  HidertlFind;
end;

procedure TfCity.grdListEnter(Sender: TObject);
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

procedure TfCity.grdListGetCellClass(Sender: TObject; AColumn, ARow: Integer;
  var ACellClass: TTMSFNCDataGridCellClass);
begin
  if ARow> 0 then begin
    case AColumn of
      //5: ACellClass:= TTMSFNCDataGridCheckBoxCell;
      4: ACellClass:= TTMSFNCDataGridCheckBoxCell;
    end;
  end;
end;

procedure TfCity.grdListGetCellData(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
begin
  if ACell.Row= 0 then begin
    case ACell.Column of
      (*1: AData:= 'Number';
      2: AData:= 'Code';
      3: AData:= 'Description';
      4: AData:= 'State';
      5: AData:= 'Deleted';
      6: AData:= 'EditUser';
      7: AData:= 'EditDate';*)
      1: AData:= 'Code';
      2: AData:= 'Description';
      3: AData:= 'State';
      4: AData:= 'Deleted';
      5: AData:= 'EditUser';
      6: AData:= 'EditDate';
    end;
  end;
end;

procedure TfCity.grdListGetCellLayout(Sender: TObject;
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

procedure TfCity.grdListGetCellProperties(Sender: TObject;
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

procedure TfCity.grdListGetInplaceEditorProperties(Sender: TObject;
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
