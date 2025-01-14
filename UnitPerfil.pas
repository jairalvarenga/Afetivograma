unit UnitPerfil;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Edit;

type
  TFrmPerfil = class(TForm)
    rectMenu: TRectangle;
    Image1: TImage;
    Label4: TLabel;
    Layout1: TLayout;
    edtNome: TEdit;
    edtSenha: TEdit;
    edtemail: TEdit;
    rectSalvar: TRectangle;
    Label2: TLabel;
    edtSenhaAnterior: TEdit;
    procedure rectSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure edtSenhaAnteriorExit(Sender: TObject);
  private
    { Private declarations }
    Senha_Anterior : string;
  public
    { Public declarations }
  end;

var
  FrmPerfil: TFrmPerfil;

implementation

{$R *.fmx}

uses uFrmDM;

procedure TFrmPerfil.edtSenhaAnteriorExit(Sender: TObject);
begin
  if edtSenhaAnterior.Text <> Senha_Anterior then
  begin
    ShowMessage('Senha n�o confere');
    Close;
  end;
end;

procedure TFrmPerfil.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPerfil := nil;
end;

procedure TFrmPerfil.FormShow(Sender: TObject);
begin
  with FrmDm.fdqAux01 do
  begin
    Close;
    SQL.Clear;
    SQL.Text := ' Select perfil_senha from perfil ';
    Open;
    if RecordCount > 0 then
    begin
      edtSenhaAnterior.Visible := True;
      Senha_Anterior := Fields[0].AsString;
      edtSenhaAnterior.SetFocus;
    end
    else
      edtSenhaAnterior.Visible := False;
  end;
end;

procedure TFrmPerfil.rectSalvarClick(Sender: TObject);
begin
  Try
    FrmDm.AddUsuario(edtNome.Text, edtEmail.Text, edtSenha.Text);
    close;
  except on e:Exception do
    ShowMessage('Erro ao inclluir usu�rio: ' + e.Message);
  End;
end;

end.
