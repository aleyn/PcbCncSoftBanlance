unit pcsb_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus,
  dxSkinsCore, dxSkinLilian, dxSkinsForm, StdCtrls, cxButtons, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxGroupBox,
  cxDropDownEdit, cxCalc, hmStrTools, hmIniTools, ExtCtrls, jpeg,
  dxSkinLondonLiquidSky, cxProgressBar, cxSpinEdit;

const
  RowCount = 20; //MillTable 行数
  ColCount = 20; //MillTable 列数
  RowMin = 1;
  ColMin = 1;
  RowMax = RowCount + 1;
  ColMax = ColCount + 1;
  MinDist = 3;


type
  TAxis = record
    X: Double;
    Y: Double;
    Z: Double;
  end;

  TDCC = record
    Dist: Double;
    CscX: Double;
    CscY: Double;
  end;
  PDCC = ^TDCC;

  TAreaRect = record
    LeftTop: TAxis;
    LeftBottom: TAxis;
    RightTop: TAxis;
    RightBottom: TAxis;
  end;

  TGMode = (gmNotFound, gmG0, gmG1, gmGX);

  TGCodeDecode = record
    GMode: TGMode;
    F: Double;
    FE: Boolean;
    X: Double;
    XE: Boolean;
    Y: Double;
    YE: Boolean;
    Z: Double;
    ZE: Boolean;
  end;
  PGCodeDecode = ^TGCodeDecode;

type
  TfrmPcsb = class(TForm)
    dxSkinController1: TdxSkinController;
    cxGroupBox1: TcxGroupBox;
    edtFilename: TcxButtonEdit;
    Label1: TLabel;
    cxGroupBox2: TcxGroupBox;
    edtPos7: TcxCalcEdit;
    edtPos8: TcxCalcEdit;
    edtPos9: TcxCalcEdit;
    edtPos4: TcxCalcEdit;
    edtPos5: TcxCalcEdit;
    edtPos6: TcxCalcEdit;
    edtPos1: TcxCalcEdit;
    edtPos2: TcxCalcEdit;
    edtPos3: TcxCalcEdit;
    btnClose: TcxButton;
    btnSave: TcxButton;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    cxProgressBar1: TcxProgressBar;
    edtOriX: TcxCalcEdit;
    Label2: TLabel;
    edtOriY: TcxCalcEdit;
    Label3: TLabel;
    edtWidth: TcxCalcEdit;
    Label4: TLabel;
    edtHeight: TcxCalcEdit;
    edtTstX: TcxCalcEdit;
    edtTstY: TcxCalcEdit;
    edtTest: TcxSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtFilenamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    RootPath: string;
    ConfigFile: string;
    MillTable: array[RowMin..RowMax, ColMin..ColMax] of Double;
    OriX, OriY: Double;
    LenX, LenY: Double;
    PerX, PerY: Double;
  public
    procedure LoadConfig;
    procedure SaveConfig;
    procedure GenerateGCode;
    function DecodeGCode(Line: string; GCode: PGCodeDecode): Boolean;
    procedure InitTable;
    function GetMillData(X, Y: Double): Double;
    function NumToStr(Value: Double): string;
    procedure DecodeDCC(X1, Y1, X2, Y2: Double; DCC: PDCC);
  end;

var
  frmPcsb: TfrmPcsb;

implementation

{$R *.dfm}

{ TfrmPcsb }

procedure TfrmPcsb.FormCreate(Sender: TObject);
begin
  LoadConfig;
  {$IFDEF DEBUG}
  edtTstX.Visible:=True;
  edtTstY.Visible:=True;
  edtTest.Visible:=True;
  {$ENDIF}
end;

procedure TfrmPcsb.FormDestroy(Sender: TObject);
begin
  SaveConfig;
end;

procedure TfrmPcsb.LoadConfig;
var
  Ini: THMInifile;
