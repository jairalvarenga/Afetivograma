unit uFrmDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.UI, FMX.Objects, System.IoUtils;

type
  TFrmDm = class(TDataModule)
    FDConnAfetivograma: TFDConnection;
    fdqHumor: TFDQuery;
    fdqAux01: TFDQuery;
    fdqPerfil: TFDQuery;
    fdqHumorHumor_ID: TIntegerField;
    fdqHumorHumor_Desc: TStringField;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    fdqAnotacao: TFDQuery;
    fdqAddAnotacao: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure FDConnAfetivogramaAfterConnect(Sender: TObject);
    procedure FDConnAfetivogramaBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddUsuario(Nome, Email, Senha: string);
    function BuscarUsuario(NomeEmail, Senha: string): boolean;
    procedure AddAnotacao(Humor: integer; DataAnota:TDateTime; Obs, Periodo: string);
    procedure ListaSoma(dtinicial, dtFinal: TDateTime);
    procedure ListaHumor(dtinicial, dtFinal: TDatetime);
    procedure CarregaGrafico(dtinicial, dtFinal: TDateTime);
  end;

var
  FrmDm: TFrmDm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function TFrmDm.BuscarUsuario(NomeEmail, Senha: string): boolean;
begin
  with fdqPerfil do
  begin
    Close;
    SQL.Clear;
    SQL.Text := ' Select *                               '+
                '   from Perfil                          '+
                '  Where (Perfil_Nome  = :NomeEmail or   '+
                '         Perfil_Email = :NomeEmail) and '+
                '        (Perfil_Senha = :Senha)         ';
    ParamByName('NomeEmail').Value := NomeEmail;
    ParamByName('Senha'    ).Value := Senha;
    Open;

    if RecordCount > 0 then
      Result := True
    else
      Result := False;
  end;
end;

procedure TFrmDm.AddUsuario(Nome, Email, Senha: string);
begin
  with fdqPerfil do
  begin
    Close;
    SQL.Clear;
    SQL.Text := ' Insert into Perfil(Perfil_Nome, Perfil_Email, Perfil_Senha)   '+
                '             Values(:Perfil_Nome, :Perfil_Email, :Perfil_Senha)';
    ParamByName('Perfil_Nome').Value := Nome;
    ParamByName('Perfil_Email').Value := Email;
    ParamByName('Perfil_Senha').Value := Senha;
    ExecSQL;
  end;
end;

procedure TFrmDm.DataModuleCreate(Sender: TObject);
begin
  try
    FDConnAfetivograma.Connected := true;
  except on e:exception do
    raise Exception.Create('Erro de conex�o com o banco de dados: ' + e.Message);
  end;
end;

procedure TFrmDm.AddAnotacao(Humor: integer; DataAnota:TDateTime; Obs, Periodo: string);
begin
  with fdqAnotacao do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'Insert into Anotacao(Anotacao_Data, Anotacao_Obs, Humor_ID, Anotacao_Periodo)    '+
                '             Values(:Anotacao_Data, :Anotacao_Obs, :Humord_ID, :Anotacao_Periodo)';
    ParamByName('Anotacao_Data'   ).Value := DataAnota;
    ParamByName('Anotacao_Obs'    ).Value := Obs;
    ParamByName('Humord_ID'       ).Value := Humor;
    ParamByName('Anotacao_Periodo').Value := Periodo;
    ExecSQL;
  end;
end;

procedure TFrmDm.ListaSoma(dtinicial, dtFinal: TDateTime);
begin
  with fdqAnotacao do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'Select h.humor_Desc, a.humor_ID,                           '+
                '       case when a.anotacao_periodo = "M" then "Manh�"     '+
                '            when a.anotacao_periodo = "T" then "Tarde"     '+
                '            else "Noite"                                   '+
                '       end as periodo,                                     '+
                '       count(*) as TotPeriodo,                             '+
                '       case when a.anotacao_periodo = "M" then 1           '+
                '            when a.anotacao_periodo = "T" then 2           '+
                '            else 3                                         '+
                '            end as ordem                                   '+
                '  From anotacao a join humor h on h.humor_id = a.humor_id  '+
                ' Where anotacao_data between :dtinicial and :dtfinal       '+
                ' Group by h.humor_Desc, a.anotacao_periodo                 '+
                ' Order by ordem, totperiodo Desc                           ';
    ParamByName('dtInicial').Value := dtinicial;
    ParamByName('dtFinal'  ).Value := dtFinal;
    Open;
  end;
