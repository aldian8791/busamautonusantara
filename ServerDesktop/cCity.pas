unit cCity;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Data.DB,
  Uni, DBAccess(*Database*);

type
  TcCity = class
  private
  public
    const pkid: string= 'ctid';
    class function GetState: string; static;
    //class function GetNumberLoc: string; static;
    class function CheckCodeByCode(ACode: string): string; static;
    class function CheckCodeByOtherID(AID, ACode: string): string; static;
    class function IndexCity(ASortCol: string; AAsc: boolean; (*ALocation,
      ANumFrom, ANumTo,*) ACode, ADescription, AState: string): string; static;
    class function CreateCity(const AJSON: string; ALocation: string): string; static;
    class function ReadCityByID(AID: string): string; static;
    class function UpdateCityByID(const AJSON: string): string; static;
    class function DeleteCityByID(const AJSON: string): string; static;
  end;

implementation

uses uServerCon, uServerCmd;

const
  tbcode: string= 'CT';
  tbdesc: string= 'sys_city';

var
  qryCity: TUniQuery;

class function TcCity.GetState: string;
begin
  Result:= '';
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT stcode, description, stid FROM sys_state '+
        'WHERE inactive= false ORDER BY description ASC';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;

(*class function TcCity.GetNumberLoc: string;
begin
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
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
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;*)

class function TcCity.CheckCodeByCode(ACode: string): string;
begin
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT ctcode FROM '+ tbdesc+ ' WHERE ctcode='''+
        ACode.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.CheckCodeByOtherID(AID, ACode: string): string;
begin
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT ctcode FROM '+ tbdesc+ ' WHERE '+ pkid+ '<>'''+
        AID.Trim+ ''' AND ctcode='''+ ACode.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.IndexCity(ASortCol: string; AAsc: boolean; (*ALocation,
  ANumFrom, ANumTo,*) ACode, ADescription, AState: string): string;
var
  sortcol, sqlwhere: string;
begin
  Result:= '';
  if ASortCol= '' then begin
    //ASortCol:= pkid;
    ASortCol:= 'ctcode';
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
    sqlwhere:= sqlwhere+ 'AND ctcode LIKE ''%'+ ACode+ '%'' ';
  end;
  if ADescription<> '' then begin
    sqlwhere:= sqlwhere+ 'AND description LIKE ''%'+ ADescription+ '%'' ';
  end;
  if AState<> '' then begin
    sqlwhere:= sqlwhere+ 'AND state LIKE ''%'+ AState+ '%'' ';
  end;
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
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
        'ctcode, description, state, inactive, edituser, '+
        'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
        'FROM ( '+
        'SELECT '+ pkid+ ', ctcode, a.description, b.description AS state, '+
        'a.inactive, a.edituser, a.editdate '+
        'FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_state b ON (a.stid= b.stid) '+
        ') z '+
        'WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;*)
      SQL.Text:= 'SELECT ctcode, description, state, inactive, edituser, '+
        'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
        'FROM ( '+
        'SELECT '+ pkid+ ', ctcode, a.description, b.description AS state, '+
        'a.inactive, a.edituser, a.editdate '+
        'FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_state b ON (a.stid= b.stid) '+
        ') z '+
        'WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.CreateCity(const AJSON: string;
  ALocation: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
  myNumber: string;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryCity:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryCity.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryCity.Connection:= mServerCon.conbusamautonusantara;
      with qryCity do begin
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
          with qryCity do begin
            LockMode:= lmPessimistic;
            DataTypeMap.AddFieldNameRule('newdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, '+
              'editdate, note, ctcode, description, stid FROM '+ tbdesc+ '';
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

            FieldByName('ctcode').AsString:=
              Obj.GetValue<string>('ctcode');
            FieldByName('description').AsString:=
              Obj.GetValue<string>('description');
            FieldByName('stid').AsString:=
              Obj.GetValue<string>('stid');
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
    qryCity.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.ReadCityByID(AID: string): string;
begin
  qryCity:= TUniQuery.Create(nil);
  try
    with qryCity do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, editdate, '+
        'inactive, note, ctcode, description, stcode FROM ( '+
        'SELECT '+ pkid+ ', a.newuser, a.newdate, a.edituser, a.editdate, '+
        'a.inactive, a.note, ctcode, a.description, stcode FROM '+ tbdesc+ ' a '+
        'INNER JOIN sys_state b ON (a.stid=b.stid) '+
        ') z '+
        'WHERE '+ pkid+ '='''+ AID.Trim+'''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryCity);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryCity.EnableControls;
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.UpdateCityByID(const AJSON: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryCity:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryCity.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryCity.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryCity do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', edituser, editdate, note, ctcode, '+
              'description, stid FROM '+ tbdesc+ ' WHERE '+ pkid+ '='''+
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

              FieldByName('ctcode').AsString:=
                Obj.GetValue<string>('ctcode');
              FieldByName('description').AsString:=
                Obj.GetValue<string>('description');
              FieldByName('stid').AsString:=
                Obj.GetValue<string>('stid');
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
    qryCity.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryCity);
  end;
end;

class function TcCity.DeleteCityByID(const AJSON: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryCity:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryCity.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryCity.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryCity do begin
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
      if qryCity.FieldByName('inactive').AsBoolean= True then begin
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
    qryCity.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryCity);
  end;
end;

end.
