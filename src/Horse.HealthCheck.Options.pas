unit Horse.HealthCheck.Options;

interface

uses
  Horse.Commons,
  Horse.HealthCheck.Types;

type

  THorseHealthCheckOptions = class
  private
    { private declarations }
    FEncode: string;
    FResultStatusCodes: TResultStatusCodes;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    function SetResultEncode(AEncode: string): THorseHealthCheckOptions;
    function GetResultEncode(out AEncode: string): THorseHealthCheckOptions;
    function SetResultStatusCodes(AResultStatusCodes: TResultStatusCodes): THorseHealthCheckOptions;
    function GetResultStatusCodes(out AResultStatusCodes: TResultStatusCodes): THorseHealthCheckOptions;
  end;

implementation

uses
  System.SysUtils;

const
  sDefaultEncode = 'UTF-8';

{ THorseHealthCheckOptions }

constructor THorseHealthCheckOptions.Create;
begin
  FEncode := sDefaultEncode;
  FResultStatusCodes := TResultStatusCodes.Create;
  FResultStatusCodes.Add(THorseHealthStatus.Healthy, THTTPStatus.Ok);
  FResultStatusCodes.Add(THorseHealthStatus.Degraded, THTTPStatus.Ok);
  FResultStatusCodes.Add(THorseHealthStatus.Unhealthy, THTTPStatus.ServiceUnavailable);
end;

destructor THorseHealthCheckOptions.Destroy;
begin
  if FResultStatusCodes <> nil then
    FreeAndNil(FResultStatusCodes);
  inherited;
end;

function THorseHealthCheckOptions.GetResultEncode(out AEncode: string): THorseHealthCheckOptions;
begin
  Result := Self;
  AEncode := FEncode;
end;

function THorseHealthCheckOptions.GetResultStatusCodes(out AResultStatusCodes: TResultStatusCodes): THorseHealthCheckOptions;
begin
  Result := Self;
  AResultStatusCodes := FResultStatusCodes;
end;

function THorseHealthCheckOptions.SetResultEncode(AEncode: string): THorseHealthCheckOptions;
begin
  Result := Self;
  FEncode := AEncode;
end;

function THorseHealthCheckOptions.SetResultStatusCodes(AResultStatusCodes: TResultStatusCodes): THorseHealthCheckOptions;
begin
  Result := Self;
  if FResultStatusCodes <> nil then
    FreeAndNil(FResultStatusCodes);
  FResultStatusCodes := AResultStatusCodes;
end;

end.
