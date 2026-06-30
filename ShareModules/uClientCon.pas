unit uClientCon;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, (*Database*)Data.DB, DBAccess,
  Uni, UniProvider, SQLiteUniProvider(*Database*);

type
  TmClientCon= class(TDataModule)
    conmyriften: TUniConnection;
    conusrsetting: TUniConnection;
    pvdmyriften: TSQLiteUniProvider;
    pvdusrsetting: TSQLiteUniProvider;
  private
    { Private declarations }
  public
    procedure dbusrsetting;
    procedure dbmyriften(out AMsg: string);
  end;

var
  mClientCon: TmClientCon;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uClientCmd;

{$R *.dfm}

var
  usrsetting, myriften: string;

procedure TmClientCon.dbusrsetting;
begin
  {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(IOS))}
  if directoryexists(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'BusamAutoNusantara'))= False then begin
    CreateDir(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
      'BusamAutoNusantara'));
    usrsetting:= '';
  end;
  documentfolder:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'BusamAutoNusantara');
  if FileExists(System.IOUtils.TPath.Combine(documentfolder,
    'usrsetting.ald'))= True then begin
    usrsetting:= System.IOUtils.TPath.Combine(documentfolder, 'usrsetting.ald');
  end else begin
    usrsetting:= '';
  end;
  {$ENDIF}
  {$IF (DEFINED(ANDROID))}
  if directoryexists(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
    'BusamAutoNusantara'))= False then begin
    CreateDir(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
      'BusamAutoNusantara'));
    usrsetting:= '';
  end;
  documentfolder:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
    'BusamAutoNusantara');
  if FileExists(System.IOUtils.TPath.Combine(documentfolder,
    'usrsetting.ald'))= True then begin
    usrsetting:= System.IOUtils.TPath.Combine(documentfolder, 'usrsetting.ald');
  end else begin
    usrsetting:= '';
  end;
  {$ENDIF}
  if usrsetting<> '' then begin
    with conusrsetting do begin
      ProviderName:= pvdusrsetting.GetProviderName;
      Database:= usrsetting;
      {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(ANDROID))}
      SpecificOptions.Values['Direct']:= 'True'; //ios not support direct mode
      {$ENDIF}
    end;
  end else if usrsetting= '' then begin
    usrsetting:= System.IOUtils.TPath.Combine(documentfolder, 'usrsetting.ald'); //set path for file setting
    with conusrsetting do begin
      ProviderName:= pvdUsrSetting.GetProviderName;
      Database:= usrsetting;
      SpecificOptions.Values['ForceCreateDatabase']:= 'True'; //if database not exist then create SQLite database
      {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(ANDROID))}
      SpecificOptions.Values['Direct']:= 'True'; //Direct version not available for IOS
      {$ENDIF}
      Connected:= True;
      ExecSQL('PRAGMA foreign_keys = OFF');
      ExecSQL('DROP TABLE IF EXISTS riftenset');
      ExecSQL('CREATE TABLE riftenset ( '+
        'riftensetid VARCHAR (50) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'riftendesc VARCHAR (30) NOT NULL, '+
        'riftenvalue VARCHAR (50) DEFAULT '''', '+
        'CONSTRAINT riftensetid_pkey PRIMARY KEY (riftensetid) ON CONFLICT ROLLBACK, '+
        'CONSTRAINT riftendesc_ukey UNIQUE (riftendesc) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('PRAGMA foreign_keys = ON');
      ExecSQL('VACUUM');
      try
        if InTransaction= True then begin
          Rollback;
        end;
        StartTransaction;
        ExecSQL('INSERT OR IGNORE INTO riftenset VALUES '+
          '(''1'', ''aldian'', datetime(''now'', ''localtime''), ''windowmode'', ''0''), '+
          '(''2'', ''aldian'', datetime(''now'', ''localtime''), ''ostheme'', ''0'')');
        Commit;
        Connected:= False;
      except
        Rollback;
        raise;
      end;
    end;
  end;
end;

procedure TmClientCon.dbmyriften(out AMsg: string);
begin
  {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64))}
  appfolder:= System.IOUtils.TPath.GetDirectoryName(ParamStr(0));
  if directoryexists(System.IOUtils.TPath.Combine(appfolder,
    'reports'))= False then begin
    CreateDir(System.IOUtils.TPath.Combine(appfolder, 'reports'));
  end;
  reportsfolder:= System.IOUtils.TPath.Combine(appfolder, 'reports');
  if FileExists(System.IOUtils.TPath.Combine(appfolder,
    'myriften.ald'))= True then begin
    myriften:= System.IOUtils.TPath.Combine(appfolder, 'myriften.ald');
  end else begin
    myriften:= '';
  end;
  {$ENDIF}
  {$IF (DEFINED(ANDROID)) OR (DEFINED(IOS))}
  appfolder:= System.IOUtils.TPath.GetDocumentsPath;
  if FileExists(System.IOUtils.TPath.Combine(appfolder,
    'myriften.ald'))= True then begin
    myriften:= System.IOUtils.TPath.Combine(appfolder, 'myriften.ald');
  end else begin
    myriften:= '';
  end;
  {$ENDIF}
  if myriften= '' then begin
    AMsg:= 'Can not connect to database server, because file setting is '+
      'missing.';
    Exit;
  end;
  AMsg:= '';
  with conmyriften do begin
    ProviderName:= pvdmyriften.GetProviderName;
    Database:= myriften;
    {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(ANDROID))}
    SpecificOptions.Values['Direct']:= 'True'; //ios not support direct mode
    {$ENDIF}
    SpecificOptions.Values['ConnectMode']:= 'cmReadOnly';
  end;
end;

end.
