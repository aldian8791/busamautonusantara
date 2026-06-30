unit uClientOS;

interface

uses
  System.SysUtils, {$IF (DEFINED(MSWINDOWS))}Vcl.Graphics, Winapi.Messages,
  Winapi.Shellapi, Winapi.Windows, FMX.Platform.Win, Winapi.DwmApi,{$ENDIF}
  FMX.Forms, FMX.Platform;

type
  TmClientOS = class
  private
  public
    class procedure ChangeFormIcon(myForm: TForm); static;
    class procedure SetDarkModeTitleBar(const AForm: TCommonCustomForm;
      const Enabled: Boolean); static;
    class function OSDarkMode: Boolean; static;
  end;

implementation

uses uClientCmd;

class procedure TmClientOS.SetDarkModeTitleBar(const AForm: TCommonCustomForm;
  const Enabled: Boolean);
{$IF (DEFINED(MSWINDOWS))}
const
  DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
var
  Value: BOOL;
  myHWND: HWND;
{$ENDIF}
begin
  {$IF (DEFINED(MSWINDOWS))}
  myHWND:= FmxHandleToHWND(AForm.Handle);
  if myHWND= 0 then Exit;
  Value:= Enabled;
  DwmSetWindowAttribute(myHWND, DWMWA_USE_IMMERSIVE_DARK_MODE, @Value,
    SizeOf(Value));
  SendMessage(myHWND, WM_NCACTIVATE, 0, 0);
  SendMessage(myHWND, WM_NCACTIVATE, 1, 0);
  {$ENDIF}
end;

class procedure TmClientOS.ChangeFormIcon(myForm: TForm);
{$IF (DEFINED(MSWINDOWS))}
var
  NewIcon: TIcon;
  hIconBig, hIconSmall: HICON;
  myHWND: HWND;
{$ENDIF}
begin
  {$IF (DEFINED(MSWINDOWS))}
  if not Assigned(mrsIcon) then Exit;
  if mrsIcon.Size <= 0 then Exit;
  NewIcon:= TIcon.Create;
  try
    mrsIcon.Position:= 0;
    NewIcon.LoadFromStream(mrsIcon);
    hIconBig:= CopyIcon(NewIcon.Handle);
    hIconSmall:= CopyIcon(NewIcon.Handle);
    myHWND:= WindowHandleToPlatform(myForm.Handle).Wnd;
    //Taskbar icon
    SendMessage(ApplicationHWND, WM_SETICON, ICON_BIG, LPARAM(hIconBig));
    SendMessage(ApplicationHWND, WM_SETICON, ICON_SMALL, LPARAM(hIconSmall));
    //Titlebar icon
    SendMessage(myHWND, WM_SETICON, ICON_BIG, LPARAM(hIconBig));
    SendMessage(myHWND, WM_SETICON, ICON_SMALL, LPARAM(hIconSmall));
    SetWindowPos(myHWND, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
      SWP_NOZORDER or SWP_FRAMECHANGED);
    RedrawWindow(myHWND, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
  finally
    FreeAndNil(NewIcon);
  end;
  {$ENDIF}
end;

class function TmClientOS.OSDarkMode: Boolean;
//to check is OS in Dark mode or Light Mode
{$IF (DEFINED(LINUX))}
var
  LBuffer : array[0..512] of Byte;
  LHandle : PFile;
  LResult : string;
function RunCommand(const ACmd: string): string;
begin
  Result := '';
  LHandle := popen(MarshaledAString(UTF8String(ACmd)), 'r');
  if LHandle <> nil then begin
    try
      while fgets(@LBuffer, SizeOf(LBuffer), LHandle) <> nil do
        Result := Result + UTF8ToString(@LBuffer);
    finally
      pclose(LHandle);
    end;
  end;
  Result := Result.Trim;
end;
{$ELSE}
var
  LService: IFMXSystemAppearanceService;
{$ENDIF}
begin
  {$IF (DEFINED(LINUX))}
  LResult := RunCommand('dbus-send --print-reply=literal '+
    '--dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop ' +
    'org.freedesktop.portal.Settings.Read string:org.freedesktop.appearance '+
    'string:color-scheme');
  if LResult.Contains('uint32 1') then Exit(True);
  LResult := RunCommand('gsettings get org.gnome.desktop.interface color-scheme');
  Exit(LResult.Contains('prefer-dark'));
  {$ELSE}
  if TPlatformServices.Current.SupportsPlatformService(
       IFMXSystemAppearanceService, LService) then begin
    Exit(LService.GetSystemThemeKind = TSystemThemeKind.Dark);
  end;
  Exit(False);
  {$ENDIF}
end;

end.
