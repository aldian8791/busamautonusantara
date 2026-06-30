unit uPrintReport;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Character, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.Edit, FMX.TMSFNCPageControl, FMX.TMSFNCCustomControl, FMX.TMSFNCTabSet,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.TMSFNCButton, FMX.Layouts,
  System.Rtti, FMX.TMSFNCDataGridCell, FMX.TMSFNCDataGridData,
  FMX.TMSFNCDataGridBase, FMX.TMSFNCDataGridCore, FMX.TMSFNCDataGridRenderer,
  FMX.TMSFNCDataGrid, FMX.DateTimeCtrls;

type
  TfPrintReport = class(TForm)
    lytPrintReport: TLayout;
    lytTool: TLayout;
    btnSave: TTMSFNCButton;
    btnDelete: TTMSFNCButton;
    pclFind: TTMSFNCPageControl;
    tbsGeneral: TTMSFNCPageControlContainer;
    Label4: TLabel;
    edtNumFrom: TEdit;
    Label13: TLabel;
    lblCaption: TLabel;
    grdList: TTMSFNCDataGrid;
    edtNumTo: TEdit;
    detFrom: TDateEdit;
    Label3: TLabel;
    detTo: TDateEdit;
    Label5: TLabel;
    Label1: TLabel;
    edtPrintUser: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrintReport: TfPrintReport;

implementation

{$R *.fmx}

uses uClientCmd, uClientFrmCursor;

procedure TfPrintReport.btnSaveClick(Sender: TObject);
begin
  if not edtNumFrom.Text.IsEmpty= True then begin
    if CharInSet(edtNumFrom.Text[1], ['a'..'z', 'A'..'Z'])= True then showmessage('huruf');
    if edtNumFrom.Text[1].IsDigit= True then showmessage('angka');
  end;
end;

procedure TfPrintReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= TCloseAction.caFree;
end;

procedure TfPrintReport.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  grdList.OnExit:= nil;
  grdList.OnEnter:= nil;
  grdList.OnCellClick:= nil;
end;

procedure TfPrintReport.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Caption:= 'PrintReport';
  i:= 0;
  while i< pclFind.Pages.Count do begin
    pclFind.Pages[i].UseDefaultAppearance:= False;
    TmClientCmd.TMSTabColor(pclFind.Pages[i]);
    TmClientCmd.FillTMSColor(pclFind.PageContainers[i].Fill, False, False);
    pclFind.PageContainers[i].Stroke.Width:= strkthickness;
    inc(i);
  end;
  detFrom.ShowCheckBox:= True;
  detFrom.IsChecked:= False;
  detTo.ShowCheckBox:= True;
  detTo.IsChecked:= False;
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

  TmClientCmd.FillTMSColor(grdList.Fill, False, False);
end;

procedure TfPrintReport.FormDestroy(Sender: TObject);
begin
  fPrintReport:= nil;
end;

end.
