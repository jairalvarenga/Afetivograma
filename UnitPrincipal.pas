unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFrmPrincipal = class(TForm)
    rectMenu: TRectangle;
    Layout1: TLayout;
    Image1: TImage;
    Label4: TLabel;
    Image2: TImage;
    rectAnotar: TRectangle;
    Label2: TLabel;
    Rectangle1: TRectangle;
    Image4: TImage;
    Rectangle2: TRectangle;
    Label1: TLabel;
    Rectangle3: TRectangle;
    Image3: TImage;
    Rectangle4: TRectangle;
    Label3: TLabel;
    Rectangle5: TRectangle;
    Image5: TImage;
    procedure rectAnotarClick(Sender: TObject);
    procedure rectAcompanharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image2Click(Sender: TObject);
    procedure rectConfigClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses UnitAnotar, UnitAcompanhar, UnitCreditos, UnitPerfil;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPrincipal := nil;
end;

procedure TFrmPrincipal.Image2Click(Sender: TObject);
begin
  if not Assigned(FrmCreditos) then
    Application.CreateForm(TFrmCreditos,FrmCreditos);
  FrmCreditos.Show;
end;

procedure TFrmPrincipal.rectAcompanharClick(Sender: TObject);
begin
  if not Assigned(FrmAcompanhar) then
    Application.CreateForm(TFrmAcompanhar,FrmAcompanhar);
  FrmAcompanhar.Show;
end;

procedure TFrmPrincipal.rectAnotarClick(Sender: TObject);
begin
  if not Assigned(FrmAnotar) then
    Application.CreateForm(TFrmAnotar,FrmAnotar);
  FrmAnotar.Show;
end;

procedure TFrmPrincipal.rectConfigClick(Sender: TObject);
begin
  if not Assigned(FrmPerfil) then
    Application.CreateForm(TFrmPerfil, FrmPerfil);
  FrmPerfil.Show;
end;

end.
