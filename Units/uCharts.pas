unit uCharts;

interface

Uses
  FMX.Layouts, RegularExpressions, FMX.Dialogs, FMX.Objects, System.SysUtils,
  FMX.Types, System.UITypes;

Type
  TChartHelper = class helper for TLayout

    procedure DesenhaGrafico(Valores, Humor: String);
  end;

implementation

uses
  FMX.Graphics;

{ TChartHelper }

procedure TChartHelper.DesenhaGrafico(Valores, Humor: String);
var
  ArrValores : TArray<String>;
  ArrHumor   : TArray<String>;
  i : integer;
  VlrTotal, Vlr, Rotacao, UltRotacao : Real;
  Pie : TPie;
  Circ : TCircle;
begin
  VlrTotal := 0;

  ArrValores := TRegEx.Split(Valores,';');
  ArrHumor := TRegEx.Split(Humor,';');

  for i := 0 to TRegEx.Matches(Valores,';').count do
    VlrTotal := VlrTotal + StrToFloat(ArrValores[i]);

  Rotacao := -90;
  UltRotacao := 0;

  for i := 0 to TRegEx.Matches(Valores,';').count do
  begin
    Pie := TPie.Create(self);
    Circ := TCircle.Create(Self);

    Pie.Size.Width := Self.Size.Width;
    Pie.Size.Height := Self.Size.Height;
    Pie.Align := TAlignLayout.Client;

    Circ.Size.Width := Self.Size.Width - 40;
    Circ.Size.Height := Self.Size.Height - 140;
    Circ.Align := TAlignLayout.Center;
    Circ.Stroke.Kind := TBrushKind.None;
    Circ.Fill.Color :=  TAlphaColor($FFF9F9F9);

    case ArrHumor[i].ToInteger of
      1 : Pie.Fill.Color := TAlphaColor($FFFD8059);
      2 : Pie.Fill.Color := TAlphaColor($FFFB716D);
      3 : Pie.Fill.Color := TAlphaColor($FF59B520);
      4 : Pie.Fill.Color := TAlphaColor($FFA6C736);
      5 : Pie.Fill.Color := TAlphaColor($FFAABB57);
    end;

//      Pie.Fill.Color := TAlphaColors.Cornflowerblue;

    Pie.Stroke.Color := Pie.Fill.Color;

    Vlr := (((StrToFloat(ArrValores[i]) / VlrTotal) - 1) * 100) + 100;

    Pie.EndAngle := Vlr* 3.6;
    Rotacao := Rotacao + UltRotacao;
    Pie.RotationAngle := Rotacao;
    UltRotacao := Pie.EndAngle;
    Pie.Hint := FloatToStr(Vlr);
    Pie.ShowHint:= True;

    Pie.Parent := Self;
    Circ.Parent := Self;
  end;


end;

end.
