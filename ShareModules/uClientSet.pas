unit uClientSet;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.UITypes,
  (*Database*)Uni, Data.DB, DBAccess, UniProvider, SQLiteUniProvider(*Database*),
  System.JSON, System.Generics.Collections, FMX.Controls, FMX.Dialogs, FMX.Types;

type
  TDragMode= (dmNone, dmMove, dmResize);

type
  TmClientSet= class
  private
    class procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    class procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    class procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  public
    class procedure EnableDragResize(AControl: TControl); static;
    class function GetmyVersion: string; static;
    class function ComparemyVersion(out AMsg: string): string; static;
    class function GetdbloginByUsername(AUsername: string): string; static;
    class function GetdbmasterByServername(AServername: string): string; static;
    class function GetdbdetailBydbname(Adbname: string): string; static;
    class function GetbusinessBydbnameLoc(Adbname, ALocation: string): string; static;
    class function ReadriftensetBydesc: string; static;
    class procedure UpdateriftensetBydesc(const AJSON: string); static;
  end;

implementation

uses uClientCon, uClientCmd, uLogin;

const
  ResizeSize= 15;
  fetchallvalue: string= 'True';

var
  qrymyriften, qryusrsetting: TUniQuery;
  FMode: TDragMode;
  FControl: TControl;
  FOffsetX, FOffsetY, FStartWidth, FStartHeight: single;

class procedure TmClientSet.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
//for moving and resize control
begin
  if Button<> TMouseButton.mbLeft then Exit;
  FControl:= Sender as TControl;
  {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64))}
  //capture mouse
  FControl.Root.Captured:= FControl;
  {$ENDIF}
  //resize area = bottom right corner
  if (X>= FControl.Width- ResizeSize) and (Y>= FControl.Height- ResizeSize) then
  begin
    FMode:= dmResize;
    FStartWidth:= FControl.Width;
    FStartHeight:= FControl.Height;
    FOffsetX:= X;
    FOffsetY:= Y;
  end else begin
    //move
    FMode:= dmMove;
    FOffsetX:= X;
    FOffsetY:= Y;
  end;
end;

class procedure TmClientSet.MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
//for moving and resize control
var
  NewX, NewY, NewWidth, NewHeight, ParentWidth, ParentHeight: single;
begin
  if not Assigned(FControl) then Exit;
  if not Assigned(FControl.ParentControl) then Exit;
  ParentWidth:= FControl.ParentControl.Width;
  ParentHeight:= FControl.ParentControl.Height;
  case FMode of
    dmMove: begin
      NewX:= FControl.Position.X + X - FOffsetX;
      NewY:= FControl.Position.Y + Y - FOffsetY;
      //top left limit
      if NewX< 0 then begin
        NewX:= 0;
      end;
      if NewY< 0 then begin
        NewY:= 0;
      end;
      //bottom right limit
      if NewX+ FControl.Width> ParentWidth then begin
        NewX:= ParentWidth- FControl.Width;
      end;
      if NewY+ FControl.Height> ParentHeight then begin
        NewY:= ParentHeight- FControl.Height;
      end;
      FControl.Position.X:= NewX;
      FControl.Position.Y:= NewY;
    end;
    dmResize: begin
      NewWidth:= FStartWidth+ (X- FOffsetX);
      NewHeight:= FStartHeight+ (Y- FOffsetY);
      //resize not allowed out of parent
      if FControl.Position.X+ NewWidth> ParentWidth then begin
        NewWidth:= ParentWidth- FControl.Position.X;
      end;
      if FControl.Position.Y+ NewHeight> ParentHeight then begin
        NewHeight:= ParentHeight- FControl.Position.Y;
      end;
      FControl.Width:= NewWidth;
      FControl.Height:= NewHeight;
    end;
  end;
end;

class procedure TmClientSet.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
//for moving and resize control
begin
  {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64))}
  if Assigned(FControl) and Assigned(FControl.Root) then begin
    FControl.Root.Captured:= nil;
  end;
  {$ENDIF}
  FMode:= dmNone;
  FControl:= nil;
end;

class procedure TmClientSet.EnableDragResize(AControl: TControl);
//for moving and resize control
begin
  AControl.OnMouseDown:= MouseDown;
  AControl.OnMouseMove:= MouseMove;
  AControl.OnMouseUp:= MouseUp;
end;

class function TmClientSet.GetmyVersion: string;
//for intializing application
var
  AMsg: string;
begin
  Result:= '';
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT CAST(myversionid AS INT) AS myversionid, '+
        'myversionname, description FROM myversion '+
        'ORDER BY CAST(myversionid AS INT) DESC';
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.ComparemyVersion(out AMsg: string): string;
//for compare version to force update application
begin
  Result:= '';
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      if AMsg<> '' then Exit;
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      SpecificOptions.Values['FetchAll']:= fetchallvalue;
      Active:= False;
      SQL.Text:= 'SELECT CAST(myversionid AS INT) AS myversionid, '+
        'myversionname FROM myversion ORDER BY CAST(myversionid AS INT) DESC '+
        'LIMIT 1';
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.GetdbloginByUsername(AUsername: string): string;
//for intializing application
var
  AMsg: string;
