unit uClientCmd;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, System.JSON, System.DateUtils,
  System.NetEncoding, System.Generics.Collections, FMX.Forms, FMX.Graphics,
  (*Database*)Data.DB, DBAccess, Uni, UniProvider, SQLiteUniProvider(*Database*),
  {$IF (DEFINED(LINUX))}Posix.Base,{$ENDIF} FMX.TMSFNCDataGridDatabaseAdapter,
  FMX.TMSFNCDataGridCore, FMX.TMSFNCDataGridRenderer, FMX.TMSFNCDataGridData,
  FMX.TMSFNCDataGridCell, FMX.TMSFNCGraphicsTypes, FMX.TMSFNCDataGrid,
  FMX.TMSFNCPageControl, FMX.TMSFNCTabSet, VirtualTable, FMX.TMSFNCButton;

type
  TmClientCmd = class
  private
    class function BlobFieldToBase64(AField: TField): string; static;
    class function FieldToJSONValue(AField: TField): TJSONValue; static;
    class procedure Base64ToBlobField(const ABase64: string; AField: TField); static;
    class procedure Base64ToBlobParam(const ABase64: string; AParam: TUniParam); static;
    class procedure SetFieldDateTime(Field: TField; const S: string); static;
  public
    class function QueryToJSON(AQuery: TUniQuery): string; static;
    class procedure JSONToVirtualTable(const AJSON: string;
      AVirtualTable: TVirtualTable); static;
    class function VirtualTableChangesToJSON(ATable: TVirtualTable): string; static;
    class function JSONDateTimeToDateTime(const S: string): TDateTime;
    class procedure JSONToParams(AObj: TJSONObject; AParams: TUniParams); static;
    class function IsFormOpen(const myFormName: string): boolean; static;
    class procedure FillBrushColor(myFill: TBrush; myPoint, myVertical,
      myLeftDirect: boolean); static;
    class procedure FillTMSColor(myFill: TTMSFNCGraphicsFill; myVertical,
      myLeftDirect: boolean); static;
    class procedure GridAppearance(myGrid: TTMSFNCDataGrid); static;
    class procedure AdapterSorting(myDataGrid: TTMSFNCDataGrid;
      myAdapter: TTMSFNCDataGridDatabaseAdapter); static;
    class procedure TMSTabColor(TabPage: TTMSFNCTabSetTab); static;
    class function FormatNumDoc(const ANumDoc: string): string; static;
  end;

{$IF (DEFINED(LINUX))}
type
  PFile= pointer;

function popen(command, mode: MarshaledAString): PFile; cdecl; external libc name 'popen';
function pclose(stream: PFile): Integer; cdecl; external libc name 'pclose';
function fgets(buf: Pointer; size: Integer; stream: PFile): MarshaledAString; cdecl; external libc name 'fgets';
{$ENDIF}

const
  darkcolor: int64= 4281019179;
  lightcolor: int64= 4294177779;
  strkthickness: single= 0.3;
  strkcolor: TAlphaColor= TAlphaColors.Dimgray;
  shdwdistance: single= 7;
  shdwopacity: single= 0.4;
  shdwcolor: TAlphaColor= TAlphaColors.Dimgray;
  btnopacity: single= 0.5;
  mstsgn: string= '-';
  dtlsgn: string= '`';

var
  gdateserver: TDate;
  gtimeserver: TTime;
  gdatetimeserver: TDateTime;
  gmrsLogo22, gmrsLogo75, mrsIcon: TMemoryStream;
  mydb, appfolder, documentfolder, reportsfolder,
  gversionname, gdbusername, gdbpassword, gservername, gserverip, gserverloc,
  gdbname, gcomp, gcompaddress, gusername, gpassword, gfullname, gjbcode,
  gdmcode: string;
  gcolorpoint0, gcolorpoint1: int64;
  gheadcompany, gkick, gmaintenance, themedark: boolean;
  gdbport, gversion: integer;
  gusertype, winmax, curtheme: shortint;

implementation

class function TmClientCmd.BlobFieldToBase64(AField: TField): string;
//encoding Blob to Base64
var
  MS: TMemoryStream;