begin
  //Caption := AppName + ' ' + Version + ' ' + Spec;
  RootPath := ExtractFilePath(ParamStr(0));
  ConfigFile := RootPath + 'pcsb.ini';

  //EMLabel1.Color := TdxLondonLiquidSkyPainter.DefaultContentColor;

  if not FileExists(ConfigFile) then exit;

  Ini := THMIniFile.Create;
  try
    Ini.LoadFromFile(ConfigFile);
    Ini.EncodeSValue := True;
    Ini.RootKey := 'Option';
    Ini.OpenFirstKey;

    if Ini.ValueExists('Pos1') then edtPos1.Value := Ini.FValue['Pos1'];
    if Ini.ValueExists('Pos2') then edtPos2.Value := Ini.FValue['Pos2'];
    if Ini.ValueExists('Pos3') then edtPos3.Value := Ini.FValue['Pos3'];
    if Ini.ValueExists('Pos4') then edtPos4.Value := Ini.FValue['Pos4'];
    if Ini.ValueExists('Pos5') then edtPos5.Value := Ini.FValue['Pos5'];
    if Ini.ValueExists('Pos6') then edtPos6.Value := Ini.FValue['Pos6'];
    if Ini.ValueExists('Pos7') then edtPos7.Value := Ini.FValue['Pos7'];
    if Ini.ValueExists('Pos8') then edtPos8.Value := Ini.FValue['Pos8'];
    if Ini.ValueExists('Pos9') then edtPos9.Value := Ini.FValue['Pos9'];

    if Ini.ValueExists('OriX') then edtOriX.Value := Ini.FValue['OriX'];
    if Ini.ValueExists('OriY') then edtOriY.Value := Ini.FValue['OriY'];
    if Ini.ValueExists('Width') then edtWidth.Value := Ini.FValue['Width'];
    if Ini.ValueExists('Height') then edtHeight.Value := Ini.FValue['Height'];

    if Ini.ValueExists('Filename') then edtFilename.Text := Ini.SValue['Filename'];

  finally
    Ini.Free;
  end;

end;

procedure TfrmPcsb.SaveConfig;
var
  Ini: THMInifile;
begin

  Ini := THMIniFile.Create;
  try
    if FileExists(ConfigFile) then
    begin
      Ini.LoadFromFile(ConfigFile);
      Ini.EncodeSValue := True;
      Ini.RootKey := 'Option';
      Ini.OpenFirstKey;
    end
    else
    begin
      Ini.EncodeSValue := True;
      Ini.RootKey := 'Option';
      Ini.AppendKey;
    end;

    Ini.FValue['Pos1'] := edtPos1.Value;
    Ini.FValue['Pos2'] := edtPos2.Value;
    Ini.FValue['Pos3'] := edtPos3.Value;
    Ini.FValue['Pos4'] := edtPos4.Value;
    Ini.FValue['Pos5'] := edtPos5.Value;
    Ini.FValue['Pos6'] := edtPos6.Value;
    Ini.FValue['Pos7'] := edtPos7.Value;
    Ini.FValue['Pos8'] := edtPos8.Value;
    Ini.FValue['Pos9'] := edtPos9.Value;

    Ini.FValue['OriX'] := edtOriX.Value;
    Ini.FValue['OriY'] := edtOriY.Value;
    Ini.FValue['Width'] := edtWidth.Value;
    Ini.FValue['Height'] := edtHeight.Value;

    Ini.SValue['Filename'] := edtFilename.Text;

    Ini.SaveToFile(ConfigFile);
  finally
    Ini.Free;
  end;

end;

procedure TfrmPcsb.edtFilenamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if OpenDialog1.Execute then edtFilename.Text := OpenDialog1.FileName;
end;

procedure TfrmPcsb.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPcsb.GenerateGCode;
var
  SourCode: TStringList;
  DestCode: TStringList;
  GCode: TGCodeDecode;
  DCC: TDCC;
  i: integer;
  CurMode: TGMode;
  CurLine: string;
  OriZ, Dist, PerDist: Double;
  CurX, CurY, CurZ: Double;
  NextX, NextY, NextZ:Double;
