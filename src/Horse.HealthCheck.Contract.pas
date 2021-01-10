unit Horse.HealthCheck.Contract;

interface

uses
  Horse.HealthCheck.Result;

type

  IHorseHealthCheck = interface
    ['{A83F86C3-A1C3-4844-845E-52BA56FBBA8C}']
    function CheckHealth: THorseHealthCheckResult;
  end;

implementation

end.
