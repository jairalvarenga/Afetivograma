unit UnitAcompanhar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.TabControl,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.DateTimeCtrls, FMXTee.Engine,
  FMXTee.Series, FMXTee.Procs, FMXTee.Chart;

type
  TFrmAcompanhar = class(TForm)
    TabControl: TTabControl;
    tbMenu: TTabItem;
    tbListagem: TTabItem;
    tbGrafico: TTabItem;
    tbSomatorio: TTabItem;
    Layout1: TLayout;
    rectMenu: TRectangle;
    lblMenu: TLabel;
    imgVoltar: TImage;
    LbListagemHumor: TListBox;
    Layout2: TLayout;
    Label2: TLabel;
    dtIniLista: TDateEdit;
    Label7: TLabel;
    dtFinLista: TDateEdit;
    btnListagem: TRectangle;
    Label8: TLabel;
    Layout3: TLayout;
    Label3: TLabel;
    dtIniGrafico: TDateEdit;
    Label9: TLabel;
    dtFinGrafico: TDateEdit;
    btnGrafico: TRectangle;
    Label10: TLabel;
    Layout4: TLayout;
    Label11: TLabel;
    dtIniSoma: TDateEdit;
    Label12: TLabel;
    dtFinSoma: TDateEdit;
    btnListarSoma: TRectangle;
    Label13: TLabel;
    lbSomatorio: TListBox;
    rectListagem: TRectangle;
    Label4: TLabel;
    Rectangle1: TRectangle;
    imgListagem: TImage;
    rectSomatorio: TRectangle;
    Label1: TLabel;
    Rectangle3: TRectangle;
    Image1: TImage;
    rectGrafico: TRectangle;
    Label5: TLabel;
    Rectangle4: TRectangle;
    Image2: TImage;
    Label6: TLabel;
    lbLegendaGrafico: TListBox;
    lytGrafico: TLayout;
    Layout5: TLayout;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgVoltarClick(Sender: TObject);
    procedure rectListagemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnListagemClick(Sender: TObject);
    procedure btnGraficoClick(Sender: TObject);
    procedure btnListarSomaClick(Sender: TObject);
  private
    procedure MudarAba(Rect: TrecTangle);
    procedure AddDataHumor(DataHumor: TDateTime);
    procedure ListarHumor;
    procedure ThreadListagemTerminate(Sender: TObject);
    procedure AddHumor(Periodo, Humor_desc: string; humor_ID:integer);
    procedure AddTitSomatorio(Periodo: String);
    procedure AddSomatorio(Humor_desc: string ; humor_ID,Soma: Integer);
    procedure ListarSoma;
    procedure ThreadSomaTerminate(Sender: TObject);
    procedure AddLegendaGrafico(Humor_desc: string; humor_ID: Integer;
      Percent: Real);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAcompanhar: TFrmAcompanhar;

implementation

{$R *.fmx}

uses uFrmDM, Frame.DataHumor, uLoading, Frame.Humor, Frame.TitSomatorio,
  Frame.Somatorio, uCharts;

procedure TFrmAcompanhar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmAcompanhar := nil;
end;

procedure TFrmAcompanhar.FormShow(Sender: TObject);
begin
  TabControl.TabIndex := 0;
end;

procedure TFrmAcompanhar.imgVoltarClick(Sender: TObject);
begin
  if TabControl.TabIndex = 0 then
    Close
  else
  begin
    TabControl.GotoVisibleTab(0);
    lblMenu.Text := 'Acompanhar'
  end;
end;

procedure TFrmAcompanhar.btnGraficoClick(Sender: TObject);
Var
  Soma : Real;
  Valores, Humor : String;
begin
  Soma := 0;
  lbLegendaGrafico.Items.Clear;
  FrmDm.CarregaGrafico(dtIniGrafico.Date, dtFinGrafico.Date);

  if FrmDm.fdqAnotacao.RecordCount < 1 then
  Begin
    ShowMessage('Nenhum registro, para per�odo.');
    Exit;
  End;

  FrmDm.fdqAnotacao.First;
  // Obter o total da soma dos items

  while not FrmDm.fdqAnotacao.Eof do
  begin
    Soma := soma + FrmDm.fdqAnotacao.FieldByName('Tot').AsInteger;
    FrmDm.fdqAnotacao.Next;
  end;

  FrmDm.fdqAnotacao.First;
  // Obtem-se o percentual de cada item
  while not FrmDm.fdqAnotacao.Eof do
  begin
    Valores := Valores + FloatToStr(FrmDm.fdqAnotacao.FieldByName('Tot').AsInteger / soma * 100) + ';';
    Humor := Humor + FrmDm.fdqAnotacao.FieldByName('Humor_ID').AsString + ';';

    AddLegendaGrafico(FrmDm.fdqAnotacao.FieldByName('Humor_Desc').AsString,
                      FrmDm.fdqAnotacao.FieldByName('Humor_ID').AsInteger,
                      FrmDm.fdqAnotacao.FieldByName('Tot').AsInteger / soma * 100);

    FrmDm.fdqAnotacao.Next;
  end;

  Valores := Copy(Valores,1,length(Valores)-1);
  Humor := Copy(Humor,1,length(Humor)-1);

  lytGrafico.DesenhaGrafico(Valores, Humor);
