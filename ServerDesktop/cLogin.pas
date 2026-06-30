unit cLogin;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Uni,
  DBAccess(*Database*);

type
  TcLogin = class
  private
  public
    class function GetFullName: string; static;
    class function GetDateTimeServer: string; static;
    class function GetKickUser(AUsername: string): string; static;
    class function ReadUserData(AUsername: string): string; static;
    class function UpdatePwdByUsername(const AJSON: string): string; static;
  end;

implementation

uses uServerCon, uServerCmd;

const
  tbdesc: string= 'sys_user';

var
  qryLogin: TUniQuery;

class function TcLogin.GetFullName: string;
begin
  Result:= '';
  qryLogin:= TUniQuery.Create(nil);
  try
    with qryLogin do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT urfullname, urname FROM '+ tbdesc+ ' '+
        'WHERE inactive= false ORDER BY urfullname ASC';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryLogin);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryLogin.EnableControls;
    FreeAndNil(qryLogin);
  end;
end;

class function TcLogin.ReadUserData(AUsername: string): string;
begin
  Result:= '';
  qryLogin:= TUniQuery.Create(nil);
  try
    with qryLogin do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      if Ausername= 'aldian' then begin
        SQL.Text:= 'SELECT urtype, urpassword, urfullname, jbcode, dmcode, kick '+
          'FROM '+ tbdesc+ ' WHERE urname=:urname';
        ParamByName('urname').AsString:= AUsername.Trim;
      end else if Ausername<> 'aldian' then begin
        SQL.Text:= 'SELECT urtype, urpassword, urfullname, jbcode, dmcode, kick '+
          'FROM '+ tbdesc+ ' WHERE inactive= false AND urname=:urname';
        ParamByName('urname').AsString:= AUsername.Trim;
      end;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryLogin);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryLogin.EnableControls;
    FreeAndNil(qryLogin);
  end;
end;

class function TcLogin.GetDateTimeServer: string;
begin
  Result:= '';
  qryLogin:= TUniQuery.Create(nil);
  try
    with qryLogin do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT date(''now'',''localtime'') AS curdate, '+
        'time(''now'',''localtime'') AS curtime';
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryLogin);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryLogin.EnableControls;
    FreeAndNil(qryLogin);
  end;
end;

class function TcLogin.GetKickUser(AUsername: string): string;
begin
  Result:= '';
  qryLogin:= TUniQuery.Create(nil);
  try
    with qryLogin do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT kick FROM '+ tbdesc+ ' WHERE urname=:urname';
      ParamByName('urname').AsString:= AUsername.Trim;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryLogin);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryLogin.EnableControls;
    FreeAndNil(qryLogin);
  end;
end;

class function TcLogin.UpdatePwdByUsername(const AJSON: string): string;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryLogin:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryLogin.DisableControls;
    mServerCon.dbmain;
    mServerCon.conbusamautonusantara.Connected:= True;
    try
      if mServerCon.conbusamautonusantara.InTransaction= True then begin
        mServerCon.conbusamautonusantara.Rollback;
      end;
      mServerCon.conbusamautonusantara.StartTransaction;
      qryLogin.Connection:= mServerCon.conbusamautonusantara;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryLogin do begin
            LockMode:= lmOptimistic;
            Active:= False;
            SQL.Text:= 'SELECT urpassword, urid FROM '+ tbdesc+ ' '+
              'WHERE urname='''+Obj.GetValue<string>('urname')+''' ';
            Active:= True;
            if RecordCount> 0 then begin
              Lock;
              Edit;
              FieldByName('urpassword').AsString:=
                Obj.GetValue<string>('urpassword');
              Post;
            end;
          end;
        finally
          inc(i);
        end;
      end;
      mServerCon.conbusamautonusantara.Commit;
      Result:= Format(
        '{"success":true,"message":"Your New Password has been updated.","affected":%d}',
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
    qryLogin.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryLogin);
  end;
end;

end.
