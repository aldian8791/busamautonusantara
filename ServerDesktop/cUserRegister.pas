unit cUserRegister;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Data.DB,
  Uni, DBAccess(*Database*);

type
  TcUserRegister = class
  private
  public
    const pkid: string= 'urid';
    //class function GetNumberLoc: string; static;
    class function CheckUsernameByUsername(AUsername: string): string; static;
    class function CheckUsernameByOtherID(AID, AUsername: string): string; static;
    class function IndexUserRegister(out AMsg: string; Atype: shortint;
      ASortCol: string; AAsc: boolean; (*ALocation, ANumFrom, ANumTo,*) AUserType,
      AUserName, AFullName, AJob, ADepartment: string): string; static;
    (*CRUD*)
    class function CreateUserRegister(const AJSON: string; ALocation: string): string; static;
    class function ReadUserRegisterByID(AID: string): string; static;
    class function UpdateUserRegisterByID(const AJSON: string): string; static;
    class function DeleteUserRegisterByID(const AJSON: string): string; static;
    (*CRUD*)
  end;

implementation

uses uServerCmd, uServerCon;

const
  tbcode: string= 'UR';
  tbdesc: string= 'sys_user';

var
  qryUserRegister: TUniQuery;

(*class function TcUserRegister.GetNumberLoc: string;
begin
  qryUserRegister:= TUniQuery.Create(nil);
  try
    with qryUserRegister do begin
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
    Result:= TmServerCmd.QueryToJSON(qryUserRegister);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryUserRegister.EnableControls;
    FreeAndNil(qryUserRegister);
  end;
end;*)