end;

procedure TFrmAcompanhar.btnListagemClick(Sender: TObject);
begin
  ListarHumor;
end;

procedure TFrmAcompanhar.rectListagemClick(Sender: TObject);
begin
  MudarAba(TRectangle(Sender));
end;

procedure TFrmAcompanhar.MudarAba(Rect: TRectangle);
begin
  if Rect.Tag = 1 then
    lblMenu.Text := 'Listagem'
  else
  if Rect.Tag = 2 then
    lblMenu.Text := 'Gr�fico'
  else
  if Rect.Tag = 3 then
    lblMenu.Text := 'Somat�rio';

  TabControl.GotoVisibleTab(Rect.Tag);
end;

procedure TFrmAcompanhar.AddLegendaGrafico(Humor_desc: string ; humor_ID: Integer; Percent: Real);
var
  item: TListBoxItem;
  frame: TFrameSomatorio;
begin
  item := TListBoxItem.Create(lbLegendaGrafico);
  item.Selectable := False;
  item.Text := '';
  item.Height := 18;
  item.Tag := 0;

  frame := TFrameSomatorio.Create(item);
  case humor_ID of
  1 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFFD8059);
  2 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFFB716D);
  3 : frame.rectSoma.Fill.Color :=  TAlphaColor($FF59B520);
  4 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFA6C736);
  5 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFAABB57);
  end;

  frame.lblHumor.Text := Humor_desc;
  frame.lblSoma.Text := Formatfloat('00', Percent) + '%';

  item.AddObject(frame);

  lbLegendaGrafico.AddObject(item);
end;

procedure TFrmAcompanhar.btnListarSomaClick(Sender: TObject);
begin
  ListarSoma;
end;

procedure TFrmAcompanhar.AddDataHumor(DataHumor: TDateTime);
var
  item: TListBoxItem;
  frame: TFrameDataHumor;
begin
  item := TListBoxItem.Create(LbListagemHumor);
  item.Selectable := False;
  item.Text := '';
  item.Height := 32;
  item.Tag := 0;

  // Frame...
  frame := TFrameDataHumor.Create(item);
  frame.lblDataHumor.Text := FormatDateTime('dddddd', DataHumor);
  item.AddObject(frame);

  LbListagemHumor.AddObject(item);
end;

procedure TFrmAcompanhar.AddTitSomatorio(Periodo: String);
var
  item: TListBoxItem;
  frame: TFrameTitSomatorio;
begin
  item := TListBoxItem.Create(lbSomatorio);
  item.Selectable := False;
  item.Text := '';
  item.Height := 32;
  item.Tag := 0;

  // Frame...
  frame := TFrameTitSomatorio.Create(item);
  frame.lblTitSoma.Text := Periodo;
  item.AddObject(frame);

  lbSomatorio.AddObject(item);
end;

procedure TFrmAcompanhar.AddSomatorio(Humor_desc: string ; humor_ID, Soma: Integer);
var
  item: TListBoxItem;
  frame: TFrameSomatorio;
begin
  item := TListBoxItem.Create(lbSomatorio);
  item.Selectable := False;
  item.Text := '';
  item.Height := 18;
  item.Tag := 0;

  //Cores Humor
  // $FFFD8059 - 1
  // $FFFB716D - 2
  // $FF59B520 - 3
  // $FFA6C736 - 4
  // $FFAABB57 - 5

  frame := TFrameSomatorio.Create(item);
  case  humor_ID of
  1 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFFD8059);
  2 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFFB716D);
  3 : frame.rectSoma.Fill.Color :=  TAlphaColor($FF59B520);
  4 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFA6C736);
  5 : frame.rectSoma.Fill.Color :=  TAlphaColor($FFAABB57);
  end;

  frame.lblHumor.Text := Humor_desc;
  frame.lblSoma.Text := Formatfloat('00', Soma);

  item.AddObject(frame);

  lbSomatorio.AddObject(item);
