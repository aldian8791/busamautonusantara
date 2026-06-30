unit EnCryptDeCrypt;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation, (* Database *)SQLiteUniProvider,
  UniProvider, DBAccess, Data.DB, MemDS, Uni(* Database *),
  uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_Constants,
  {$IF (DEFINED(MSWINDOWS))} WinApi.Windows, {$ELSE} Posix.Unistd, {$ENDIF}
  FMX.TMSFNCCustomComponent;

type
  TForm1 = class(TForm)
    grbAesSQLite: TGroupBox;
    btnBrowseAesSQLiteDec: TButton;
    btnBrowseAesSQLiteEnc: TButton;
    edtAesSQLiteEnc: TEdit;
    edtAesSQLiteDec: TEdit;
    btnAesSQLiteEnc: TButton;
    btnAesSQLiteDec: TButton;
    grbAesText: TGroupBox;
    edtAesTextEnc: TEdit;
    edtAesTextDec: TEdit;
    btnAesTextEnc: TButton;
    btnAesTextDec: TButton;
    odlAesSQLiteEnc: TOpenDialog;
    odlAesSQLiteDec: TOpenDialog;
    grbAesFile: TGroupBox;
    btnBrowseAesFileDec: TButton;
    btnBrowseAesFileEnc: TButton;
    edtAesFileEnc: TEdit;
    edtAesFileDec: TEdit;
    btnAesFileEnc: TButton;
    btnAesFileDec: TButton;
    odlAesFileEnc: TOpenDialog;
    odlAesFileDec: TOpenDialog;
    grbCRC32File: TGroupBox;
    btnBrowseCRC32File: TButton;
    edtCRC32File: TEdit;
    btnCRC32FileSum: TButton;
    edtCRC32FileSum: TEdit;
    odlCRC32File: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAesTextEncClick(Sender: TObject);
    procedure btnAesTextDecClick(Sender: TObject);
    procedure btnAesFileEncClick(Sender: TObject);
    procedure btnAesFileDecClick(Sender: TObject);
    procedure btnAesSQLiteEncClick(Sender: TObject);
    procedure btnAesSQLiteDecClick(Sender: TObject);
    procedure btnBrowseAesSQLiteEncClick(Sender: TObject);
    procedure btnBrowseAesSQLiteDecClick(Sender: TObject);
    procedure btnBrowseAesFileEncClick(Sender: TObject);
    procedure btnBrowseAesFileDecClick(Sender: TObject);
    procedure btnBrowseCRC32FileClick(Sender: TObject);
    procedure btnCRC32FileSumClick(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses uUserPassword;

var
  CryptoLib: TCryptographicLibrary;
  myCodec: TCodec;

const
  READBUFFERSIZE = 4096;
  CRCSeed = $ffffffff;
  CRC32Table : array[0..255] of Cardinal = (
      $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f,
      $e963a535, $9e6495a3, $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988,
      $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91, $1db71064, $6ab020f2,
      $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
      $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9,
      $fa0f3d63, $8d080df5, $3b6e20c8, $4c69105e, $d56041e4, $a2677172,
      $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b, $35b5a8fa, $42b2986c,
      $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
      $26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423,
      $cfba9599, $b8bda50f, $2802b89e, $5f058808, $c60cd9b2, $b10be924,
      $2f6f7c87, $58684c11, $c1611dab, $b6662d3d, $76dc4190, $01db7106,
      $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
      $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d,
      $91646c97, $e6635c01, $6b6b51f4, $1c6c6162, $856530d8, $f262004e,
      $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457, $65b0d9c6, $12b7e950,
      $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
      $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7,
      $a4d1c46d, $d3d6f4fb, $4369e96a, $346ed9fc, $ad678846, $da60b8d0,
      $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9, $5005713c, $270241aa,
      $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
      $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81,
      $b7bd5c3b, $c0ba6cad, $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a,
      $ead54739, $9dd277af, $04db2615, $73dc1683, $e3630b12, $94643b84,
      $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
      $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb,
      $196c3671, $6e6b06e7, $fed41b76, $89d32be0, $10da7a5a, $67dd4acc,
      $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5, $d6d6a3e8, $a1d1937e,
      $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
      $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55,
      $316e8eef, $4669be79, $cb61b38c, $bc66831a, $256fd2a0, $5268e236,
      $cc0c7795, $bb0b4703, $220216b9, $5505262f, $c5ba3bbe, $b2bd0b28,
      $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
      $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f,
      $72076785, $05005713, $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38,
      $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242,
      $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
      $88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69,
      $616bffd3, $166ccf45, $a00ae278, $d70dd2ee, $4e048354, $3903b3c2,
      $a7672661, $d06016f7, $4969474d, $3e6e77db, $aed16a4a, $d9d65adc,
      $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
      $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693,
      $54de5729, $23d967bf, $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94,
      $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d  );

function CRC32(value: Byte; crc: Cardinal): Cardinal;
begin
  Result := CRC32Table[Byte(crc xor Cardinal(value))] xor
    ((crc shr 8) and $00ffffff);
end;

function CRCEnd(crc: Cardinal): Cardinal;
begin
  CRCEnd := (crc xor CRCSeed);
end;

function GetChecksumOfFile(Filename: string; var AFileExists: Boolean): Integer;
var
  fh: THandle;
  buf: array[0..READBUFFERSIZE - 1] of Byte;
  tmp, I, tmpRes: Cardinal;
begin
  tmpRes := CRCSeed;
  if not FileExists(FileName) then
    AFileExists := False
  else begin
    fh := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
    if fh > 0 then begin
      repeat
        tmp := FileRead(fh, buf, READBUFFERSIZE);
        for I := 1 to tmp do
          tmpRes := tmpRes + CRC32(buf[I - 1], tmpRes);
      until tmp <> READBUFFERSIZE;
      FileClose(fh);
    end;
  end;
  tmpRes := CRCEnd(tmpRes);
  Result := Integer(tmpRes);
end;

procedure TForm1.btnAesFileDecClick(Sender: TObject);
begin
  if odlAesFileDec.FileName<> '' then begin
    myCodec.DecryptFile(ExtractFilePath(odlAesFileDec.FileName)+ 'Decrypt_'+
      ExtractFileName(odlAesFileDec.FileName), edtAesFileDec.Text);
    edtAesFileEnc.Text:= ExtractFilePath(odlAesFileDec.FileName)+ 'Decrypt_'+
      ExtractFileName(odlAesFileDec.FileName);
    odlAesFileDec.FileName:= '';
  end else if odlAesFileDec.FileName= '' then begin
    edtAesFileDec.Text:= '';
    edtAesFileEnc.Text:= '';
  end;
end;

procedure TForm1.btnBrowseCRC32FileClick(Sender: TObject);
begin
  odlCRC32File.InitialDir:= System.IOUtils.TPath.GetDocumentsPath;
  odlCRC32File.Options:= [TOpenOption.ofReadOnly];
  if odlCRC32File.Execute then begin
    edtCRC32File.Text:= odlCRC32File.FileName;
  end;
end;

procedure TForm1.btnCRC32FileSumClick(Sender: TObject);
var
  cs: Integer;
  fe: Boolean;
begin
  fe := True;
  cs := GetCheckSumOfFile(edtCRC32File.Text, fe);
  edtCRC32FileSum.Text:= IntToStr(cs);
end;

procedure TForm1.btnBrowseAesSQLiteDecClick(Sender: TObject);
begin
  odlAesSQLiteDec.InitialDir:=
    System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'riften1978');
  odlAesSQLiteDec.Options:= [TOpenOption.ofReadOnly];
  odlAesSQLiteDec.Filter:= 'Database Files (*.ald;*.sef)|*.ald;*.sef';
  if odlAesSQLiteDec.Execute then begin
    edtAesSQLiteDec.Text:= odlAesSQLiteDec.FileName;
  end;