begin
  Result:= '';
  if not Assigned(AField) then Exit;
  if AField.IsNull then Exit;
  MS:= TMemoryStream.Create;
  try
    TBlobField(AField).SaveToStream(MS);
    if MS.Size> 0 then begin
      Result:= TNetEncoding.Base64.EncodeBytesToString(MS.Memory, MS.Size);
    end;
  finally
    FreeAndNil(MS);
  end;
end;

class procedure TmClientCmd.Base64ToBlobField(const ABase64: string;
  AField: TField);
  //decoding Base64 to Blob Field
var
  MS: TMemoryStream;
  Bytes: TBytes;
begin
  if not Assigned(AField) then Exit;
  if ABase64= '' then Exit;
  Bytes:= TNetEncoding.Base64.DecodeStringToBytes(ABase64);
  MS:= TMemoryStream.Create;
  try
    if Length(Bytes)> 0 then begin
      MS.WriteBuffer(Bytes[0], Length(Bytes));
      MS.Position:= 0;
      TBlobField(AField).LoadFromStream(MS);
    end;
  finally
    FreeAndNil(MS);
  end;
end;

class procedure TmClientCmd.Base64ToBlobParam(const ABase64: string;
  AParam: TUniParam);
//decoding Base64 to Blob Param
var
  MS: TMemoryStream;
  Bytes: TBytes;
begin
  if not Assigned(AParam) then Exit;
  if ABase64= '' then Exit;
  Bytes:= TNetEncoding.Base64.DecodeStringToBytes(ABase64);
  MS:= TMemoryStream.Create;
  try
    if Length(Bytes)> 0 then begin
      MS.WriteBuffer(Bytes[0], Length(Bytes));
      MS.Position:= 0;
      AParam.LoadFromStream(MS, ftBlob);
    end;
  finally
    FreeAndNil(MS);
  end;
end;

class function TmClientCmd.FieldToJSONValue(AField: TField): TJSONValue;
//create JSONValue from query Field
var
  FS: TFormatSettings;
begin
  FS:= TFormatSettings.Invariant;
  if AField.IsNull then Exit(TJSONNull.Create);
  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftShortint, ftByte:
      Result:= TJSONNumber.Create(AField.AsInteger);
    ftLargeint, ftAutoInc:
      Result:= TJSONNumber.Create(AField.AsLargeInt);
    ftLongWord:
      Result:= TJSONNumber.Create(AField.AsLongWord);
    ftLargeUint:
      Result:= TJSONString.Create(UIntToStr(AField.AsLargeUInt));
    ftFloat, ftCurrency, ftBCD, ftFMTBcd:
      Result:= TJSONNumber.Create(FloatToStr(AField.AsFloat, FS));
    ftSingle:
      Result:= TJSONNumber.Create(FloatToStr(AField.AsSingle, FS));
    ftExtended:
      Result:= TJSONNumber.Create(FloatToStr(AField.AsExtended, FS));
    ftBoolean:
      Result:= TJSONBool.Create(AField.AsBoolean);
    ftDate:
      Result:= TJSONString.Create(FormatDateTime('yyyy-mm-dd',
        AField.AsDateTime, FS));
    ftTime:
      Result:= TJSONString.Create(FormatDateTime('hh:nn:ss',
        AField.AsDateTime, FS));
    ftDateTime, ftTimeStamp, ftOraTimeStamp:
      Result:= TJSONString.Create(DateToISO8601(AField.AsDateTime));
    ftTimeStampOffset:
      Result:= TJSONString.Create(AField.AsString);
    ftString, ftFixedChar, ftMemo, ftFmtMemo, ftGuid:
      Result:= TJSONString.Create(AField.AsString);
    ftWideString, ftFixedWideChar, ftWideMemo:
      Result:= TJSONString.Create(AField.AsWideString);
    ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftStream, ftTypedBinary:
      Result:= TJSONString.Create(BlobFieldToBase64(AField));
    else begin
      Result:= TJSONString.Create(AField.AsString);
    end;
  end;
end;

