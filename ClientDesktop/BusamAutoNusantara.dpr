program BusamAutoNusantara;

uses
  System.StartUpCopy,
  System.SysUtils,
  FMX.Forms,
  FMX.Platform,
  FMX.Types,
  uBusamAutoNusantara in 'Forms\uBusamAutoNusantara.pas' {fMain},
  uLogin in 'Forms\System\uLogin.pas' {fLogin},
  uClientCmd in '..\ShareModules\uClientCmd.pas',
  uClientSet in '..\ShareModules\uClientSet.pas',
  uClientCon in '..\ShareModules\uClientCon.pas' {mClientCon: TDataModule},
  uClientOS in '..\ShareModules\uClientOS.pas',
  uServerCon in '..\ServerDesktop\uServerCon.pas' {mServerCon: TDataModule},
  uServerCmd in '..\ServerDesktop\uServerCmd.pas',
  cLogin in '..\ServerDesktop\cLogin.pas',
  uChangePwd in 'Forms\System\uChangePwd.pas' {fChangePwd},
  uAbout in 'Forms\uAbout.pas' {fAbout},
  cUserRegister in '..\ServerDesktop\cUserRegister.pas',
  uClientFrmCursor in '..\ShareModules\uClientFrmCursor.pas',
  uOptions in 'Forms\System\uOptions.pas' {fOptions},
  cOptions in '..\ServerDesktop\cOptions.pas',
  uCountry in 'Forms\Masters\uCountry.pas' {fCountry},
  cCountry in '..\ServerDesktop\cCountry.pas',
  uCountryInput in 'Forms\Masters\uCountryInput.pas' {fCountryInput},
  uState in 'Forms\Masters\uState.pas' {fState},
  uStateInput in 'Forms\Masters\uStateInput.pas' {fStateInput},
  cState in '..\ServerDesktop\cState.pas',
  uCity in 'Forms\Masters\uCity.pas' {fCity},
  uCityInput in 'Forms\Masters\uCityInput.pas' {fCityInput},
  cCity in '..\ServerDesktop\cCity.pas',
  uCurrency in 'Forms\Masters\uCurrency.pas' {fCurrency},
  uCurrencyInput in 'Forms\Masters\uCurrencyInput.pas' {fCurrencyInput},
  cCurrency in '..\ServerDesktop\cCurrency.pas',
  uNumberMap in 'Forms\System\uNumberMap.pas' {fNumberMap},
  cNumberMap in '..\ServerDesktop\cNumberMap.pas',
  uUserRegister in 'Forms\Masters\uUserRegister.pas' {fUserRegister},
  uUserRegisterInput in 'Forms\Masters\uUserRegisterInput.pas' {fUserRegisterInput},
  uPrintReport in 'Forms\System\uPrintReport.pas' {fPrintReport},
  uUserPassword in '..\Databases\uUserPassword.pas';

{$R *.res}

var
  myfs: TFormatSettings;
  ScreenService: IFMXScreenService;

begin
  myfs:= TFormatSettings.Create; //custom format setting
  with myfs do begin
    DateSeparator:= '/';
    ShortDateFormat:= 'dd-mm-yyyy';
    LongDateFormat:= 'dddd, dd mmmm yyyy';
    TimeSeparator:= ':';
    ShortTimeFormat:= 'hh:nn';
    LongTimeFormat:= 'hh:nn:ss';
    ThousandSeparator:= '.';
    DecimalSeparator:= ',';
    CurrencyString:= 'Rp';
    CurrencyFormat:= 2;
    CurrencyDecimals:= 6;
    NegCurrFormat:= 12;
    ShortMonthNames[1]:= 'Jan';
    ShortMonthNames[2]:= 'Feb';
    ShortMonthNames[3]:= 'Mar';
    ShortMonthNames[4]:= 'Apr';
    ShortMonthNames[5]:= 'Mei';
    ShortMonthNames[6]:= 'Jun';
    ShortMonthNames[7]:= 'Jul';
    ShortMonthNames[8]:= 'Agu';
    ShortMonthNames[9]:= 'Sep';
    ShortMonthNames[10]:= 'Okt';
    ShortMonthNames[11]:= 'Nop';
    ShortMonthNames[12]:= 'Des';
    LongMonthNames[1]:= 'Januari';
    LongMonthNames[2]:= 'Februari';
    LongMonthNames[3]:= 'Maret';
    LongMonthNames[4]:= 'April';
    LongMonthNames[5]:= 'Mei';
    LongMonthNames[6]:= 'Juni';
    LongMonthNames[7]:= 'Juli';
    LongMonthNames[8]:= 'Agustus';
    LongMonthNames[9]:= 'September';
    LongMonthNames[10]:= 'Oktober';
    LongMonthNames[11]:= 'November';
    LongMonthNames[12]:= 'Desember';
    ShortDayNames[1]:= 'Min';
    ShortDayNames[2]:= 'Sen';
    ShortDayNames[3]:= 'Sel';
    ShortDayNames[4]:= 'Rab';
    ShortDayNames[5]:= 'Kam';
    ShortDayNames[6]:= 'Jum';
    ShortDayNames[7]:= 'Sab';
    LongDayNames[1]:= 'Minggu';
    LongDayNames[2]:= 'Senin';
    LongDayNames[3]:= 'Selasa';
    LongDayNames[4]:= 'Rabu';
    LongDayNames[5]:= 'Kamis';
    LongDayNames[6]:= 'Jumat';
    LongDayNames[7]:= 'Sabtu';
    TwoDigitYearCenturyWindow:= 50;
    ListSeparator:= ',';
  end;
  System.SysUtils.FormatSettings:= myfs;

  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    IInterface(ScreenService))= True then begin
    ScreenService.SetSupportedScreenOrientations([TScreenOrientation.Landscape]); //force screen orientation
  end;

  {$IFOPT D+}
  ReportMemoryLeaksOnShutdown:= True; //check memory leak when close application in debug mode
  {$ENDIF}

  {$IF (DEFINED(ANDROID)) OR (DEFINED(IOS))}
  Application.ShowHint:= False; //android and ios does not support component hints
  {$ENDIF}

  Application.Initialize;
  Application.CreateForm(TmClientCon, mClientCon);
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TmServerCon, mServerCon);
  Application.Run;
end.