end;

procedure TFrmDm.ListaHumor(dtinicial, dtFinal: TDatetime);
begin
  with fdqAnotacao do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'Select a.Anotacao_Data, h.humor_Desc, a.anotacao_periodo, h.Humor_id, '+
                '       case when a.anotacao_periodo = "M" then "Manh�"                '+
                '            when a.anotacao_periodo = "T" then "Tarde"                '+
                '            else "Noite"                                              '+
                '       end as periodo,                                                '+
                '       case when a.anotacao_periodo = "M" then 1                      '+
                '            when a.anotacao_periodo = "T" then 2                      '+
                '            else 3                                                    '+
                '       end as ordem                                                   '+
                '  From anotacao a join humor h on h.humor_id = a.humor_id             '+
                ' Where anotacao_data between '+
                QuotedStr(FormatDateTime('yyyy-mm-dd', dtInicial))                      +
                ' and ' +
                QuotedStr(FormatDateTime('yyyy-mm-dd',dtFinal))                    +
                ' Order by a.Anotacao_Data, ordem, a.Anotacao_Periodo                  ';
//    ParamByName('dtInicial').Value := dtinicial;
//    ParamByName('dtFinal'  ).Value := dtFinal;
//    sql.SaveToFile('D:\Projetos\Delphi\temp\sql.sql');
    Open;
  end;
end;

procedure TFrmDm.CarregaGrafico(dtinicial, dtFinal: TDateTime);
begin
  with fdqAnotacao do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'Select count(*) as Tot, Hu.Humor_Desc,               '+
                '       Hu.Humor_ID                                   '+
                '  From Anotacao An join Humor Hu on                  '+
                '       Hu.Humor_ID = An.Humor_ID                     '+
                ' Where anotacao_data between :dtInicial and :dtFinal '+
                ' Group by Hu.Humor_Desc                              '+
                ' Order by Tot Desc                                   ';
    ParamByName('dtInicial').Value := dtinicial;
    ParamByName('dtFinal'  ).Value := dtFinal;
    Open;
  end;
end;

procedure TFrmDm.FDConnAfetivogramaAfterConnect(Sender: TObject);
begin

//  FDConnAfetivograma.ExecSQL('Drop Table Anotacao');
//  FDConnAfetivograma.ExecSQL('Drop Table Humor');
//  FDConnAfetivograma.ExecSQL('Drop Table Perfil');

  FDConnAfetivograma.ExecSQL('CREATE TABLE IF NOT EXISTS Anotacao (      '+
                             '  Anotacao_ID      INTEGER    PRIMARY KEY, '+
                             '  Anotacao_Data    DATETIME,               '+
                             '  Anotacao_Obs     TEXT (100),             '+
                             '  Humor_ID         INTEGER,                '+
                             '  Anotacao_Periodo TEXT (1))               ');

  FDConnAfetivograma.ExecSQL('CREATE TABLE IF NOT EXISTS Humor (      '+
                             '  Humor_ID   INTEGER PRIMARY KEY,       '+
                             '  Humor_Desc VARCHAR (200));            ');

  FDConnAfetivograma.ExecSQL(' CREATE TABLE IF NOT EXISTS Perfil('+
                             ' Perfil_ID INTEGER PRIMARY KEY,    '+
                             ' Perfil_Nome VARCHAR(100),         '+
                             ' Perfil_Email VARCHAR(100),        '+
                             ' Perfil_Senha VARCHAR(50))         ');

//== Preenche Tabela Humor
  fdqAux01.Close;
  fdqAux01.SQL.Clear;
  fdqAux01.SQL.Text := 'Select * from Humor';
  fdqAux01.Open;

  if fdqAux01.RecordCount = 0 then
  begin
    FDConnAfetivograma.ExecSQL('INSERT INTO HUMOR(HUMOR_ID, HUMOR_DESC) VALUES(1,"EUFORIA / AGITA��O / ACELERA��O / AGRESSIVIDADE")');
    FDConnAfetivograma.ExecSQL('INSERT INTO HUMOR(HUMOR_ID, HUMOR_DESC) VALUES(2,"IRRITBILIDADE / INQUIETA��O / IMPACI�NCIA")');
    FDConnAfetivograma.ExecSQL('INSERT INTO HUMOR(HUMOR_ID, HUMOR_DESC) VALUES(3,"BOM HUMOR / ESTABILIDADE / NORMALIDADE")');
    FDConnAfetivograma.ExecSQL('INSERT INTO HUMOR(HUMOR_ID, HUMOR_DESC) VALUES(4,"TRISTEZA / FADIGA / CANSA�O / DES�NIMO")');
    FDConnAfetivograma.ExecSQL('INSERT INTO HUMOR(HUMOR_ID, HUMOR_DESC) VALUES(5,"TRISTEZA PROFUNDA / LENTID�O / APATIA")');
  end;