class function TmClientCmd.QueryToJSON(AQuery: TUniQuery): string;
//Convert query to JSON data in SERVER for CLIENT
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: Integer;
begin
  Arr:= TJSONArray.Create;
  try
    with AQuery do begin
      First;
      while not Eof do begin
        Obj:= TJSONObject.Create;
        i:= 0;
        while i< FieldCount do begin
          Obj.AddPair(Fields[i].FieldName, FieldToJSONValue(Fields[i]));
          Inc(i);
        end;
        Arr.AddElement(Obj);
        Next;
      end;
    end;
    Result:= Arr.ToJSON;
  finally
    FreeAndNil(Arr);
  end;
end;

class procedure TmClientCmd.SetFieldDateTime(Field: TField; const S: string);
//helper field DateTime
var
  DT: TDateTIme;
  FS: TFormatSettings;
begin
  if TryISO8601ToDate(S, DT) then begin
    Field.AsDateTime:= DT;
  end else begin
    FS:= TFormatSettings.Create;
    FS.ShortDateFormat:= 'yyyy-mm-dd';
    FS.DateSeparator:= '-';
    FS.TimeSeparator:= ':';
    if TryStrToDateTime(S, DT, FS) then begin
      Field.AsDateTime:= DT;
    end else begin
      Field.Clear;
    end;
  end;
end;

class procedure TmClientCmd.JSONToVirtualTable(const AJSON: string;
  AVirtualTable: TVirtualTable);
//convert JSON to VirtualTable
var
  V: TJSONValue;
  Arr: TJSONArray;
  Obj: TJSONObject;
  Pair: TJSONPair;
  FieldMap: TDictionary<string, TField>;
  i, j, k: Integer;
  F, Field: TField;
  s, FN: string;
  FS: TFormatSettings;
begin
  FS:= TFormatSettings.Invariant;
  V:= TJSONObject.ParseJSONValue(AJSON);
  if not (V is TJSONArray) then begin
    FreeAndNil(V);
    Exit;
  end;
  Arr:= V as TJSONArray;
  try
    AVirtualTable.DisableControls;
    try
      AVirtualTable.Clear;
      FieldMap:= TDictionary<string, TField>.Create;
      try
        k:= 0;
        while k< AVirtualTable.FieldCount do begin
          F:= AVirtualTable.Fields[k];
          FieldMap.AddOrSetValue(F.FieldName.ToLower, F);
          inc(k);
        end;
        i:= 0;
        while i< Arr.Count do begin
          try
            if Arr.Items[i] is TJSONObject then begin
              Obj:= Arr.Items[i] as TJSONObject;
              AVirtualTable.Append;
              try
                j:= 0;
                while j < Obj.Count do begin
                  try
                    Pair:=  Obj.Pairs[j];
                    FN:= Pair.JsonString.Value.ToLower;
                    if not FieldMap.TryGetValue(FN, Field) then Continue;
                    if (not Assigned(Pair.JsonValue)) or
                      (Pair.JsonValue is TJSONNull) then begin
                      Field.Clear;
                    end else begin
                      s:= Pair.JsonValue.Value;
                      case Field.DataType of
                        ftSmallint, ftInteger, ftWord, ftShortint, ftByte:
                          Field.AsInteger:= StrToIntDef(s, 0);
                        ftLargeint, ftAutoInc:
                          Field.AsLargeInt:= StrToInt64Def(s, 0);
                        ftLongWord:
                          Field.AsLongWord:= StrToUIntDef(s, 0);
                        ftLargeUint:
                          Field.AsLargeUInt:= StrToUInt64Def(s, 0);
                        ftFloat, ftCurrency, ftBCD, ftFMTBcd:
                          Field.AsFloat:= StrToFloatDef(s, 0, FS);
                        ftSingle:
                          Field.AsSingle:= StrToFloatDef(s, 0, FS);
                        ftExtended:
                          Field.AsExtended:= StrToFloatDef(s, 0, FS);
                        ftBoolean:
                          Field.AsBoolean:= SameText(s, 'true');
                        ftDate:
                          SetFieldDateTime(Field, s);
                        ftTime:
                          SetFieldDateTime(Field, '1970-01-01T' + s);
                        ftDateTime, ftTimeStamp, ftOraTimeStamp:
                          SetFieldDateTime(Field, s);
                        ftTimeStampOffset:
                          Field.AsString:= s;
                        ftString, ftFixedChar, ftMemo, ftFmtMemo, ftGuid:
                          Field.AsString:= s;
                        ftWideString, ftFixedWideChar, ftWideMemo:
                          Field.AsWideString:= s;
                        ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob,
                          ftStream, ftTypedBinary:
                          Base64ToBlobField(s, Field);
                        else begin
                          Field.AsString:= s;
                        end;
                      end;
                    end;
                  finally
                    inc(j);
                  end;
                end;
                AVirtualTable.Post;
              except
                AVirtualTable.Cancel;
                raise;
              end;
            end;
          finally
            inc(i);
          end;
        end;
      finally
        FreeAndNil(FieldMap);
      end;
    finally
      AVirtualTable.EnableControls;
    end;
  finally
    FreeAndNil(V);
  end;