class function TcUserRegister.CheckUsernameByUsername(AUsername: string): string;
begin
  qryUserRegister:= TUniQuery.Create(nil);
  try
    with qryUserRegister do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT urname FROM '+ tbdesc+ ' WHERE urname='''+
        AUsername.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryUserRegister);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryUserRegister.EnableControls;
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.CheckUsernameByOtherID(AID, AUsername: string): string;
begin
  qryUserRegister:= TUniQuery.Create(nil);
  try
    with qryUserRegister do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT urname FROM '+ tbdesc+ ' WHERE '+ pkid+ '<>'''+
        AID.Trim+ ''' AND urname='''+ AUsername.Trim+ '''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryUserRegister);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryUserRegister.EnableControls;
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.IndexUserRegister(out AMsg: string; Atype: shortint;
  ASortCol: string; AAsc: boolean; (*ALocation, ANumFrom, ANumTo,*) AUserType,
  AUserName, AFullName, AJob, ADepartment: string): string;
var
  sortcol, sqlwhere: string;
begin
  Result:= '';
  if ASortCol= '' then begin
    //ASortCol:= pkid;
    ASortCol:= 'urname';
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
        'INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+'))) AS INTEGER)='+
        ANumFrom.Trim+' ';
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
  if AUserType<> '' then begin
    if AUserType= 'user' then begin
      sqlwhere:= sqlwhere+ 'AND urtype= 0 ';
    end else if AUserType= 'administrator' then begin
      sqlwhere:= sqlwhere+ 'AND urtype= 1 ';
    end else begin
      if AUserType= 'programmer' then begin
        sqlwhere:= sqlwhere+ 'AND urtype= 2 ';
      end else begin
        AMsg:= 'No UserType like '+ QuotedStr(AUserType.Trim)+'. Please select '+
          'UserType from DropDown list.';
        sqlwhere:= sqlwhere;
      end;
    end;
  end;
  if AUserName<> '' then begin
    sqlwhere:= sqlwhere+ 'AND urname LIKE ''%'+ AUserName+ '%'' ';
  end;
  if AFullName<> '' then begin
    sqlwhere:= sqlwhere+ 'AND urfullname LIKE ''%'+ AFullName+ '%'' ';
  end;
  if AJob<> '' then begin
    sqlwhere:= sqlwhere+ 'AND jbcode LIKE ''%'+ AJob+ '%'' ';
  end;
  if ADepartment<> '' then begin
    sqlwhere:= sqlwhere+ 'AND jbcode LIKE ''%'+ ADepartment+ '%'' ';
  end;
  qryUserRegister:= TUniQuery.Create(nil);
  try
    with qryUserRegister do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      if Atype= 0 then begin
        (*SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 1, INSTR('+ pkid+ ', '+
          QuotedStr(mstsgn)+ ')) || printf(''%010d'', CAST(SUBSTR('+ pkid+ ', '+
          '-(LENGTH('+ pkid+ ')- INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+
          '))) AS INTEGER)) AS myid, CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE urtype= 0 '+ sqlwhere+ 'ORDER BY '+ sortcol;*)
        SQL.Text:= 'SELECT CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE urtype= 0 '+ sqlwhere+ 'ORDER BY '+ sortcol;
      end else if Atype= 1 then begin
        (*SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 1, INSTR('+ pkid+ ', '+
          QuotedStr(mstsgn)+ ')) || printf(''%010d'', CAST(SUBSTR('+ pkid+ ', '+
          '-(LENGTH('+ pkid+ ')- INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+
          '))) AS INTEGER)) AS myid, CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE urtype IN (0, 1) '+ sqlwhere+ 'ORDER BY '+
          sortcol;*)
        SQL.Text:= 'SELECT CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE urtype IN (0, 1) '+ sqlwhere+ 'ORDER BY '+
          sortcol;
      end else if Atype= 2 then begin
        (*SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 1, INSTR('+ pkid+ ', '+
          QuotedStr(mstsgn)+ ')) || printf(''%010d'', CAST(SUBSTR('+ pkid+ ', '+
          '-(LENGTH('+ pkid+ ')- INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+
          '))) AS INTEGER)) AS myid, CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;*)
        SQL.Text:= 'SELECT CASE WHEN urtype= 2 THEN ''programmer'' '+
          'WHEN urtype= 1 THEN ''administrator'' ELSE ''user'' END AS urtype, '+
          'urname, urfullname, jbcode, dmcode, kick, inactive, edituser, '+
          'STRFTIME(''%d-%m-%Y %H:%M:%S'', editdate) AS editdate, '+ pkid+ ' '+
          'FROM '+ tbdesc+ ' WHERE 1=1 '+ sqlwhere+ 'ORDER BY '+ sortcol;
      end;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryUserRegister);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryUserRegister.EnableControls;
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.CreateUserRegister(const AJSON: string;
  ALocation: string): string;
//save JSON to Database (Create)
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
  myNumber: string;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryUserRegister:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryUserRegister.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryUserRegister.Connection:= mServerCon.conbusamautonusantara;
      with qryUserRegister do begin
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
          //mynumber:= Obj.GetValue<string>('donumber');//for multi record
          with qryUserRegister do begin
            LockMode:= lmPessimistic;
            DataTypeMap.AddFieldNameRule('newdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            DataTypeMap.AddFieldNameRule('urtype', ftShortInt);
            DataTypeMap.AddFieldNameRule('kick', ftBoolean);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, '+
              'editdate, note, urtype, urname, urpassword, urfullname, jbcode, '+
              'dmcode, kick FROM '+ tbdesc+ '';
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

            FieldByName('urtype').AsInteger:=
              Obj.GetValue<shortint>('urtype');
            FieldByName('urname').AsString:=
              Obj.GetValue<string>('urname');
            FieldByName('urpassword').AsString:=
              Obj.GetValue<string>('urpassword');
            FieldByName('urfullname').AsString:=
              Obj.GetValue<string>('urfullname');
            (*Table not yet ready
            FieldByName('jbcode').AsString:=
              Obj.GetValue<string>('jbcode');
            FieldByName('dmcode').AsString:=
              Obj.GetValue<string>('dmcode');*)
            FieldByName('kick').AsBoolean:=
              Obj.GetValue<boolean>('kick');
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
    qryUserRegister.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.ReadUserRegisterByID(AID: string): string;
//Read JSON from Database (Read)
begin
  qryUserRegister:= TUniQuery.Create(nil);
  try
    with qryUserRegister do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT '+ pkid+ ', newuser, newdate, edituser, editdate, '+
        'inactive, note, urtype, urname, urpassword, urfullname, jbcode, '+
        'dmcode, kick FROM '+ tbdesc+ ' WHERE '+ pkid+ '='''+ AID.Trim+'''';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryUserRegister);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryUserRegister.EnableControls;
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.UpdateUserRegisterByID(const AJSON: string): string;
//save JSON to Database (Update)
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryUserRegister:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryUserRegister.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryUserRegister.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryUserRegister do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('note', ftMemo);
            DataTypeMap.AddFieldNameRule('urtype', ftShortInt);
            DataTypeMap.AddFieldNameRule('kick', ftBoolean);
            Active:= False;
            SQL.Text:= 'SELECT '+ pkid+ ', edituser, editdate, note, urtype, '+
              'urname, urpassword, urfullname, jbcode, dmcode, kick '+
              'FROM '+ tbdesc+ ' WHERE '+ pkid+ '='''+
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

              FieldByName('urtype').AsInteger:=
                Obj.GetValue<shortint>('urtype');
              FieldByName('urname').AsString:=
                Obj.GetValue<string>('urname');
              FieldByName('urpassword').AsString:=
                Obj.GetValue<string>('urpassword');
              FieldByName('urfullname').AsString:=
                Obj.GetValue<string>('urfullname');
              (*Table not yet ready
              FieldByName('jbcode').AsString:=
                Obj.GetValue<string>('jbcode');
              FieldByName('dmcode').AsString:=
                Obj.GetValue<string>('dmcode');*)
              FieldByName('kick').AsBoolean:=
                Obj.GetValue<boolean>('kick');
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
    qryUserRegister.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryUserRegister);
  end;
end;

class function TcUserRegister.DeleteUserRegisterByID(const AJSON: string): string;
//save JSON to Database (Delete in update mode)
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryUserRegister:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryUserRegister.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryUserRegister.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryUserRegister do begin
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
      if qryUserRegister.FieldByName('inactive').AsBoolean= True then begin
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
    qryUserRegister.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryUserRegister);
  end;
end;

end.
