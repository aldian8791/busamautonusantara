unit cNumberMap;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, (*Database*)Data.DB,
  Uni, DBAccess(*Database*);

type
  TcNumberMap = class
  public
    const pkid: string= 'tbid';
    class function IndexNumberMap(ASortCol: string; AAsc: boolean): string; static;
  end;

implementation

uses uServerCmd, uServerCon;

const
  tbdesc: string= 'sys_table';

var
  qryNumberMap: TUniQuery;

class function TcNumberMap.IndexNumberMap(ASortCol: string; AAsc: boolean): string;
var
  sortcol: string;
begin
  Result:= '';
  if ASortCol= '' then begin
    ASortCol:= pkid;
  end;
  if ASortCol= pkid then begin
    if AAsc= True then begin
      sortcol:= 'CAST(SUBSTR('+ ASortCol+ ', -(LENGTH('+ ASortCol+ ')- '+
        'INSTR('+ ASortCol+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER)';
    end else begin
      sortcol:= 'CAST(SUBSTR('+ ASortCol+ ', -(LENGTH('+ ASortCol+ ')- '+
        'INSTR('+ ASortCol+ ', '+ QuotedStr(mstsgn)+ '))) AS INTEGER) DESC';
    end;
  end else begin
    if AAsc= True then begin
      sortcol:= ASortCol;
    end else begin
      sortcol:= ASortCol+ ' DESC';
    end;
  end;
  qryNumberMap:= TUniQuery.Create(nil);
  try
    with qryNumberMap do begin
      DisableControls;
      mServerCon.dbmain;
      mServerCon.conbusamautonusantara.Connected:= True;
      Connection:= mServerCon.conbusamautonusantara;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT SUBSTR('+ pkid+ ', 1, INSTR('+ pkid+ ', '+
        QuotedStr(mstsgn)+ ')) || printf(''%010d'', CAST(SUBSTR('+ pkid+ ', '+
        '-(LENGTH('+ pkid+ ')- INSTR('+ pkid+ ', '+ QuotedStr(mstsgn)+'))) '+
        'AS INTEGER)) AS myid, '+
        'tbcode, description, '+ pkid+ ' '+
        'FROM '+ tbdesc+ ' ORDER BY '+ sortcol;
      Active:= True;
    end;
    Result:= TmServerCmd.QueryToJSON(qryNumberMap);
  finally
    mServerCon.conbusamautonusantara.Connected:= False;
    qryNumberMap.EnableControls;
    FreeAndNil(qryNumberMap);
  end;
end;

end.