end;

class function TmClientCmd.VirtualTableChangesToJSON(ATable: TVirtualTable): string;
//store changed virtualtable to JSON
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: Integer;
begin
  Arr:= TJSONArray.Create;
  try
    with ATable do begin
      First;
      while not ATable.Eof do begin
        if FieldByName('is_new').AsBoolean or
          FieldByName('is_changed').AsBoolean or
          FieldByName('is_deleted').AsBoolean then begin
          Obj:= TJSONObject.Create;
          i:= 0;
          while i< FieldCount do begin
            Obj.AddPair(Fields[i].FieldName, FieldToJSONValue(Fields[i]));
            Inc(i);
          end;
          Arr.AddElement(Obj);
        end;
        Next;
      end;
    end;
    Result:= Arr.ToJSON;
  finally
    FreeAndNil(Arr);
  end;
end;

class function TmClientCmd.JSONDateTimeToDateTime(const S: string): TDateTime;
var
  FS: TFormatSettings;
begin
  FS:= TFormatSettings.Create;
  FS.DateSeparator:= '-';
  FS.TimeSeparator:= ':';
  FS.ShortDateFormat:= 'yyyy-mm-dd';
  FS.LongTimeFormat:= 'hh:nn:ss';
  Result:= StrToDateTime(S, FS);
end;

class procedure TmClientCmd.JSONToParams(AObj: TJSONObject; AParams: TUniParams);
var
  Pair: TJSONPair;
  Param: TUniParam;
  S: string;
  i: Integer;
  FS: TFormatSettings;
begin
  FS:= TFormatSettings.Invariant;
  if not Assigned(AObj) then Exit;
  if not Assigned(AParams) then Exit;
  i:= 0;
  while i < AObj.Count do begin
    try
      Pair:= AObj.Pairs[i];
      Param:= AParams.FindParam(Pair.JsonString.Value);
      if not Assigned(Param) then Continue;
      if Pair.JsonValue is TJSONNull then begin
        Param.Clear;
        Continue;
      end;
      S:= Pair.JsonValue.Value;
      case Param.DataType of
        ftSmallint, ftInteger, ftWord, ftShortint, ftByte:
          Param.AsInteger:= StrToIntDef(S, 0);
        ftLargeint, ftAutoInc:
          Param.AsLargeInt:= StrToInt64Def(S, 0);
        ftLongWord:
          Param.AsLongWord:= StrToUIntDef(S, 0);
        ftLargeUint:
          Param.AsLargeUInt:= StrToUInt64Def(S, 0);
        ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended:
          Param.AsFloat:= StrToFloatDef(S, 0, FS);
        ftSingle:
          Param.AsSingle:= StrToFloatDef(S, 0, FS);
        ftBoolean:
          Param.AsBoolean:= SameText(S, 'true');
        ftDate:
          if S <> '' then begin
            Param.AsDate:= ISO8601ToDate(S);
          end;
        ftTime:
          if S <> '' then begin
            Param.AsTime:= StrToTime(S, FS);
          end;
        ftDateTime, ftTimeStamp, ftOraTimeStamp:
          if S <> '' then begin
            Param.AsDateTime:= ISO8601ToDate(S);
          end;
        ftTimeStampOffset:
          Param.AsString:= S;
        ftString, ftFixedChar, ftMemo, ftFmtMemo, ftGuid:
          Param.AsString:= S;
        ftWideString, ftFixedWideChar, ftWideMemo:
          Param.AsWideString:= S;
        ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftStream,
          ftTypedBinary:
          if S <> '' then begin
            Base64ToBlobParam(S, Param);
          end else begin
            Param.Clear;
          end
        else begin
          Param.AsString:= S;
        end;
      end;
    finally
      Inc(i);
    end;
  end;