begin
  if not FileExists(edtFilename.Text) then
  begin
    ShowMessage('File not found :' + edtFilename.Text);
    exit;
  end;

  SourCode := TStringList.Create;
  DestCode := TStringList.Create;

  try
    SourCode.LoadFromFile(edtFilename.Text);
    cxProgressBar1.Properties.Max := SourCode.Count;
    cxProgressBar1.Properties.Min := 0;

    CurMode := gmNotFound;
    CurX := 0;
    CurY := 0;
    CurZ := 0;
    OriZ := 0;
    PerDist := Sqrt(Sqr(PerX) + Sqr(PerY));

    for i := 1 to SourCode.Count do
    begin
      CurLine := Trim(SourCode[i - 1]);

      {$IFDEF DEBUG}
      edtTest.Value:=i;
      if (i = 164) then //Debug
      begin
        CurLine := CurLine + ' ';
      end;
      {$ENDIF}

      if Length(CurLine) > 0 then
      begin
        if DecodeGCode(CurLine, @GCode) then
        begin
          if (GCode.GMode <> gmNotFound) then CurMode := GCode.GMode;

          if CurMode = gmG1 then
          begin
            CurLine := 'G01';
            if GCode.FE then CurLine := CurLine + Format(' F%.0f', [GCode.F]);

            if GCode.ZE and (not GCode.XE) and (not GCode.YE) then
            begin
              OriZ := GCode.Z;
              CurZ := OriZ + GetMillData(CurX, CurY);
              CurLine := CurLine + ' Z' + NumToStr(CurZ);
            end
            else if (GCode.XE or GCode.YE) then
            begin
              if not GCode.XE then GCode.X := CurX;
              if not GCode.YE then GCode.Y := CurY;

              DecodeDCC(CurX, CurY, GCode.X, GCode.Y, @DCC);

              if (DCC.Dist > 100) then //Debug
              begin
                edtTstX.Value:=DCC.Dist;
              end;

              if (DCC.Dist <= MinDist) then
              begin
                if GCode.XE then
                  CurLine := CurLine + ' X' + NumToStr(GCode.X);
                if GCode.Ye then
                  CurLine := CurLine + ' Y' + NumToStr(GCode.Y);

                NextZ := OriZ + GetMillData(GCode.X, GCode.Y);

                if NextZ <> CurZ then
                begin
                  CurZ := NextZ;
                  CurLine := CurLine + ' Z' + NumToStr(CurZ);
                end;
              end
              else
              begin
                Dist := PerDist;
                if (Dist > DCC.Dist) then Dist := DCC.Dist;

                NextX := CurX;
                NextY := CurY;

                while (Dist <= DCC.Dist) do
                begin
                  if GCode.XE then
                  begin
                    {$IFDEF DEBUG}
                    if DCC.CscX = 0 then //Debug
                    begin
                      edtTstX.Value:=DCC.CscX;
                    end;
                    {$ENDIF}
                    NextX := CurX + Dist / DCC.CscX;
                    CurLine := CurLine + ' X' + NumToStr(NextX);
                  end;

                  if GCode.YE then
                  begin
                    {$IFDEF DEBUG}
                    if DCC.CscY = 0 then //Debug
                    begin
                      edtTstY.Value:=DCC.CscY;
                    end;
                    {$ENDIF}
                    NextY := CurY + Dist / DCC.CscY;
                    CurLine := CurLine + ' Y' + NumToStr(NextY);
                  end;

                  NextZ := OriZ + GetMillData(NextX, NextY);
                  if NextZ <> CurZ then
                  begin
                    CurZ := NextZ;
                    CurLine := CurLine + ' Z' + NumToStr(CurZ);
                  end;

                  if Dist < DCC.Dist then
                  begin
                    DestCode.Add(CurLine);
                    CurLine := '   ';
                    Dist := Dist + PerDist;
                    if (Dist > DCC.Dist) then Dist := DCC.Dist;
                  end
                  else
                    break;
                end;
              end;

              CurX:=GCode.X;
              CurY:=GCode.Y;
              
            end;
          end
          else
          begin
            if GCode.XE then CurX := GCode.X;
            if GCode.YE then CurY := GCode.Y;
            if GCode.ZE then OriZ := GCode.Z;
          end;
        end;
      end;

      {$IFDEF DEBUG}
      if (CurX > 100) or (CurY >100) then  //Debug
      begin
        edtTstX.Value:=CurX;
        edtTstY.Value:=CurY;
      end;
      {$ENDIF}


      DestCode.Add(CurLine);
      cxProgressBar1.Position := i;
      Application.ProcessMessages;
    end;
    DestCode.SaveToFile(ChangeFileExt(edtFilename.Text, '.txt'));
  finally
    SourCode.Free;
    DestCode.Free;
  end;
