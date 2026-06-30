unit cState;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Data.DB,
  Uni, DBAccess(*Database*);

type
  TcState = class
  private
  public
    const pkid: string= 'stid';
    class function GetCountry: string; static;
    //class function GetNumberLoc: string; static;
    class function CheckCodeByCode(ACode: string): string; static;
    class function CheckCodeByOtherID(AID, ACode: string): string; static;
    class function IndexState(ASortCol: string; AAsc: boolean; (*ALocation,
      ANumFrom, ANumTo,*) ACode, ADescription, ACountry: string): string; static;
    class function CreateState(const AJSON: string; ALocation: string): string; static;
    class function ReadStateByID(AID: string): string; static;
    class function UpdateStateByID(const AJSON: string): string; static;
    class function DeleteStateByID(const AJSON: string): string; static;
  end;

implementation

uses uServerCon, uServerCmd;

const
  tbcode: string= 'ST';
  tbdesc: string= 'sys_state';

var
  qryState: TUniQuery;

class function TcState.GetCountry: string;
begin
  Result:= '';
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT cncode, description, cnid FROM sys_country '+
        'WHERE inactive= false ORDER BY description ASC';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;

(*class function TcState.GetNumberLoc: string;
begin
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 3, INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+ ')- 3) AS numberloc FROM '+ tbdesc+ ' '+
        'GROUP BY SUBSTR('+ pkid+ ', 3, INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+
        ')- 3) ORDER BY SUBSTR('+ pkid+ ', 3, INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+')- 3) DESC';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;*)

class function TcState.CheckCodeByCode(ACode: string): string;
begin
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT stcode FROM '+ tbdesc+ ' WHERE stcode='''+
        ACode.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;

class function TcState.CheckCodeByOtherID(AID, ACode: string): string;
begin
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT stcode FROM '+ tbdesc+ ' WHERE '+ pkid+ '<>'''+
        AID.Trim+ ''' AND stcode='''+ ACode.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;

class function TcState.IndexState(ASortCol: string; AAsc: boolean; (*ALocation,
  ANumFrom, ANumTo,*) ACode, ADescription, ACountry: string): string;
var
  sortcol, sqlwhere: string;
begin
  Result:= '';
  if ASortCol= '' then begin
    //ASortCol:= pkid;
    ASortCol:= 'stcode';
  end;
  (*if ASortCol= pkid then begin
    if AAsc= True then begin
      sortcol:= 'CAST(SUBSTR('+ ASortCol+ ', -(LENGTH('+ ASortCol+ ')- '+
        'INSTR('+ ASortCol+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER)';
    end else begin
      sortcol:= 'CAST(SUBSTR('+ ASortCol+ ', -(LENGTH('+ ASortCol+ ')- '+
        'INSTR('+ ASortCol+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER) DESC';
    end;
  end else begin*)
    if AAsc= True then begin
      sortcol:= ASortCol;
    end else begin
      sortcol:= ASortCol+ ' DESC';
    end;
  //end;
  sqlwhere:= '';
  (*if ALocation= '' then begin
    if (ANumFrom= '') and (ANumTo= '') then begin
      sqlwhere:= sqlwhere+ '';
    end else if (ANumFrom<> '') and (ANumTo= '') then begin
      sqlwhere:= sqlwhere+ 'AND CAST(SUBSTR('+ pkid+ ', -(LENGTH('+ pkid+ ')- '+
        'INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+'))) AS INTEGER)='+ ANumFrom.Trim+' ';
    end else if (ANumFrom<> '') and (ANumTo<> '') then begin
      sqlwhere:= sqlwhere+ 'AND CAST(SUBSTR('+ pkid+ ', INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+ ')+ 1) AS INTEGER) BETWEEN '+ ANumFrom.Trim+' AND '+
        ANumTo.Trim+' ';
    end;
  end else if ALocation<> '' then begin
    if (ANumFrom= '') and (ANumTo= '') then begin
      sqlwhere:= sqlwhere+ 'AND '+ pkid+ ' LIKE '''+ tbcode+ ALocation.Trim+
        mstsgn+'%'' ';
    end else if (ANumFrom<> '') and (ANumTo= '') then begin
      sqlwhere:= sqlwhere+ 'AND '+ pkid+ '='''+ tbcode+ ALocation.Trim+ mstsgn+
        ANumFrom+''' ';
    end else if (ANumFrom<> '') and (ANumTo<> '') then begin
      sqlwhere:= sqlwhere+ 'AND '+ pkid+ ' LIKE '''+ tbcode+ ALocation.Trim+
        mstsgn+'%'' AND CAST(SUBSTR('+ pkid+ ', -(LENGTH('+ pkid+ ')- INSTR('+
        pkid+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER) BETWEEN '+ ANumFrom.Trim+
        ' AND '+ ANumTo.Trim+' ';
    end;
  end;*)
  if ACode<> '' then begin
    sqlwhere:= sqlwhere+ 'AND stcode LIKE ''%'+ ACode+ '%'' ';
  end;
  if ADescription<> '' then begin
    sqlwhere:= sqlwhere+ 'AND description LIKE ''%'+ ADescription+ '%'' ';
  end;
  if ACountry<> '' then begin
    sqlwhere:= sqlwhere+ 'AND country LIKE ''%'+ ACountry+ '%'' ';
  end;
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      (*SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 1, INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+ ')) || printf(''%010d'', CAST(SUBSTR('+ pkid+ ', '+
        '-(LENGTH('+ pkid+ ')- INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+'))) '+
        'AS INTEGER)) AS myid, '+
        'stcode, description, country, inactive, edituser, '+
        'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
        'FROM ( '+
        'SELECT '+ pkid+ ', stcode, a.description, b.description AS country, '+
        'a.inactive, a.edituser, a.editdate '+
        'FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_country b ON (a.cnid= b.cnid) '+
        ') z '+
        'WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;*)
      SQL.Text:= 'SELECT stcode, description, country, inactive, edituser, '+
        'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
        'FROM ( '+
        'SELECT '+ pkid+ ', stcode, a.description, b.description AS country, '+
        'a.inactive, a.edituser, a.editdate '+
        'FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_country b ON (a.cnid= b.cnid) '+
        ') z '+
        'WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;