end;

procedure TFrmAcompanhar.ListarSoma;
var
  t: TThread;
  periodo_anterior : string;
begin
  periodo_anterior := '';
  lbSomatorio.Items.Clear;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    FrmDm.ListaSoma(dtIniSoma.Date, dtFinSoma.Date);

    while not FrmDm.fdqAnotacao.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        if FrmDm.fdqAnotacao.FieldByName('periodo').AsString <> periodo_anterior  then
        begin
          AddTitSomatorio(FrmDm.fdqAnotacao.FieldByName('periodo').AsString);
          periodo_anterior := FrmDm.fdqAnotacao.FieldByName('periodo').AsString;
        end;

        AddSomatorio(FrmDm.fdqAnotacao.FieldByName('Humor_Desc').AsString,
                     FrmDm.fdqAnotacao.FieldByName('Humor_ID').AsInteger,
                     FrmDm.fdqAnotacao.FieldByName('TotPeriodo').AsInteger);
        FrmDm.fdqAnotacao.Next;
      end);
    end;
  end);
  t.OnTerminate := ThreadSomaTerminate;
  t.Start;
end;

procedure TFrmAcompanhar.AddHumor(Periodo, Humor_desc: string; humor_ID:integer);
var
  item: TListBoxItem;
  frame: TFrameHumor;
begin
  item := TListBoxItem.Create(LbListagemHumor);
  item.Selectable := False;
  item.Text := '';
  item.Height := 30;
  item.Tag := 0;

  //Cores Humor
  // $FFFD8059 - 1
  // $FFFB716D - 2
  // $FF59B520 - 3
  // $FFA6C736 - 4
  // $FFAABB57 - 5

  frame := TFrameHumor.Create(item);
  case humor_ID of
  1 : frame.rectHumor.Fill.Color :=  TAlphaColor($FFFD8059);
  2 : frame.rectHumor.Fill.Color :=  TAlphaColor($FFFB716D);
  3 : frame.rectHumor.Fill.Color :=  TAlphaColor($FF59B520);
  4 : frame.rectHumor.Fill.Color :=  TAlphaColor($FFA6C736);
  5 : frame.rectHumor.Fill.Color :=  TAlphaColor($FFAABB57);
  end;

  frame.lblPeriodo.Text := Periodo;
  frame.lblHumor.Text := Humor_desc;

  item.AddObject(frame);

  LbListagemHumor.AddObject(item);
end;

procedure TFrmAcompanhar.ListarHumor;
var
  t: TThread;
  Data_anterior : string;
begin
  Data_anterior := '';
  LbListagemHumor.Items.Clear;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    FrmDm.ListaHumor(dtIniLista.DateTime, dtFinLista.DateTime);

    while not FrmDm.fdqAnotacao.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        if DateToStr(FrmDm.fdqAnotacao.FieldByName('Anotacao_Data').AsDateTime) <> Data_anterior  then
        begin
          AddDataHumor(FrmDm.fdqAnotacao.FieldByName('Anotacao_Data').AsDateTime);
          Data_anterior := FrmDm.fdqAnotacao.FieldByName('Anotacao_Data').AsString;
        end;

        AddHumor(FrmDm.fdqAnotacao.FieldByName('periodo').AsString,
                 FrmDm.fdqAnotacao.FieldByName('humor_Desc').AsString,
                 FrmDm.fdqAnotacao.FieldByName('humor_ID').AsInteger);
        FrmDm.fdqAnotacao.Next;
      end);
    end;
  end);
  t.OnTerminate := ThreadListagemTerminate;
  t.Start;
end;

procedure TFrmAcompanhar.ThreadListagemTerminate(Sender: TObject);
begin
  if Sender is TThread then
  begin
    if Assigned(TThread(Sender).FatalException) then
    begin
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
      Exit;
    end;
  end;
  if FrmDm.fdqAnotacao.RecordCount < 1 then
    ShowMessage('Nenhum registro, para o per�odo');
end;

procedure TFrmAcompanhar.ThreadSomaTerminate(Sender: TObject);
begin
  if Sender is TThread then
  begin
    if Assigned(TThread(Sender).FatalException) then
    begin
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
      Exit;
    end;
  end;
  if FrmDm.fdqAnotacao.RecordCount < 1 then
    ShowMessage('Nenhum registro, para o per�odo');
end;

end.