end;

class function TmClientCmd.IsFormOpen(const myFormName: string): boolean;
//to check is form open or close with boolean result
var
  i: integer;
begin
  Result:= False;
  i:= Screen.FormCount- 1;
  while (i>= 0) and (result= False) do begin //loop step back from last form/newest to first form/oldest
    if Screen.Forms[i].Name= myFormName then begin
      Result:= True;
    end;
    dec(i);
  end;
end;

class procedure TmClientCmd.AdapterSorting(myDataGrid: TTMSFNCDataGrid;
  myAdapter: TTMSFNCDataGridDatabaseAdapter);
//for sorting Data grid from VirtualTable
var
  i, c: Integer;
  f: TField;
  vtb: TVirtualTable;
  s: TTMSFNCDataGridSortIndex;
  n, fn: string;
begin
  if myAdapter.DataLink.DataSet is TVirtualTable then begin
    vtb:= myAdapter.DataLink.DataSet as TVirtualTable;
    vtb.IndexFieldNames:= '';
    fn:= '';
    i:= 0;
    while i< myDataGrid.SortIndexList.Count do begin
	    s:= myDataGrid.SortIndexList[i];
      if s.Direction<> gsdNone then begin
        c:= s.Column- myDataGrid.FixedColumnCount;
        f:= myAdapter.FieldAtColumn[c];
        if Assigned(f) and (f.FieldKind in [fkData, fkInternalCalc, fkLookup])
          then begin
          n:= f.FieldName;
          if s.Direction= gsdDescending then begin
            n:= n+ ' DESC';
          end else begin
            n:= n+ ' ASC';
          end;
          if fn= '' then begin
            fn:= n;
          end else begin
            fn:= fn + ';' + n;
          end;
        end;
      end;
      inc(i);
    end;
    vtb.IndexFieldNames:= fn;
  end;
end;

class procedure TmClientCmd.FillTMSColor(myFill: TTMSFNCGraphicsFill; myVertical,
  myLeftDirect: boolean);
begin
  with myFill do begin
    if themedark= True then begin
      Color:= darkcolor;
      Kind:= gfkSolid;
    end else begin
      if myLeftDirect= False then begin
        Color:= gcolorpoint0;
        ColorTo:= gcolorpoint1;
      end else begin
        Color:= gcolorpoint1;
        ColorTo:= gcolorpoint0;
      end;
      if myVertical= False then begin
        Orientation:= gfoHorizontal;
      end else begin
        Orientation:= gfoVertical;
      end;
      Kind:= gfkGradient;
    end;
  end;
end;

