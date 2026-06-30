unit uClientFrmCursor;

interface

uses
  FMX.Platform, FMX.Types, System.UITypes;

type
  TmClientFrmCursor = class(TInterfacedObject, IFMXCursorService)
  private
    class var FPreviousPlatformService: IFMXCursorService;
    class var FAllFormCursorService: TmClientFrmCursor;
    class var FCursorOverride: TCursor;
    class procedure SetCursorOverride(const Value: TCursor); static;
  public
    class property CursorOverride: TCursor read FCursorOverride write SetCursorOverride;

    class constructor Create;
    procedure SetCursor(const ACursor: TCursor);
    function GetCursor: TCursor;
  end;

implementation

{ TWinCursorService }

class constructor TmClientFrmCursor.Create;
begin
  FAllFormCursorService:= TmClientFrmCursor.Create;

  FPreviousPlatformService:= TPlatformServices.Current.GetPlatformservice(IFMXCursorService) as IFMXCursorService; // TODO: if not assigned

  TPlatformServices.Current.RemovePlatformService(IFMXCursorService);
  TPlatformServices.Current.AddPlatformService(IFMXCursorService, FAllFormCursorService);
end;

function TmClientFrmCursor.GetCursor: TCursor;
begin
  result:=  FPreviousPlatformService.GetCursor;
end;

procedure TmClientFrmCursor.SetCursor(const ACursor: TCursor);
begin
  if FCursorOverride= crDefault then
  begin
    FPreviousPlatformService.SetCursor(ACursor);
  end
  else
  begin
    FPreviousPlatformService.SetCursor(FCursorOverride);
  end;
end;


class procedure TmClientFrmCursor.SetCursorOverride(const Value: TCursor);
begin
  FCursorOverride:= Value;
  TmClientFrmCursor.FPreviousPlatformService.SetCursor(FCursorOverride);
end;

end.