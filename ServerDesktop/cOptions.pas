unit cOptions;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Data.DB,
  Uni, DBAccess(*Database*);

type
  TcOptions = class
  private
  public
    class function GetOptionsmyVersion: string; static;
    class function GetOptionsMaintenance: string; static;
    class function GetOptionsmyMessage: string; static;
    class function GetCurrency: string; static;
    class function ReadOptionsByCode: string; static;
    class function UpdateOptionsByCode(const AJSON: string): string; static;
  end;

implementation

uses uServerCon, uServerCmd;

const
  tbdesc: string= 'sys_option';

var
  qryOptions: TUniQuery;

class function TcOptions.GetOptionsmyVersion: string;
//from unit uLogin
begin
  Result:= '';
  qryOptions:= TUniQuery.Create(nil);
  try
    with qryOptions do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT CAST(otvalue AS INTEGER) AS otvalue FROM '+ tbdesc+ ' '+
        'WHERE otcode=''myversion''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryOptions);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(qryOptions);
  end;
end;

class function TcOptions.GetOptionsMaintenance: string;
//from unit uLogin
begin
  Result:= '';
  qryOptions:= TUniQuery.Create(nil);
  try
    with qryOptions do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT CAST(otvalue AS BOOLEAN) AS otvalue FROM '+ tbdesc+ ' '+
        'WHERE otcode=''maintenance''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryOptions);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(qryOptions);
  end;
end;

class function TcOptions.GetOptionsmyMessage: string;
//from unit uLogin
begin
  Result:= '';
  qryOptions:= TUniQuery.Create(nil);
  try
    with qryOptions do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT otvalue FROM '+ tbdesc+ ' WHERE otcode=''mymessage''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryOptions);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(qryOptions);
  end;
end;

class function TcOptions.GetCurrency: string;
begin
  Result:= '';
  qryOptions:= TUniQuery.Create(nil);
  try
    with qryOptions do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT cycode, description FROM sys_currency '+
        'WHERE inactive= false ORDER BY description ASC';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryOptions);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(qryOptions);
  end;
end;

class function TcOptions.ReadOptionsByCode: string;
begin
  Result:= '';
  qryOptions:= TUniQuery.Create(nil);
  try
    with qryOptions do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT otcode, otvalue FROM '+ tbdesc+ ' '+
        'ORDER BY CAST(SUBSTR(otid, -(LENGTH(otid)- INSTR(otid, '+
        QuotedStr(mstsgn)+ '))) AS INTEGER)';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryOptions);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(qryOptions);
  end;
end;

class function TcOptions.UpdateOptionsByCode(const AJSON: string): string;
//save JSON updated string to Database
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryOptions:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryOptions.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryOptions.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryOptions do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            Active:= False;
            SQL.Text:= 'SELECT otcode, otvalue, edituser, editdate, otid '+
              'FROM '+ tbdesc+ ' WHERE otcode='''+
              Obj.GetValue<string>('otcode')+ '''';
            Active:= True;
            if RecordCount> 0 then begin
              Lock;
              Edit;
              FieldByName('otvalue').AsString:=
                Obj.GetValue<string>('otvalue');
              FieldByName('edituser').AsString:=
                Obj.GetValue<string>('edituser');
              FieldByName('editdate').AsDateTime:= Now;
              Post;
            end;
          end;
        finally
          inc(i);
        end;
      end;
      mServerCon.conbusamautonusantara.Commit;
      Result:= Format(
        '{"success":true,"message":"Data has been edited.","affected":%d}',
        [Arr.Count]
        );
    except
      on E: Exception do begin
        mServerCon.conbusamautonusantara.Rollback;
        Result:= Format('{"success":false,"message":"%s"}',
          [StringReplace(E.Message, '"', '\"', [rfReplaceAll])]
          );
      end;
    end;
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryOptions.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryOptions);
  end;
end;

end.
