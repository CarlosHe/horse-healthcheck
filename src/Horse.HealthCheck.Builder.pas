unit Horse.HealthCheck.Builder;

interface

uses
  Horse.HealthCheck.Abstract, Horse.HealthCheck.Result;

type
  THorseHealthCheckBuilder = class(THorseHealthCheckAbstract)
  private
    { private declarations }
    FHorseHealthCheckResult: THorseHealthCheckResult;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AHorseHealthCheckResult: THorseHealthCheckResult);
    destructor Destroy; override;
    function CheckHealth: THorseHealthCheckResult; override;
  end;

implementation

uses
  System.SysUtils;

{ THorseHealthCheckBuilder }

function THorseHealthCheckBuilder.CheckHealth: THorseHealthCheckResult;
begin
  Result := THorseHealthCheckResult.Create(
    FHorseHealthCheckResult.Status,
    FHorseHealthCheckResult.Description,
    FHorseHealthCheckResult.Exception,
    FHorseHealthCheckResult.Data
  );
end;

constructor THorseHealthCheckBuilder.Create(AHorseHealthCheckResult: THorseHealthCheckResult);
begin
  FHorseHealthCheckResult := AHorseHealthCheckResult;
end;

destructor THorseHealthCheckBuilder.Destroy;
begin
  FreeAndNil(FHorseHealthCheckResult);
  inherited;
end;

end.
