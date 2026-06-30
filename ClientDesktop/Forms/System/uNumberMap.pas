unit uNumberMap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.JSON, System.Generics.Collections, FMX.Dialogs, FMX.Types, FMX.Controls,
  (*Adapter*)FMX.TMSFNCCustomComponent, FMX.TMSFNCDataGridDatabaseAdapter(*Adapter*),
  (*DBAware*)Uni, Data.DB, DBAccess(*DBAware*), FMX.DialogService, VirtualTable,
  FMX.Forms, FMX.Graphics, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.TMSFNCButton, FMX.Layouts,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  System.Rtti, FMX.TMSFNCDataGridCell, FMX.TMSFNCDataGridData,
  FMX.TMSFNCDataGridBase, FMX.TMSFNCDataGridCore, FMX.TMSFNCDataGridRenderer,
  FMX.TMSFNCCustomControl, FMX.TMSFNCDataGrid, FMX.Effects;

type
  TfNumberMap = class(TForm)
    lytHeader: TLayout;
    btnClose: TTMSFNCButton;
    Label1: TLabel;
    rtlNumberMap: TRectangle;
    grdList: TTMSFNCDataGrid;
    sdeNumberMap: TShadowEffect;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
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
    procedure grdListCellClick(Sender: TObject; AColumn, ARow: Integer);
  private
    procedure LoadData;
    procedure AdapterSortData(Sender: TObject);
    procedure LoadGrid;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fNumberMap: TfNumberMap;

implementation

{$R *.fmx}

uses uBusamAutoNusantara, uClientSet, uClientCmd, uClientFrmCursor, cNumberMap;

var
  vtbNumberMap: TVirtualTable;
  dtsNumberMap: TUniDataSource;
  adtNumberMap: TTMSFNCDataGridDatabaseAdapter;
  FSortColumn, FocusID: string;
  FSortAsc: boolean;
  FocusCol: integer;

procedure TfNumberMap.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfNumberMap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfNumberMap.FormCreate(Sender: TObject);
begin
  fMain.SetrtlModal;
  TmClientSet.EnableDragResize(rtlNumberMap);//move and resize control
  with rtlNumberMap do begin
    Align:= TAlignLayout.None;
    Stroke.Color:= strkcolor;
    Stroke.Thickness:= strkthickness;
    if themedark= True then begin
      Fill.Color:= darkcolor;
      Fill.Kind:= TBrushKind.Solid;
    end;
  end;
  with sdeNumberMap do begin
    Distance:= shdwdistance;
    Opacity:= shdwopacity;
    ShadowColor:= shdwcolor;
  end;
  vtbNumberMap:= TVirtualTable.Create(Self);
  dtsNumberMap:= TUniDataSource.Create(Self);
  adtNumberMap:= TTMSFNCDataGridDatabaseAdapter.Create(Self);
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
  LoadData;
  LoadGrid;
  FSortColumn:= 'myid';
  FSortAsc:= False;
  with TmClientCmd do begin
    FillTMSColor(grdList.Fill, False, False);
    FillBrushColor(rtlNumberMap.Fill, False, False, False);
  end;
  with grdList do begin
    if (RowCount)> 1 then begin
      SelectCell(MakeCell(1, 1));
    //Save Grid Focus;
      FocusID:= vtbNumberMap.FieldByName(TcNumberMap.pkid).AsString.Trim;
      FocusCol:= FocusedCell.Column;
    end;
  end;
end;

procedure TfNumberMap.LoadData;
var
  JSONNumberMap: string;
begin
  TmClientFrmCursor.CursorOverride:= crHourGlass;
  try
    JSONNumberMap:= '';
    JSONNumberMap:= TcNumberMap.IndexNumberMap(FSortColumn, FSortAsc);
    with vtbNumberMap do begin
      DisableControls;
      try
        Active:= False;
        IndexFieldNames:= '';
        DeleteFields;
        AddField(TcNumberMap.pkid, ftString, 50, True);
        AddField('myid', ftString, 50, True);
        AddField('tbcode', ftString, 4, True);
        AddField('description', ftString, 25, True);
        IndexFieldNames:= '';
        CachedUpdates:= False;
        Active:= True;
        TmClientCmd.JSONToVirtualTable(JSONNumberMap, vtbNumberMap);
      finally
        EnableControls;
      end;
    end;
    dtsNumberMap.DataSet:= vtbNumberMap;
    with adtNumberMap do begin
      OnSortData:= AdapterSortData;
      LoadMode:= almBuffered;
      DataSource:= dtsNumberMap;
      Columns.Clear;
      AddAllFields;
      Active:= True;
    end;
  finally
    TmClientFrmCursor.CursorOverride:= crDefault;
  end;
