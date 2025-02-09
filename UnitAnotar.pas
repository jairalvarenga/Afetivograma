unit UnitAnotar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  FMX.Calendar, FMX.TabControl,FMX.Ani, DateUtils,

  uCustomCalendar, FMX.ListBox, FMX.DateTimeCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, Datasnap.DBClient;


type
  TFrmAnotar = class(TForm)
    rectMenu: TRectangle;
    Label4: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Label1: TLabel;
    Circle1: TCircle;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    rectCalendario: TRectangle;
    Layout3: TLayout;
    imgVoltar: TImage;
    TabControl: TTabControl;
    tbCalendario: TTabItem;
    tbPeriodo: TTabItem;
    tbHumor: TTabItem;
    rectFinalizar: TRectangle;
    Label6: TLabel;
    lytRectCalendario: TLayout;
    lytMes: TLayout;
    imgVoltarMes: TImage;
    imgProxMes: TImage;
    lblMes: TLabel;
    lytCalendario: TLayout;
    Rectangle1: TRectangle;
    Label7: TLabel;
    Layout4: TLayout;
    Label8: TLabel;
    Circle2: TCircle;
    Label9: TLabel;
    Layout5: TLayout;
    Label10: TLabel;
    Label11: TLabel;
    rectMenuHumor: TRectangle;
    Label12: TLabel;
    Layout6: TLayout;
    Label13: TLabel;
    Circle3: TCircle;
    Label14: TLabel;
    Layout7: TLayout;
    Label15: TLabel;
    Label16: TLabel;
    Layout8: TLayout;
    lytHumor: TLayout;
    rect1: TRectangle;
    rect5: TRectangle;
    rect4: TRectangle;
    rect3: TRectangle;
    rect2: TRectangle;
    Circle4: TCircle;
    Label20: TLabel;
    Circle5: TCircle;
    Circle6: TCircle;
    Circle7: TCircle;
    Circle8: TCircle;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    memObs: TMemo;
    rectMemObs: TRectangle;
    lblmemObs: TLabel;
    lytMemObs: TLayout;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    rb4: TRadioButton;
    rb5: TRadioButton;
    lblData: TLabel;
    imgCancelar: TImage;
    memData: TClientDataSet;
    memDataAnotacao_Data: TDateField;
    memDataHumor_ID: TIntegerField;
    memDataAnotacao_Obs: TStringField;
    memDataAnotacao_Periodo: TStringField;
    rectNoite: TRectangle;
    Label17: TLabel;
    Rectangle2: TRectangle;
    Image4: TImage;
    rectTarde: TRectangle;
    Label18: TLabel;
    Rectangle4: TRectangle;
    Image1: TImage;
    rectManha: TRectangle;
    Label19: TLabel;
    Rectangle6: TRectangle;
    Image2: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgVoltarMesClick(Sender: TObject);
    procedure imgProxMesClick(Sender: TObject);
    procedure rectManhaClick(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure rect1Click(Sender: TObject);
    procedure rectFinalizarClick(Sender: TObject);
    procedure imgCancelarClick(Sender: TObject);
  private
    Calendario : TCustomCalendar;
    procedure MudarAba;
    procedure DayClick(Sender: TObject);
    procedure CarregarMes;
    procedure ChecarRB(Rect:TRectangle);
    procedure AnimaMemObs;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAnotar: TFrmAnotar;

Const
  AZUL = $FF49AACF;
  AMARELO = $FFF7FF44;//$FFF3B835;
  BRANCO = $FFFFFFFF;

implementation

{$R *.fmx}

uses uFrmDM;

procedure TFrmAnotar.DayClick(Sender: TObject);
var
  DataAnotacao : string;
  fdqAux01 : TFDQuery;
begin
  if Calendario.SelectedDate > Now then
  begin
    ShowMessage('Data superior � atual.');
    Exit;
  end;
  //===================================================================
  //  Verifica se data j� est� preenchida
  //==================================================================
  fdqAux01 := TFDQuery.Create(Self);
  fdqAux01.Connection := FrmDm.FDConnAfetivograma;
  DataAnotacao := Copy(DateToStr(Calendario.SelectedDate),7,4)+'-'+
                  Copy(DateToStr(Calendario.SelectedDate),4,2)+'-'+
                  Copy(DateToStr(Calendario.SelectedDate),1,2);
  with FrmDm.fdqAux01 do
  begin
    Close;
    SQL.Clear;
    SQL.Text := ' Select *               '+
                '   From Anotacao        '+
                '  Where Anotacao_data = '+
                QuotedStr(DataAnotacao);
    Open;
    if (RecordCount > 0) and (RecordCount < 3) then
    begin
      First;
      while not eof do
      begin
        if FieldByName('Anotacao_Periodo').AsString = 'M' then
          rectManha.Visible := False;
        if FieldByName('Anotacao_Periodo').AsString = 'T' then
          rectTarde.Visible := False;
        if FieldByName('Anotacao_Periodo').AsString = 'N' then
          rectNoite.Visible := False;
        Next;
      end;
    end
    else
    if (RecordCount > 2) then
    begin
      ShowMessage('Todos os per�odos desta data, j� lan�ados');
      Exit;
    end
    //==================================================================
    else
      memDataAnotacao_Data.Value := Calendario.SelectedDate;
  end;
  MudarAba;
  lblData.Text := 'Data: ' + FormatDateTime('dd/mm/yyyy', Calendario.SelectedDate) ;
end;

procedure TFrmAnotar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  memData.Close;
  Action := TCloseAction.caFree;
  FrmAnotar := nil;
  Calendario.DisposeOf;
end;

procedure TFrmAnotar.FormShow(Sender: TObject);
begin
//  memData.Active := True;
  memData.Append;
  TabControl.TabIndex := 0;
  imgCancelar.Visible := False;
  rectFinalizar.Visible := False;
  Calendario := TCustomCalendar.Create(lytCalendario);
  Calendario.OnClick := DayClick;

  //Personalizando
  Calendario.DayFontSize      := 18;
  Calendario.DayFontColor     := BRANCO;
  Calendario.SelectedDayColor := AMARELO;
  Calendario.BackgroundColor  := AZUL;

  Calendario.ShowCalendar;

  CarregarMes;
end;

procedure TFrmAnotar.AnimaMemObs;
begin
  if lytMemObs.Margins.Bottom <> 300 then
    lytMemObs.AnimateFloat('Margins.Bottom',
                            300,
                            0.2,
                            TAnimationType.InOut,
                            TInterpolationType.Linear)
  else
    lytMemObs.AnimateFloat('Margins.Bottom',
                            0,
                            0.2,
                            TAnimationType.InOut,
                            TInterpolationType.Linear);
end;

procedure TFrmAnotar.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  lytHumor.Opacity := 1;
  AnimaMemObs;
end;

procedure TFrmAnotar.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  lytHumor.Opacity := 0.3;
  AnimaMemObs;
end;

procedure TFrmAnotar.imgCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAnotar.CarregarMes;
begin
  lblMes.Text := Calendario.MonthName;
end;

procedure TFrmAnotar.MudarAba;
begin
  TabControl.GotoVisibleTab(TabControl.TabIndex+1);

  if (TabControl.TabIndex = 2)  then
  begin
    imgCancelar.Visible := True;
    rectFinalizar.Visible := True;
  end
  else
  begin
    imgCancelar.Visible := False;
    rectFinalizar.Visible := False;
  end;
end;

procedure TFrmAnotar.ChecarRB(rect: TRectangle);
begin
  case rect.Tag of
    1 : rb1.IsChecked := True;
    2 : rb2.IsChecked := True;
    3 : rb3.IsChecked := True;
    4 : rb4.IsChecked := True;
    5 : rb5.IsChecked := True;
  end;
end;

procedure TFrmAnotar.rect1Click(Sender: TObject);
begin
  if lytHumor.Opacity = 1 then
  begin
    memDataHumor_ID.AsInteger    := TRectangle(Sender).Tag;
    ChecarRB(TRectangle(Sender));
  end;
end;

procedure TFrmAnotar.rectFinalizarClick(Sender: TObject);
begin
  if (not rb1.IsChecked) and (not rb2.IsChecked) and (not rb3.IsChecked) and
     (not rb4.IsChecked) and (not rb5.IsChecked) then
  begin
    ShowMessage('Selecione estado de Humor');
    Exit;
  end;

  memDataAnotacao_Obs.AsString := memObs.Lines.Text;

  Try
    FrmDm.AddAnotacao(memDataHumor_ID.AsInteger, Calendario.SelectedDate,
                      memObs.Lines.Text, memDataAnotacao_Periodo.AsString);
  except on e:Exception do
    showmessage('Erro na inclus�o: ' + e.Message);
  End;
//  ShowMessage('Inclus�o ok');
  close;
end;

procedure TFrmAnotar.rectManhaClick(Sender: TObject);
begin
  memDataAnotacao_Periodo.AsString := Copy(TRectangle(Sender).Name,5,1);
  MudarAba;
end;

procedure TFrmAnotar.imgProxMesClick(Sender: TObject);
begin
  Calendario.NextMonth;
  CarregarMes;
end;

procedure TFrmAnotar.imgVoltarClick(Sender: TObject);
begin
  if TabControl.TabIndex = 0 then
  begin
    Close;
  end
  else
  begin
    TabControl.GotoVisibleTab(TabControl.TabIndex - 1);
  end;
end;

procedure TFrmAnotar.imgVoltarMesClick(Sender: TObject);
begin
  Calendario.PriorMonth;
  CarregarMes;
end;

end.
