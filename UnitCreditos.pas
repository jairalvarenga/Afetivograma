unit UnitCreditos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TFrmCreditos = class(TForm)
    rectMenu: TRectangle;
    Image1: TImage;
    Label4: TLabel;
    Image2: TImage;
    Label1: TLabel;
    Rectangle3: TRectangle;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Rectangle1: TRectangle;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Memo1: TMemo;
    procedure Image2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCreditos: TFrmCreditos;

implementation

{$R *.fmx}

procedure TFrmCreditos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmCreditos := nil;
end;

procedure TFrmCreditos.Image2Click(Sender: TObject);
begin
  Close;
end;

end.