end;

procedure TForm1.btnBrowseAesSQLiteEncClick(Sender: TObject);
begin
  odlAesSQLiteEnc.InitialDir:=
    System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
    'riften1978');
  odlAesSQLiteEnc.Options:= [TOpenOption.ofReadOnly];
  odlAesSQLiteEnc.Filter:= 'Database Files (*.ald;*.sef)|*.ald;*.sef';
  if odlAesSQLiteEnc.Execute then begin
    edtAesSQLiteEnc.Text:= odlAesSQLiteEnc.FileName;
  end;
end;

procedure TForm1.btnAesTextEncClick(Sender: TObject);
var
  myEncrypted: string;
begin
  myCodec.EncryptString(edtAesTextEnc.Text.Trim, myEncrypted, TEncoding.UTF8);
  edtAesTextDec.Text:= myEncrypted;
end;

procedure TForm1.btnAesTextDecClick(Sender: TObject);
var
  myDecrypted: string;
begin
  myCodec.DecryptString(myDecrypted, edtAesTextDec.Text.Trim, TEncoding.UTF8);
  edtAesTextEnc.Text:= myDecrypted;
end;

procedure TForm1.btnAesSQLiteEncClick(Sender: TObject);
var
  pvdAesSQLite: TSQLiteUniProvider;
  conAesSQLite: TUniConnection;
