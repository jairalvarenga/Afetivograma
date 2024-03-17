object FrmDm: TFrmDm
  OnCreate = DataModuleCreate
  Height = 343
  Width = 504
  PixelsPerInch = 120
  object FDConnAfetivograma: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      
        'Database=D:\Projetos\Delphi\Afetivograma\Win32\Debug\AfetivoBD.d' +
        'b'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    AfterConnect = FDConnAfetivogramaAfterConnect
    BeforeConnect = FDConnAfetivogramaBeforeConnect
    Left = 80
    Top = 33
  end
  object fdqHumor: TFDQuery
    Connection = FDConnAfetivograma
    SQL.Strings = (
      'Select * From Humor')
    Left = 248
    Top = 33
    object fdqHumorHumor_ID: TIntegerField
      FieldName = 'Humor_ID'
      Origin = 'Humor_ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object fdqHumorHumor_Desc: TStringField
      FieldName = 'Humor_Desc'
      Origin = 'Humor_Desc'
      Size = 200
    end
  end
  object fdqAux01: TFDQuery
    Connection = FDConnAfetivograma
    Left = 384
    Top = 33
  end
  object fdqPerfil: TFDQuery
    Connection = FDConnAfetivograma
    SQL.Strings = (
      '')
    Left = 248
    Top = 233
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 80
    Top = 128
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 80
    Top = 233
  end
  object fdqAnotacao: TFDQuery
    Connection = FDConnAfetivograma
    SQL.Strings = (
      'Select a.Anotacao_data, a.Anotacao_Periodo,'
      '      h.Humor_Desc, a.Anotacao_Obs         '
      ' From anotacao a left join                 '
      '      Humor h on h.Humor_ID = a.Humor_ID   ')
    Left = 248
    Top = 136
  end
  object fdqAddAnotacao: TFDQuery
    Connection = FDConnAfetivograma
    SQL.Strings = (
      
        'Insert into Anotacao(Anotacao_Data, Anotacao_Obs, Humord_ID, Ano' +
        'tacao_Periodo)   '#39
      
        '             Values(:Anotacao_Data, :Anotacao_Obs, :Humord_ID, :' +
        'Anotacao_Periodo)'#39)
    Left = 384
    Top = 136
  end
end