end;

procedure TfNumberMap.LoadGrid;
begin
  with grdList do begin
    Columns.Clear;
    ColumnCount:= adtNumberMap.Columns.Count;
    Adapter:= adtNumberMap;
    Columns[0].Width:= 0;
    Columns[0].Visible:= False;
    Columns[1].Width:= 125;

    Columns[2].Width:= 60;
    Columns[3].Width:= 150;
  end;
end;

procedure TfNumberMap.AdapterSortData(Sender: TObject);
begin
  TmClientCmd.AdapterSorting(grdList, adtNumberMap);
end;

procedure TfNumberMap.FormDestroy(Sender: TObject);
begin
  FreeAndNil(adtNumberMap);
  FreeAndNil(dtsNumberMap);
  FreeAndNil(vtbNumberMap);
  FreeAndNil(fMain.lytModal);
  FreeAndNil(fMain.rtlModal);
  fMain.lytMain.Enabled:= True;
  fMain.btnMenu.SetFocus;
  fNumberMap:= nil;
end;

procedure TfNumberMap.grdListBeforeSortColumn(Sender: TObject; AColumn: Integer;
  var ACanSort: Boolean);
var
  ColName: string;
begin
  //stop sort builtin grid
  ACanSort:= False;

  case AColumn of
    0: ColName:= TcNumberMap.pkid;
    1: ColName:= 'myid';
    2: ColName:= 'tbcode';
    3: ColName:= 'description';
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
      if vtbNumberMap.Locate(TcNumberMap.pkid, FocusID, [])= True
      then begin
        SelectCell(MakeCell(FocusCol, FocusedCell.Row));
      end else begin
        SelectCell(MakeCell(1, 1));
      end;
    end;
  end;
end;

procedure TfNumberMap.grdListCellClick(Sender: TObject; AColumn, ARow: Integer);
begin
  if grdList.RowCount> 1 then begin
  //Save Grid Focus;
    FocusID:= vtbNumberMap.FieldByName(TcNumberMap.pkid).AsString.Trim;
    FocusCol:= grdList.FocusedCell.Column;
  end;
end;

procedure TfNumberMap.grdListEnter(Sender: TObject);
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

procedure TfNumberMap.grdListGetCellData(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; var AData: TTMSFNCDataGridCellValue);
begin
  if ACell.Row= 0 then begin
    case ACell.Column of
      1: AData:= 'Number';
      2: AData:= 'Code';
      3: AData:= 'Description';
    end;
  end;
end;

procedure TfNumberMap.grdListGetCellLayout(Sender: TObject;
  ACell: TTMSFNCDataGridCell);
begin
  if ACell.Row> 0 then begin
    with ACell.Layout do begin
      case ACell.Column of
        1, 2, 3: TextAlign:= TTMSFNCGraphicsTextAlign.gtaLeading;
      end;
    end;
  end;
end;

procedure TfNumberMap.grdListGetInplaceEditorProperties(Sender: TObject;
  ACell: TTMSFNCDataGridCellCoord; AInplaceEditor: TTMSFNCDataGridInplaceEditor;
  AInplaceEditorType: TTMSFNCDataGridInplaceEditorType);
begin
  if ACell.Row> 0 then begin
    case ACell.Column of
      1, 2, 3: begin
        with AInplaceEditor do begin
          AsEdit.ReadOnly:= True;
          if themedark= True then begin
            AsEdit.FontColor:= TAlphaColors.White;
          end else begin
            AsEdit.FontColor:= TAlphaColors.Black;
          end;
        end;
      end;
    end;
  end;
end;

end.
