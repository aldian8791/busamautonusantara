program EnCrypt_DeCrypt;

uses
  System.StartUpCopy,
  FMX.Forms,
  EnCryptDeCrypt in 'EnCryptDeCrypt.pas' {Form1},
  uUserPassword in '..\Databases\uUserPassword.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
