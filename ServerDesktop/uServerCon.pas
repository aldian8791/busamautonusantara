unit uServerCon;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, UniProvider,
  SQLiteUniProvider, Data.DB, DBAccess, Uni;

type
  TmServerCon = class(TDataModule)
    conbusamautonusantara: TUniConnection;
    pvdbusamautonusantara: TSQLiteUniProvider;
  private
    { Private declarations }
  public
    procedure dbmain;
  end;

var
  mServerCon: TmServerCon;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uServerCmd;

{$R *.dfm}

var
  busamautonusantara: string;

procedure TmServerCon.dbmain;
begin
  {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(IOS))}
  if directoryexists(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'BusamAutoNusantara'))= False then begin
    CreateDir(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
      'BusamAutoNusantara'));
    busamautonusantara:= '';
  end;
  documentfolder:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'BusamAutoNusantara');
  if FileExists(System.IOUtils.TPath.Combine(documentfolder,
    'busamautonusantara.ald'))= True then begin
    busamautonusantara:= System.IOUtils.TPath.Combine(documentfolder,
      'busamautonusantara.ald');
  end else begin
    busamautonusantara:= '';
  end;
  {$ENDIF}
  {$IF (DEFINED(ANDROID))}
  if directoryexists(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
    'BusamAutoNusantara'))= False then begin
    CreateDir(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
      'BusamAutoNusantara'));
    busamautonusantara:= '';
  end;
  documentfolder:= System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetPublicPath,
    'BusamAutoNusantara');
  if FileExists(System.IOUtils.TPath.Combine(documentfolder,
    'busamautonusantara.ald'))= True then begin
    busamautonusantara:= System.IOUtils.TPath.Combine(documentfolder,
      'busamautonusantara.ald');
  end else begin
    busamautonusantara:= '';
  end;
  {$ENDIF}
  if busamautonusantara<> '' then begin
    with conbusamautonusantara do begin
      ProviderName:= pvdbusamautonusantara.GetProviderName;
      Database:= busamautonusantara;
      {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(ANDROID))}
      SpecificOptions.Values['Direct']:= 'True'; //ios not support direct mode
      {$ENDIF}
    end;
  end else if busamautonusantara= '' then begin
    busamautonusantara:= System.IOUtils.TPath.Combine(documentfolder,
      'busamautonusantara.ald'); //set path for main database
    with conbusamautonusantara do begin
      ProviderName:= pvdbusamautonusantara.GetProviderName;
      Database:= busamautonusantara;
      SpecificOptions.Values['ForceCreateDatabase']:= 'True'; //if database not exist then create SQLite database
      {$IF (DEFINED(MSWINDOWS)) OR (DEFINED(LINUX64)) OR (DEFINED(OSX64)) OR (DEFINED(ANDROID))}
      SpecificOptions.Values['Direct']:= 'True'; //Direct version not available for IOS
      {$ENDIF}
      Connected:= True;
      ExecSQL('PRAGMA foreign_keys = OFF');
      ExecSQL('DROP TABLE IF EXISTS sys_uom');
      ExecSQL('DROP TABLE IF EXISTS sys_currency');
      ExecSQL('DROP TABLE IF EXISTS sys_user');
      ExecSQL('DROP TABLE IF EXISTS sys_city');
      ExecSQL('DROP TABLE IF EXISTS sys_state');
      ExecSQL('DROP TABLE IF EXISTS sys_country');
      ExecSQL('DROP TABLE IF EXISTS sys_option');
      ExecSQL('DROP TABLE IF EXISTS sys_print');
      ExecSQL('DROP TABLE IF EXISTS sys_table');
      ExecSQL('CREATE TABLE sys_table ( '+
        'tbid VARCHAR (50) NOT NULL, '+
        'tbcode VARCHAR (4) NOT NULL, '+
        'description VARCHAR (25) DEFAULT '''', '+
        'CONSTRAINT tbid_pkey PRIMARY KEY (tbid) ON CONFLICT ROLLBACK, '+
        'CONSTRAINT tbcode_ukey UNIQUE (tbcode) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_print ( '+
        'prid VARCHAR (50) NOT NULL, '+
        'prdocid VARCHAR (50) NOT NULL, '+
        'prdoc VARCHAR (50) NOT NULL, '+
        'pruser VARCHAR (20) DEFAULT '''', '+
        'prdate TEXT (30) NOT NULL, '+
        'CONSTRAINT prid_pkey PRIMARY KEY (prid) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_option ( '+
        'otid VARCHAR (50) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'otcode VARCHAR (20) NOT NULL, '+
        'description VARCHAR (50) DEFAULT '''', '+
        'otvalue VARCHAR (20) DEFAULT '''', '+
        'CONSTRAINT otid_pkey PRIMARY KEY (otid) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_country ( '+
        'cnid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'cncode CHARACTER (2) NOT NULL, '+
        'description VARCHAR (50) DEFAULT '''', '+
        'CONSTRAINT cnid_pkey PRIMARY KEY (cnid) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_state ( '+
        'stid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'stcode CHARACTER (2) NOT NULL, '+
        'description VARCHAR (50) DEFAULT '''', '+
        'cnid VARCHAR (50) DEFAULT NULL, '+
        'CONSTRAINT stid_pkey PRIMARY KEY (stid) ON CONFLICT ROLLBACK, '+
        'CONSTRAINT cnid_fkey FOREIGN KEY (cnid) REFERENCES sys_country (cnid) ON DELETE RESTRICT ON UPDATE CASCADE '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_city ( '+
        'ctid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'ctcode CHARACTER (3) NOT NULL, '+
        'description VARCHAR (50) DEFAULT '''', '+
        'stid VARCHAR (50) DEFAULT NULL, '+
        'CONSTRAINT ctid_pkey PRIMARY KEY (ctid) ON CONFLICT ROLLBACK, '+
        'CONSTRAINT stid_fkey FOREIGN KEY (stid) REFERENCES sys_state (stid) ON DELETE RESTRICT ON UPDATE CASCADE '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_user ( '+
        'urid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'urtype TINYINT (1) NOT NULL DEFAULT 0, '+
        'urname VARCHAR (20) NOT NULL, '+
        'urpassword VARCHAR (400) NOT NULL, '+
        'urfullname VARCHAR (50) NOT NULL, '+
        'jbcode CHARACTER (3) DEFAULT NULL, '+
        'dmcode CHARACTER (3) DEFAULT NULL, '+
        'kick BOOLEAN NOT NULL DEFAULT FALSE, '+
        'CONSTRAINT urid_pkey PRIMARY KEY (urid) ON CONFLICT ROLLBACK, '+
        'CONSTRAINT urname_ukey UNIQUE (urname) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('CREATE TABLE sys_currency ( '+
        'cyid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'cycode VARCHAR (20) NOT NULL, '+
        'description VARCHAR (50) NOT NULL, '+
        'CONSTRAINT cyid_pkey PRIMARY KEY (cyid) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');        
      ExecSQL('CREATE TABLE sys_uom ( '+
        'umid VARCHAR (50) NOT NULL, '+
        'newuser VARCHAR (20) NOT NULL, '+
        'newdate TEXT (30) NOT NULL, '+
        'edituser VARCHAR (20) NOT NULL, '+
        'editdate TEXT (30) NOT NULL, '+
        'inactive BOOLEAN NOT NULL DEFAULT FALSE, '+
        'note TEXT DEFAULT '''', '+
        'umcode VARCHAR (10) NOT NULL, '+
        'description VARCHAR (50) DEFAULT '''', '+
        'CONSTRAINT umid_pkey PRIMARY KEY (umid) ON CONFLICT ROLLBACK '+
        ') '+
        'WITHOUT ROWID');
      ExecSQL('PRAGMA foreign_keys = ON');
      ExecSQL('VACUUM');
      try
        if InTransaction= True then begin
          Rollback;
        end;
        StartTransaction;
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-1'', ''TB'', ''Table'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-2'', ''PR'', ''Print'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-3'', ''OT'', ''Option'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-4'', ''CN'', ''Country'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-5'', ''ST'', ''State'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-6'', ''CT'', ''City'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-7'', ''UR'', ''UserRegister'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-8'', ''CY'', ''Currency'')');
        ExecSQL('INSERT OR IGNORE INTO sys_table VALUES '+
          '(''TBBPP-9'', ''UM'', ''UnitofMeasurement'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''myversion'', ''Version'', ''1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''mymessage'', ''Message Server'', ''Version 1.0.1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-3'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''maintenance'', ''Maintenance Server'', ''0'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-4'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''currency'', ''Currency'', ''IDR'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-5'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''vatpercent'', ''VAT Percent'', ''11'')');
        ExecSQL('INSERT OR IGNORE INTO sys_option VALUES '+
          '(''OTBPP-6'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''precisionother'', ''Other Precision'', ''2'')');
        ExecSQL('INSERT OR IGNORE INTO sys_country VALUES '+
          '(''CNBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''ID'', '+
          '''Indonesia'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''AC'', ''Aceh'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SU'', ''Sumatera Utara'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-3'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SB'', ''Sumatera Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-4'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''RI'', ''Riau'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-5'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''JA'', ''Jambi'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-6'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SS'', ''Sumatera Selatan'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-7'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''BE'', ''Bengkulu'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-8'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''LA'', ''Lampung'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-9'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''BB'', ''Kepulauan Bangka Belitung'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-10'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''KR'', ''Kepulauan Riau'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-11'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''JK'', ''Daerah Khusus Ibukota Jakarta'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-12'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''JB'', ''Jawa Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-13'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''JT'', ''Jawa Tengah'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-14'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''YO'', ''Daerah Istimewa Yogyakarta'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-15'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''JI'', ''Jawa Timur'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-16'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''BT'', ''Banten'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-17'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''BA'', ''Bali'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-18'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''NB'', ''Nusa Tenggara Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-19'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''NT'', ''Nusa Tenggara Timur'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-20'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''KB'', ''Kalimantan Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-21'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''KT'', ''Kalimantan Tengah'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-22'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''KS'', ''Kalimantan Selatan'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-23'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''KI'', ''Kalimantan Timur'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-24'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SA'', ''Sulawesi Utara'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-25'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''ST'', ''Sulawesi Tengah'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-26'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SN'', ''Sulawesi Selatan'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-27'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SG'', ''Sulawesi Tenggara'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-28'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''GO'', ''Gorontalo'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-29'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SR'', ''Sulawesi Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-30'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''MA'', ''Maluku'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-31'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''MU'', ''Maluku Utara'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-32'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''PA'', ''Papua'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_state VALUES '+
          '(''STBPP-33'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''PB'', ''Papua Barat'', ''CNBPP-1'')');
        ExecSQL('INSERT OR IGNORE INTO sys_city VALUES '+
          '(''CTBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''BPP'', ''Balikpapan'', ''STBPP-23'')');
        ExecSQL('INSERT OR IGNORE INTO sys_city VALUES '+
          '(''CTBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', '+
          '''SMR'', ''Samarinda'', ''STBPP-23'')');
        ExecSQL('INSERT OR IGNORE INTO sys_user VALUES '+
          '(''URBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), true, '''', 2, '+
          '''aldian'', ''FRtJxtiBYDGP4RLwT3pZ3A=='', ''Aldian Abdilla'', NULL, '+
          'NULL, true)');
        ExecSQL('INSERT OR IGNORE INTO sys_user VALUES '+
          '(''URBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', 1, '+
          '''khahar'', ''mVh1ujZTyHvVIlMzQaqJMQ=='', ''Khahar Syahruddin'', NULL, '+
          'NULL, false)');
        ExecSQL('INSERT OR IGNORE INTO sys_user VALUES '+
          '(''URBPP-3'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', 0, '+
          '''training'', ''w+wEHM9Ul6QNN5vRxggjuw=='', ''Training System'', NULL, '+
          'NULL, false)');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''IDR'', '+
          '''RUPIAH'')');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''CNY'', '+
          '''YUAN'')');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-3'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''EUR'', '+
          '''EURO'')');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-4'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''SGD'', '+
          '''SINGAPORE DOLLAR'')');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-5'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''USD'', '+
          '''US DOLLAR'')');
        ExecSQL('INSERT OR IGNORE INTO sys_currency VALUES '+
          '(''CYBPP-6'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''JPY'', '+
          '''YEN'')');
        ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-1'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''APL'', ''Ampul'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-2'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''ASSY'', ''Assy'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-3'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''BAG'', ''Bag'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-4'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''BOOK'', ''Book'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-5'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''BOX'', ''Box'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-6'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''BT'', ''Bottle'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-7'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''CAN'', ''Canister'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-8'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''CM'', ''Centimeter'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-9'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''CYL'', ''Cylinder'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-10'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''DR'', ''Drum'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-11'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''DZ'', ''Dozen'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-12'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''EA'', ''Each'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-13'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''EKOR'', ''Ekor'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-14'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''GL'', ''Gallon'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-15'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''IKAT'', ''Ikat'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-16'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''JNT'', ''Joint'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-17'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''KG'', ''Kilogram'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-18'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''LENGTH'', ''Length'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-19'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''LOT'', ''Lot'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-20'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''M3'', ''Cubic Meter'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-21'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''MTR'', ''Meter'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-22'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''PACK'', ''Pack'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-23'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''PAIL'', ''Pail'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-24'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''PCS'', ''Pieces'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-25'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''PR'', ''Pair'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-26'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''RIM'', ''Rim'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-27'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''RL'', ''Roll'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-28'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''SACK'', ''Sack'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-29'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''SET'', ''Set'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-30'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''SHT'', ''Sheet'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-31'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''SSR'', ''Sisir'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-32'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''STRIP'', ''Strip'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-33'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''TB'', ''Tube'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-34'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''TON'', ''Tonage'')');
	      ExecSQL('INSERT OR IGNORE INTO sys_uom VALUES '+
          '(''UMBPP-35'', ''aldian'', datetime(''now'', ''localtime''), '+
          '''aldian'', datetime(''now'', ''localtime''), false, '''', ''UNIT'', ''Unit'')');
        Commit;
        Connected:= False;
      except
        Rollback;
        raise;
      end;
    end;
  end;
end;

end.