begin
  pvdAesSQLite:= TSQLiteUniProvider.Create(self);
  conAesSQLite:= TUniConnection.Create(self);
  try
    if FileExists(edtAesSQLiteEnc.Text)= True then begin
      with conAesSQLite do begin
        ProviderName:= pvdAesSQLite.GetProviderName;
        Database:= edtAesSQLiteEnc.Text;
        SpecificOptions.Values['Direct']:= 'True';
        SpecificOptions.Values['EncryptionAlgorithm']:= 'leAES256';
        SpecificOptions.Values['EncryptionKey']:= '';
        Connected:= True;
      end;
      TLiteUtils.EncryptDatabase(conAesSQLite, aeskey);
    end;
  finally
    FreeAndNil(conAesSQLite);
    FreeAndNil(pvdAesSQLite);
  end;
end;

procedure TForm1.btnAesSQLiteDecClick(Sender: TObject);
var
  pvdAesSQLite: TSQLiteUniProvider;
  conAesSQLite: TUniConnection;
begin
  pvdAesSQLite:= TSQLiteUniProvider.Create(self);
  conAesSQLite:= TUniConnection.Create(self);
  try
    if FileExists(edtAesSQLiteDec.Text)= True then begin
      with conAesSQLite do begin
        ProviderName:= pvdAesSQLite.GetProviderName;
        Database:= edtAesSQLiteDec.Text;
        SpecificOptions.Values['Direct']:= 'True';
        SpecificOptions.Values['EncryptionAlgorithm']:= 'leAES256';
        SpecificOptions.Values['EncryptionKey']:= aeskey;
        Connected:= True;
      end;
      TLiteUtils.EncryptDatabase(conAesSQLite, '');
    end;
  finally
    FreeAndNil(conAesSQLite);
    FreeAndNil(pvdAesSQLite);
  end;
end;

procedure TForm1.btnBrowseAesFileDecClick(Sender: TObject);
begin
  odlAesFileDec.InitialDir:= System.IOUtils.TPath.GetDocumentsPath;
  odlAesFileDec.Options:= [TOpenOption.ofReadOnly];
  if odlAesFileDec.Execute then begin
    edtAesFileDec.Text:= odlAesFileDec.FileName;
  end;
end;

procedure TForm1.btnBrowseAesFileEncClick(Sender: TObject);
begin
  odlAesFileEnc.InitialDir:= System.IOUtils.TPath.GetDocumentsPath;
  odlAesFileEnc.Options:= [TOpenOption.ofReadOnly];
  if odlAesFileEnc.Execute then begin
    edtAesFileEnc.Text:= odlAesFileEnc.FileName;
  end;
end;

procedure TForm1.btnAesFileEncClick(Sender: TObject);
begin
  if odlAesFileEnc.FileName<> '' then begin
    myCodec.EncryptFile(edtAesFileEnc.Text,
      ExtractFilePath(odlAesFileEnc.FileName)+ 'Encrypt_'+
      ExtractFileName(odlAesFileEnc.FileName));
    edtAesFileDec.Text:= ExtractFilePath(odlAesFileEnc.FileName)+ 'Encrypt_'+
      ExtractFileName(odlAesFileEnc.FileName);
      odlAesFileEnc.FileName:= '';
  end else if odlAesFileEnc.FileName= '' then begin
    edtAesFileEnc.Text:= '';
    edtAesFileDec.Text:= '';
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CryptoLib:= TCryptographicLibrary.Create(self);
  myCodec:= TCodec.Create(self);
  myCodec.CryptoLibrary:= CryptoLib;
  myCodec.StreamCipherId:= BlockCipher_ProgId;
  myCodec.BlockCipherId:= Format(AES_ProgId, [256]);
  myCodec.ChainModeId:= ECB_ProgId;
  myCodec.Password:= aeskey;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(myCodec)= True then FreeAndNil(myCodec);
  if Assigned(CryptoLib)= True then FreeAndNil(CryptoLib);
end;

end.