end;

function TfrmPcsb.DecodeGCode(Line: string; GCode: PGCodeDecode): Boolean;
var
  GPos, Pos: Integer;
  s: string;
  v: Double;

  function GetValue(Flag: string): Boolean;
  var
    i: integer;
  begin

    s := '';
    Pos := At(Flag, Line);

    if (Pos > 0) then
      for i := Pos + 1 to Length(Line) do
      begin
        if Line[i] in ['-', '+', '.', '0'..'9'] then
          s := s + Line[i]
        else
          break;
      end;

    if Length(s) > 0 then
    begin
      Result := True;
      v := StrToFloat(s);
    end
    else
    begin
      Result := False;
      v := 0;
    end;
  end;
begin

  GPos := At('G', Line);

  GCode.GMode := gmNotFound;
  if (GPos > 0) then
  begin
    if (Line[GPos + 1] = '0') then
    begin
      if ((GPos + 2) <= Length(Line)) and (Line[GPos + 2] = '1') then
        GCode.GMode := gmG1
      else
        GCode.GMode := gmG0;
    end
    else if (Line[GPos + 1] = '1') then
    begin
      if ((GPos + 2) > Length(Line)) or (Line[GPos + 2] in ['0'..'9']) then
        GCode.GMode := gmG1
      else
        GCode.GMode := gmGX;
    end
    else
      GCode.GMode := gmGX;
  end;

  GCode.FE := GetValue('F');
  GCode.F := V;

  GCode.XE := GetValue('X');
  GCode.X := V;

  GCode.YE := GetValue('Y');
  GCode.Y := V;

  GCode.ZE := GetValue('Z');
  GCode.Z := V;

  Result := (GPos > 0) or GCode.FE or GCode.XE or GCode.YE or GCode.ZE;
end;

procedure TfrmPcsb.InitTable;
var
  i: Integer;
  j: Integer;
  RowMid, ColMid: Integer;
  HalfCount: Integer;
