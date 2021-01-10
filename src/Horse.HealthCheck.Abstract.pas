unit Horse.HealthCheck.Abstract;

interface

uses
  Horse.HealthCheck.Contract,
  Horse.HealthCheck.Result;

type
  THorseHealthCheckAbstract = class(TInterfacedObject, IHorseHealthCheck)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function CheckHealth: THorseHealthCheckResult; virtual; abstract;
  end;

implementation

uses
  System.SysUtils;

end.