class function TcState.CreateState(const AJSON: string;
  ALocation: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
  myNumber: string;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryState:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryState.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryState.Connection:= mServerCon.conbusamautonusantara;
      with qryState do begin
        Active:= False;
        SQL.Text:= 'SELECT CAST(SUBSTR('+ pkid+ ', -(LENGTH('+ pkid+ ')- INSTR('+
          pkid+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER) AS lastrec '+
          'FROM '+ tbdesc+ ' WHERE SUBSTR('+ pkid+ ', 3, INSTR('+ pkid+ ', '+
          QuotedStr(mstsgn)+ ')-3)='''+ ALocation+ ''' '+
          'ORDER BY CAST(SUBSTR('+ pkid+ ', -(LENGTH('+ pkid+ ')- INSTR('+ pkid+
          ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER) DESC LIMIT 1 ';
        Active:= True;
        if RecordCount<= 0 then begin
          myNumber:= tbcode+ ALocation+ mstsgn+ '1';
        end else if RecordCount> 0 then begin
          myNumber:= tbcode+ ALocation+ mstsgn+
            (FieldByName('lastrec').AsInteger+ 1).ToString;
        end;
      end;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryState do begin
            LockMode:= lmPessimistic;
            DataTypeMap.AddFieldNameRule('newdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, '+
              'editdate, note, stcode, description, cnid FROM '+ tbdesc+ '';
            Active:= True;
            Lock;
            Append;
            FieldByName(pkid).AsString:= myNumber;
            FieldByName('newuser').AsString:=
              Obj.GetValue<string>('newuser');
            FieldByName('newdate').AsDateTime:= Now;
            FieldByName('edituser').AsString:=
              Obj.GetValue<string>('edituser');
            FieldByName('editdate').AsDateTime:= Now;
            FieldByName('note').AsString:=
              Obj.GetValue<string>('note');

            FieldByName('stcode').AsString:=
              Obj.GetValue<string>('stcode');
            FieldByName('description').AsString:=
              Obj.GetValue<string>('description');
            FieldByName('cnid').AsString:=
              Obj.GetValue<string>('cnid');
            Post;
          end;
        finally
          inc(i);
        end;
      end;
      mServerCon.conbusamautonusantara.Commit;
      Result:= Format(
        '{"success":true,"message":"Data have been added.","affected":%d,"new_id":"%s"}',
        [Arr.Count, myNumber]
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
    qryState.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryState);
  end;
end;

class function TcState.ReadStateByID(AID: string): string;
begin
  qryState:= TUniQuery.Create(nil);
  try
    with qryState do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, editdate, '+
        'inactive, note, stcode, description, cncode FROM ( '+
        'SELECT '+ pkid+ ', a.newuser, a.newdate, a.edituser, a.editdate, '+
        'a.inactive, a.note, stcode, a.description, cncode FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_country b ON (a.cnid=b.cnid) '+
        ') z '+
        'WHERE '+ pkid+ '='''+ AID.Trim+'''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryState);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryState.EnableControls;
    FreeAndNil(qryState);
  end;
end;

class function TcState.UpdateStateByID(const AJSON: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryState:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryState.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryState.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryState do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', edituser, editdate, note, stcode, '+
              'description, cnid FROM '+ tbdesc+ ' WHERE '+ pkid+ '='''+
              Obj.GetValue<string>(pkid)+ ''' ';
            Active:= True;
            if RecordCount> 0 then begin
              Lock;
              Edit;
              FieldByName('edituser').AsString:=
                Obj.GetValue<string>('edituser');
              FieldByName('editdate').AsDateTime:= Now;
              FieldByName('note').AsString:=
                Obj.GetValue<string>('note');

              FieldByName('stcode').AsString:=
                Obj.GetValue<string>('stcode');
              FieldByName('description').AsString:=
                Obj.GetValue<string>('description');
              FieldByName('cnid').AsString:=
                Obj.GetValue<string>('cnid');
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
    qryState.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryState);
  end;
end;

class function TcState.DeleteStateByID(const AJSON: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryState:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryState.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryState.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryState do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('inactive', ftBoolean);
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', inactive, edituser, editdate '+
              'FROM '+ tbdesc+ ' WHERE '+ pkid+ '='''+
              Obj.GetValue<string>(pkid)+ ''' ';
            Active:= True;
            if RecordCount> 0 then begin
              Lock;
              Edit;
              FieldByName('inactive').AsBoolean:=
                Obj.GetValue<boolean>('inactive');
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
      if qryState.FieldByName('inactive').AsBoolean= True then begin
        Result:= Format(
          '{"success":true,"message":"Data has been deleted.","affected":%d}',
          [Arr.Count]
          );
      end else begin
        Result:= Format(
          '{"success":true,"message":"Data has been restored.","affected":%d}',
          [Arr.Count]
          );
      end;
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
    qryState.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryState);
  end;
end;

end.
