unit uServerCmd;

interface

uses
  System.SysUtils, System.Generics.Collections, System.DateUtils, System.Classes,
  System.NetEncoding, System.JSON, (*Database*)DBAccess, Data.DB, Uni(*Database*);

type
  TmServerCmd = class
  private
    class function FieldToJSONValue(AField: TField): TJSONValue; static;
    class function BlobFieldToBase64(AField: TField): string; static;
    class procedure Base64ToBlobParam(const ABase64: string; AParam: TUniParam); static;
  public
    class function QueryToJSON(AQuery: TUniQuery): string; static;
    class procedure JSONToParams(AObj: TJSONObject; AParams: TUniParams); static;
  end;

const
  fetchallvalue: string= 'True';
  mstsgn: string= '-';
  dtlsgn: string= '`';

var
  documentfolder: string;

implementation

class function TmServerCmd.BlobFieldToBase64(AField: TField): string;
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

class procedure TmServerCmd.Base64ToBlobParam(const ABase64: string;
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

class function TmServerCmd.FieldToJSONValue(AField: TField): TJSONValue;
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

class function TmServerCmd.QueryToJSON(AQuery: TUniQuery): string;
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

class procedure TmServerCmd.JSONToParams(AObj: TJSONObject; AParams: TUniParams);
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

end.