begin
  Result:= '';
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      if AMsg<> '' then Exit;
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      Active:= False;
      SQL.Text:= 'SELECT usernames, passwords, logo22, logo75, icon, '+
        'colorpoint0, colorpoint1 FROM dblogin WHERE usernames=:username';
      ParamByName('username').AsString:= AUsername.Trim;
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.GetdbmasterByServername(AServername: string): string;
//get server data from servername because of only one database.
var
  AMsg: string;
begin
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      if AMsg<> '' then Exit;
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      Active:= False;
      SQL.Text:= 'SELECT servername, serverip, location FROM dbmaster '+
        'WHERE inactive= false AND servername=:servername';
      ParamByName('servername').AsString:= AServername.Trim;
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.GetdbdetailBydbname(Adbname: string): string;
//get server data from databasename because of only one database.}
var
  AMsg: string;
begin
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      if AMsg<> '' then Exit;
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      Active:= False;
      SQL.Text:= 'SELECT headcompany, dbname, myport, company, logo22, logo75, '+
        'icon, colorpoint0, colorpoint1 FROM dbdetail WHERE inactive= false '+
        'AND dbname=:dbname';
      ParamByName('dbname').AsString:= Adbname.Trim;
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.GetbusinessBydbnameLoc(Adbname, ALocation: string): string;
//get company data from databasename because of only one database.}
var
  AMsg: string;
begin
  qrymyriften:= TUniQuery.Create(nil);
  try
    with qrymyriften do begin
      DisableControls;
      mClientCon.dbmyriften(AMsg);
      if AMsg<> '' then Exit;
      mClientCon.conmyriften.Connected:= True;
      Connection:= mClientCon.conmyriften;
      Active:= False;
      SQL.Text:= 'SELECT dbname, company, address, city FROM business '+
        'WHERE inactive= false AND dbname=:dbname AND city=:location';
      ParamByName('dbname').AsString:= Adbname.Trim;
      ParamByName('location').AsString:= ALocation.Trim;
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qrymyriften);
  finally
    mClientCon.conmyriften.Connected:= False;
    qrymyriften.EnableControls;
    FreeAndNil(qrymyriften);
  end;
end;

class function TmClientSet.ReadriftensetBydesc: string;
//Set data to JSON from a table query
begin
  Result:= '';
  qryusrsetting:= TUniQuery.Create(nil);
  try
    with qryusrsetting do begin
      DisableControls;
      mClientCon.dbusrsetting;
      mClientCon.conusrsetting.Connected:= True;
      Connection:= mClientCon.conusrsetting;
      Active:= False;
      SQL.Text:= 'SELECT riftendesc, CAST(riftenvalue AS INT) AS riftenvalue '+
        'FROM riftenset ORDER BY CAST(riftensetid AS INTEGER)';
      Active:= True;
    end;
    Result:= TmClientCmd.QueryToJSON(qryusrsetting);
  finally
    mClientCon.conusrsetting.Connected:= False;
    qryusrsetting.EnableControls;
    FreeAndNil(qryusrsetting);
  end;
end;

class procedure TmClientSet.UpdateriftensetBydesc(const AJSON: string);
//save JSON updated string to Database
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  i: integer;
begin
  Arr:= TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
  qryusrsetting:= TUniQuery.Create(nil);
  if not Assigned(Arr) then Exit;
  try
    qryusrsetting.DisableControls;
    mClientCon.dbusrsetting;
    mClientCon.conusrsetting.Connected:= True;
    try
      if mClientCon.conusrsetting.InTransaction= True then begin
        mClientCon.conusrsetting.Rollback;
      end;
      mClientCon.conusrsetting.StartTransaction;
      qryusrsetting.Connection:= mClientCon.conusrsetting;
      i:= 0;
      while i< Arr.Count do begin
        try
          Obj:= Arr.Items[i] as TJSONObject;
          with qryusrsetting do begin
            LockMode:= lmOptimistic;
            DataTypeMap.AddFieldNameRule('editdate', ftDateTime);
            DataTypeMap.AddFieldNameRule('riftensetid', ftShortInt);
            Active:= False;
            SQL.Text:= 'SELECT riftenvalue, edituser, editdate, riftensetid '+
              'FROM riftenset WHERE riftendesc='''+
              Obj.GetValue<string>('riftendesc')+ '''';
            Active:= True;
            if RecordCount> 0 then begin
              Lock;
              Edit;
              FieldByName('riftenvalue').AsString:=
                Obj.GetValue<string>('riftenvalue');
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
      mClientCon.conusrsetting.Commit;
    except
      mClientCon.conusrsetting.Rollback;
      raise;
    end;
  finally
    mClientCon.conusrsetting.Connected:= False;
    qryusrsetting.EnableControls;
    FreeAndNil(Arr);
    FreeAndNil(qryusrsetting);
  end;
end;

end.