//==

////== Preenche Tabela Anotacaao
//  fdqAux01.Close;
//  fdqAux01.SQL.Clear;
//  fdqAux01.SQL.Text := 'Select * from Anotacao';
//  fdqAux01.Open;
////
//  if fdqAux01.RecordCount = 0 then
//  begin
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(1,"2023-08-07","",3,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(2,"2023-08-07","",2,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(3,"2023-08-07","",4,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(4,"2023-09-01","jajajajajajajja",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(5,"2023-09-02","62b2",1,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(6,"2023-09-02","q6th268y7um4",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(7,"2023-09-02","nuu9ih6i4392",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(8,"2023-09-03","4 my8aop7y",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(9,"2023-09-03"," qxsp37ter6ot",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(10,"2023-09-03","jpo",5,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(11,"2023-09-04","nlul6 170y e",5,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(12,"2023-09-04","lhksvt1s4heiiw0jhhbd",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(13,"2023-09-04","minonuvu9z",2,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(14,"2023-09-05","ljxzwd km94j2		73yc" ,1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(15,"2023-09-05","2wasg",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(16,"2023-09-05","33dugg8y1b64i0dafi",3,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(17,"2023-09-06"," pn0yr2",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(18,"2023-09-06","tvme",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(19,"2023-09-06","hu7g3jp5bappkwoe2",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(20,"2023-09-07"," qdlq5q",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(21,"2023-09-07"," ycoqm22pmz6861a",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(22,"2023-09-07","g566ov7kpvcoh7b	9",1,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(23,"2023-09-08","z insb3",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(24,"2023-09-08","0",5,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(25,"2023-09-08","vtd5t7",3,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(26,"2023-09-09","4ii",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(27,"2023-09-09","apu8f8q8iqcgbbgkjj",3,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(28,"2023-09-09","9mmjg9vd75",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(29,"2023-09-10","rk",4,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(30,"2023-09-10","2rgdu0",3,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(31,"2023-09-10","4yt0ll18",4,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(32,"2023-09-11","2z",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(33,"2023-09-11","y0 ccwc",5,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(34,"2023-09-11","9kz6hcgh0c2k",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(35,"2023-09-12","3iexv67d2",3,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(36,"2023-09-12","upu6p5tzg3",1,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(37,"2023-09-12","qovdh5 u9ndab",5,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(38,"2023-09-13","wn0dfwnduhb 7ul8",4,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(39,"2023-09-13","hovd",5,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(40,"2023-09-13","cnjfm",4,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(41,"2023-09-14","lvxn3zphepjbfq7i",5,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(42,"2023-09-14","0vu4bl0fc12",3,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(43,"2023-09-14","rf7vn82tgxy 96",1,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(44,"2023-09-15","e7v3z9qf",3,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(45,"2023-09-15","tohi2w",4,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(46,"2023-09-15","fc92jdxmpf1e",5,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(47,"2023-09-16","7ax9xjtw",1,"M")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(48,"2023-09-16","4lm t 3md6yej",1,"T")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(49,"2023-09-16","0bdfay7z9sz",3,"N")');
//    FDConnAfetivograma.ExecSQL('INSERT INTO ANOTACAO(ANOTACAO_ID, ANOTACAO_DATA, ANOTACAO_OBS, HUMOR_ID, ANOTACAO_PERIODO) VALUES(50,"2023-09-17","oam",1,"N")');
//  end;
//==
end;

procedure TFrmDm.FDConnAfetivogramaBeforeConnect(Sender: TObject);
begin
    FDConnAfetivograma.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    FDConnAfetivograma.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\AfetivoBD.db';
    {$ELSE}
    FDConnAfetivograma.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'AfetivoBD.db');
    {$ENDIF}
end;

end.