class procedure TmClientCmd.GridAppearance(myGrid: TTMSFNCDataGrid);
//customize Data grid
begin
  with myGrid do begin
    Stroke.Width:= strkthickness;
    Stroke.Color:= strkcolor;
    with Options do begin
      with Keyboard do begin
        DeleteKeyHandling:= gdkhNone;
        InsertKeyHandling:= gikhNone;
      end;
      Selection.Mode:= gsmSingleRow;
      with Mouse do begin
       FixedColumnSizing:= True;
       RowSizing:= True;
       WheelScrollSize:= 1;
      end;
    end;
    with CellAppearance do begin
      NormalLayout.Stroke.Width:= strkthickness;
      FixedLayout.Stroke.Width:= strkthickness;
      FixedLayout.Font.Style:= [TFontStyle.fsBold];
      FixedLayout.TextAlign:= TTMSFNCGraphicsTextAlign.gtaCenter;
      FixedSelectedLayout.Stroke.Width:= strkthickness;
      FixedSelectedLayout.Font.Style:= [TFontStyle.fsBold];
      FixedSelectedLayout.Fill.Color:= TAlphaColors.Mediumseagreen;
      FocusedLayout.Stroke.Width:= strkthickness;
      FocusedLayout.Font.Style:= [];
      FocusedLayout.Fill.Kind:= gfkSolid;
      SelectedLayout.Stroke.Width:= strkthickness;
      SelectedLayout.Font.Style:= [];
      SelectedLayout.Fill.Kind:= gfkSolid;
      with CellAppearance do begin
        if themedark= True then begin
          FixedLayout.Fill.Color:= darkcolor;
          FocusedLayout.Fill.Color:= TAlphaColors.Navy;
          SelectedLayout.Fill.Color:= TAlphaColors.Darkslategrey;
        end else begin
          FixedLayout.Fill.Color:= gcolorpoint1;
          FocusedLayout.Fill.Color:= TAlphaColors.Lavender;
          SelectedLayout.Fill.Color:= TAlphaColors.Lightgoldenrodyellow;
        end;
      end;
    end;
  end;
end;

class procedure TmClientCmd.FillBrushColor(myFill: TBrush; myPoint, myVertical,
  myLeftDirect: boolean);
//to change brush gradient color with directions
var
  i: integer;
begin
  with myFill do begin
    if themedark= True then begin
      Color:= darkcolor;
      Kind:= TBrushKind.Solid;
    end else begin
      with Gradient do begin
        Points.Clear;
        i:= 0;
        while i<= 1 do begin
          Points.Add;
          inc(i);
        end;
        if myPoint= False then begin
          Points.Points[0].Offset:= 0.000000000000000000;
        end else begin
          Points.Points[0].Offset:= 0.167701870203018200;
        end;
        if myLeftDirect= False then begin
          Points.Points[1].Color:= gcolorpoint1;
          Points.Points[0].Color:= gcolorpoint0;
        end else begin
          Points.Points[1].Color:= gcolorpoint0;
          Points.Points[0].Color:= gcolorpoint1;
        end;
        Points.Points[1].Offset:= 1.000000000000000000;
        if myVertical= False then begin
          StartPosition.Y:= 0.500000000000000000;
          StopPosition.X:= 1.000000000000000000;
        end else begin
          StartPosition.X:= 0.500000000000000000;
          StartPosition.Y:= 1.000000000000000000;
          StopPosition.X:= 0.499999970197677600;
        end;
        StopPosition.Y:= 0.500000000000000000;
      end;
      Kind:= TBrushKind.Gradient;
    end;
  end;
end;

class procedure TmClientCmd.TMSTabColor(TabPage: TTMSFNCTabSetTab);
begin
  with TabPage do begin
    BitmapSize:= 20;
    Shape:= tsPyramidRight;
    Hint:= Text;
    if themedark= True then begin
      Color:= $FF363636;
      TextColor:= TAlphaColors.White;
      HoverColor:= $FF404040;
      HoverTextColor:= TAlphaColors.White;
      ActiveColor:= TAlphaColors.Black;
      ActiveTextColor:= TAlphaColors.White;
    end else begin
      Color:= $FFF3F3F3;
      TextColor:= TAlphaColors.Black;
      HoverColor:= $FFFBFBFB;
      HoverTextColor:= TAlphaColors.Black;
      ActiveColor:= TAlphaColors.White;
      ActiveTextColor:= TAlphaColors.Black;
    end;
  end;
end;

class function TmClientCmd.FormatNumDoc(const ANumDoc: string): string;
var
  prefix: string;
  P, numdoc: integer;
begin
  P:= ANumDoc.LastDelimiter(mstsgn);
  prefix:= copy(ANumDoc, 1, P);
  numdoc:= StrToIntDef(copy(ANumDoc, P+ 1, MaxInt), 0);
  Result:= Prefix+ Format('%.10d', [numdoc]);
end;

end.
