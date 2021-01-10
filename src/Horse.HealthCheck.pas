unit Horse.HealthCheck;

interface

uses
  Horse,
  Horse.HealthCheck.Abstract,
  Horse.HealthCheck.Contract,
  Horse.HealthCheck.Builder,
  Horse.HealthCheck.Helpers,
  Horse.HealthCheck.Manager,
  Horse.HealthCheck.Options,
  Horse.HealthCheck.Result,
  Horse.HealthCheck.Types;

type

  IHorseHealthChecker = Horse.HealthCheck.Contract.IHorseHealthCheck;
  THorseHealthCheckAbstract = Horse.HealthCheck.Abstract.THorseHealthCheckAbstract;
  THorseHealthCheckBuilder = Horse.HealthCheck.Builder.THorseHealthCheckBuilder;
  THorseHealthStatusHelper = Horse.HealthCheck.Helpers.THorseHealthStatusHelper;
  THorseHealthCheckResultHelper = Horse.HealthCheck.Helpers.THorseHealthCheckResultHelper;
  THorseHealthCheckManager = Horse.HealthCheck.Manager.THorseHealthCheckManager;
  THorseHealthCheckResult = Horse.HealthCheck.Result.THorseHealthCheckResult;
  THorseHealthStatus = Horse.HealthCheck.Types.THorseHealthStatus;

procedure HorseHealthCheck(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);

implementation

uses
  System.JSON, System.SysUtils;

procedure HorseHealthCheck(AReq: THorseRequest; ARes: THorseResponse; ANext: TNextProc);
var
  LJsonObjectCheckHealth: TJsonObject;
  LStatusCode: THTTPStatus;
  LOptions: THorseHealthCheckOptions;
  LEncode: string;
begin

  LJsonObjectCheckHealth := TJsonObject.Create;
  try
    try
      THorseHealthCheckManager
        .GetOptions(LOptions)
        .CheckHealth(LStatusCode, LJsonObjectCheckHealth);
      LOptions.GetResultEncode(LEncode);
    finally
      ARes.RawWebResponse.Content := LJsonObjectCheckHealth.ToString;
      ARes.RawWebResponse.StatusCode := Integer(LStatusCode);
      ARes.RawWebResponse.ContentType := Format('application/json; charset=%s', [LEncode]);
    end;
  finally
    try
      FreeAndNil(LJsonObjectCheckHealth);
    finally
      ARes.RawWebResponse.SendResponse;
      raise EHorseCallbackInterrupted.Create;
    end;
  end;

end;

end.