begin

  OriX := edtOriX.Value;
  OriY := edtOriY.Value;
  LenX := edtWidth.Value;
  LenY := edtHeight.Value;

  PerX := LenX / ColCount;
  PerY := LenY / RowCount;

  RowMid := (RowCount div 2) + 1;
  ColMid := (ColCount div 2) + 1;

  MillTable[RowMin, ColMin] := edtPos1.Value;
  MillTable[RowMin, ColMid] := edtPos2.Value;
  MillTable[RowMin, ColMax] := edtPos3.Value;

  MillTable[RowMid, ColMin] := edtPos4.Value;
  MillTable[RowMid, ColMid] := edtPos5.Value;
  MillTable[RowMid, ColMax] := edtPos6.Value;

  MillTable[RowMax, ColMin] := edtPos7.Value;
  MillTable[RowMax, ColMid] := edtPos8.Value;
  MillTable[RowMax, ColMax] := edtPos9.Value;

  HalfCount := ColCount div 2;

  for i := (ColMin + 1) to (ColMid - 1) do
  begin
    MillTable[RowMin, i] := MillTable[RowMin, ColMin] + (MillTable[RowMin, ColMid] - MillTable[RowMin, ColMin]) / HalfCount * (i - ColMin);
    MillTable[RowMid, i] := MillTable[RowMid, ColMin] + (MillTable[RowMid, ColMid] - MillTable[RowMid, ColMin]) / HalfCount * (i - ColMin);
    MillTable[RowMax, i] := MillTable[RowMax, ColMin] + (MillTable[RowMax, ColMid] - MillTable[RowMax, ColMin]) / HalfCount * (i - ColMin);
  end;

  for i := (ColMid + 1) to (ColMax - 1) do
  begin
    MillTable[RowMin, i] := MillTable[RowMin, ColMid] + (MillTable[RowMin, ColMax] - MillTable[RowMin, ColMid]) / HalfCount * (i - ColMid);
    MillTable[RowMid, i] := MillTable[RowMid, ColMid] + (MillTable[RowMid, ColMax] - MillTable[RowMid, ColMid]) / HalfCount * (i - ColMid);
    MillTable[RowMax, i] := MillTable[RowMax, ColMid] + (MillTable[RowMax, ColMax] - MillTable[RowMax, ColMid]) / HalfCount * (i - ColMid);
  end;

  HalfCount := RowCount div 2;

  for j := (RowMin + 1) to (RowMid - 1) do
  begin
    for i := ColMin to ColMax do
    begin
      MillTable[j, i] := MillTable[RowMin, i] / HalfCount * (RowMid - j) + MillTable[RowMid, i] / HalfCount * (j - RowMin);
      MillTable[j, i] := Round(MillTable[j, i] * 100) / 100;
    end;
  end;

  for j := (RowMid + 1) to (RowMax - 1) do
  begin
    for i := ColMin to ColMax do
    begin
      MillTable[j, i] := MillTable[RowMid, i] / HalfCount * (RowMax - j) + MillTable[RowMax, i] / HalfCount * (j - RowMid);
      MillTable[j, i] := Round(MillTable[j, i] * 100) / 100;
    end;
  end;

  for i := ColMin to ColMax do
  begin
    MillTable[RowMin, i] := Round(MillTable[RowMin, i] * 100) / 100;
    MillTable[RowMid, i] := Round(MillTable[RowMid, i] * 100) / 100;
    MillTable[RowMax, i] := Round(MillTable[RowMax, i] * 100) / 100;
  end;


end;

procedure TfrmPcsb.btnSaveClick(Sender: TObject);
begin
  cxProgressBar1.Position:=0;
  cxProgressBar1.Visible:=True;
  InitTable;
  GenerateGCode;
  ShowMessage('Success');
  cxProgressBar1.Visible:=False;
end;

function TfrmPcsb.GetMillData(X, Y: Double): Double;
var
  TabX, TabY: Integer;
begin
  if (X < OriX) then X := OriX;
  //if (X > (OriX + LenX)) then X := OriX + LenX;

  if (Y < OriY) then Y := OriY;
  //if (Y > (OriY + LenY)) then Y := OriY + LenY;

  TabX := Round((X - OriX) / PerX);
  TabY := Round((Y - OriY) / PerY);

  if TabX < ColMin then TabX := ColMin;
  if TabX > ColMax then TabX := ColMax;

  if TabY < RowMin then TabY := RowMin;
  if TabY > RowMax then TabY := RowMax;

  Result := MillTable[TabY, TabX];

end;

function TfrmPcsb.NumToStr(Value: Double): string;
begin
  Result := Format('%-4.2f', [Value]);
end;

procedure TfrmPcsb.DecodeDCC(X1, Y1, X2, Y2: Double; DCC: PDCC);
var
  W, H: Double;
begin
  W := X2 - X1;
  H := Y2 - Y1;

  if W = 0 then
  begin
    DCC.Dist := Abs(H);
    DCC.CscX := 0;
    DCC.CscY := H / Abs(H);
    exit;
  end;

  if H = 0 then
  begin
    DCC.Dist := Abs(W);
    DCC.CscX := W / Abs(W);
    DCC.CscY := 0;
    exit;
  end;

  DCC.Dist := Sqrt(Sqr(W) + Sqr(H));
  DCC.CscX := DCC.Dist / W;
  DCC.CscY := DCC.Dist / H;

end;

end.

