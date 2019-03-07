(********************************************************************************
* File Name         : pcsb_form.pas
* Author            : 吴创明(aleyn.wu)
* Version           : V1.0.0
* Create Date       : 2011-10-06
* Last Update       : 2013-07-11
* Description       : .
********************************************************************************)

unit pcsb_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus,
  dxSkinsCore, dxSkinLilian, dxSkinsForm, StdCtrls, cxButtons, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit, cxGroupBox,
  cxDropDownEdit, cxCalc, hmStrTools, hmIniTools, ExtCtrls, jpeg,
  dxSkinLondonLiquidSky, cxProgressBar, cxSpinEdit, cxLabel,
  dxSkinscxPCPainter, cxPC, hmLabel, hmWinPos, cxRadioGroup, ComCtrls,
  cxListView, ImgList, cxCheckBox;

const
  RowCount = 20; //MillTable 行数
  ColCount = 20; //MillTable 列数
  RowMin = 1;
  ColMin = 1;
  RowMax = RowCount + 1;
  ColMax = ColCount + 1;
  MinDist = 3;
  AxisCount = 100;
  MinFixed = -9999.99;
  MaxFixed = 9999.99;

type
  TAxis = packed record
    X: Double;
    Y: Double;
    Z: Double;
  end;
  PAxis = ^TAxis;

  TDCC = record
    Dist: Double;
    CscX: Double;
    CscY: Double;
  end;
  PDCC = ^TDCC;

  TMillItem = packed record
    Dist: Integer;
    Z: Double;
    EN: Boolean;
  end;
  PMillItem = ^TMillItem;

  TMillData = packed record
    Left: TMillItem;
    Right: TMillItem;
    Top: TMillItem;
    Bottom: TMillItem;
    Z: Double;
    EN: Boolean;
  end;
  PMillData = ^TMillData;

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
    btnClose: TcxButton;
    btnStart: TcxButton;
    OpenDialog1: TOpenDialog;
    lblStatus: TcxLabel;
    lblCount: TcxLabel;
    cxPageControl1: TcxPageControl;
    tabWorkspace: TcxTabSheet;
    tabAbout: TcxTabSheet;
    Label1: TLabel;
    edtFilename: TcxButtonEdit;
    Image2: TImage;
    lblVersion: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    lblLangPack: TLabel;
    Bevel2: TBevel;
    EMLabel1: TEMLabel;
    HMWinPos1: THMWinPos;
    cxPageControl2: TcxPageControl;
    tabFixedPoints: TcxTabSheet;
    tabAnyPoints: TcxTabSheet;
    Image1: TImage;
    Label5: TLabel;
    edtPos7: TcxCalcEdit;
    edtPos8: TcxCalcEdit;
    edtPos9: TcxCalcEdit;
    edtPos4: TcxCalcEdit;
    edtPos5: TcxCalcEdit;
    edtPos6: TcxCalcEdit;
    edtPos1: TcxCalcEdit;
    edtPos2: TcxCalcEdit;
    edtPos3: TcxCalcEdit;
    edtTstX: TcxCalcEdit;
    edtTstY: TcxCalcEdit;
    edtTest: TcxSpinEdit;
    cxGroupBox2: TcxGroupBox;
    cxLabel1: TcxLabel;
    opnFixedPoint: TcxRadioButton;
    opnAnyPoints: TcxRadioButton;
    lstAnyPoints: TcxListView;
    edtPointX: TcxCalcEdit;
    edtPointY: TcxCalcEdit;
    edtDeviation: TcxCalcEdit;
    Label4: TLabel;
    Label6: TLabel;
    btnAppend: TcxButton;
    btnUpdate: TcxButton;
    btnDelete: TcxButton;
    edtOriX: TcxCalcEdit;
    edtOriY: TcxCalcEdit;
    edtWidth: TcxCalcEdit;
    edtHeight: TcxCalcEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxImageList1: TcxImageList;
    tabOption: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    opnUnitMM: TcxRadioButton;
    opnUnitCC: TcxRadioButton;
    cxLabel2: TcxLabel;
    cxGroupBox3: TcxGroupBox;
    opnAbsolute: TcxRadioButton;
    opnRelative: TcxRadioButton;
    cxLabel5: TcxLabel;
    chkRecalculated: TcxCheckBox;
    btnClear: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtFilenamePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure opnFixedPointClick(Sender: TObject);
    procedure lstAnyPointsEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure btnAppendClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure lstAnyPointsDblClick(Sender: TObject);
    procedure chkRecalculatedPropertiesEditValueChanged(Sender: TObject);
  private
    SourCode: TStringList;
    RootPath: string;
    ConfigFile: string;
    MillTable: array[RowMin..RowMax, ColMin..ColMax] of Double;
    OriX, OriY: Double;
    LenX, LenY: Double;
    PerX, PerY: Double;
    UserXY: array[1..AxisCount] of TAxis;
    UserCount: Integer;

    MillData: PMillData;
    MillDataRowCount: Integer;
    MillDataColCount: Integer;

  protected
    function GetMillData(X, Y: Double; PosMode: Boolean): PMillData;
  public
    procedure LoadConfig;
    procedure SaveConfig;
    procedure LoadUserPoint;
    procedure SaveUserPoint;
    procedure FindBorder;
    procedure GenerateGCode;
    function DecodeGCode(Line: string; GCode: PGCodeDecode): Boolean;
    procedure InitTable;
    procedure InitTable2;
    function GetMillTable(X, Y: Double): Double;
    function NumToStr(Value: Double): string;
    function PointToStr(X, Y: Double): string;
    procedure DecodeDCC(X1, Y1, X2, Y2: Double; DCC: PDCC);
    procedure RepairFixedPoint(RepairZ: Boolean = False);
    procedure WriteDebugFile;
  end;

var
  frmPcsb: TfrmPcsb;

implementation

{$R *.dfm}

{ TfrmPcsb }

procedure TfrmPcsb.FormCreate(Sender: TObject);
begin
  cxPageControl1.ActivePageIndex := 0;
  cxPageControl2.ActivePageIndex := 0;
  cxPageControl2.HideTabs := True;
  tabOption.TabVisible := False;
  LoadConfig;
  LoadUserPoint;
  SourCode := TStringList.Create;

  MillData := nil;
  MillDataRowCount := 0;
  MillDataColCount := 0;

  {$IFDEF DEBUG}
  edtTstX.Visible := True;
  edtTstY.Visible := True;
  edtTest.Visible := True;
  {$ENDIF}
end;

procedure TfrmPcsb.FormDestroy(Sender: TObject);
begin
  if MillData <> nil then FreeMem(MillData);
  SourCode.Free;
  SaveUserPoint;
  SaveConfig;
end;

procedure TfrmPcsb.LoadConfig;
var
  Ini: THMInifile;
  Index: Integer;
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
    if Ini.ValueExists('OriX') then edtOriX.Value := Ini.FValue['OriX'];
    if Ini.ValueExists('OriY') then edtOriY.Value := Ini.FValue['OriY'];
    if Ini.ValueExists('Width') then edtWidth.Value := Ini.FValue['Width'];
    if Ini.ValueExists('Height') then edtHeight.Value := Ini.FValue['Height'];
    if Ini.ValueExists('Filename') then edtFilename.Text := Ini.SValue['Filename'];
    if Ini.ValueExists('Recalculated') then chkRecalculated.Checked := Ini.BValue['Recalculated'];
    if Ini.ValueExists('Unit') then
    begin
      if Ini.IValue['Unit'] = 1 then opnUnitMM.Checked := True;
      if Ini.IValue['Unit'] = 2 then opnUnitCC.Checked := True;
    end;
    if Ini.ValueExists('DataType') then
    begin
      if Ini.IValue['DataType'] = 1 then opnAbsolute.Checked := True;
      if Ini.IValue['DataType'] = 2 then opnRelative.Checked := True;
    end;

    Ini.CloseKey;

    Ini.RootKey := 'FixedPoints';
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

    if Ini.ValueExists('Any1') then UserXY[1].Z := Ini.FValue['Any1'];
    if Ini.ValueExists('Any2') then UserXY[2].Z := Ini.FValue['Any2'];
    if Ini.ValueExists('Any3') then UserXY[3].Z := Ini.FValue['Any3'];
    if Ini.ValueExists('Any4') then UserXY[4].Z := Ini.FValue['Any4'];
    Ini.CloseKey;

    Ini.RootKey := 'AnyPoints';
    Ini.OpenFirstKey;
    Index := 4;

    while (Ini.ItemKeyOpend) and (Index < AxisCount) do
    begin
      Index := Index + 1;

      if Ini.ValueExists('PosX') then
        UserXY[Index].X := Ini.FValue['PosX']
      else
        UserXY[Index].X := 0;

      if Ini.ValueExists('PosY') then
        UserXY[Index].Y := Ini.FValue['PosY']
      else
        UserXY[Index].Y := 0;

      if Ini.ValueExists('Devi') then
        UserXY[Index].Z := Ini.FValue['Devi']
      else
        UserXY[Index].Z := 0;

      Ini.OpenNextKey;
    end;

    UserCount := Index;
    Ini.CloseKey;

  finally
    Ini.Free;
  end;

end;

procedure TfrmPcsb.SaveConfig;
var
  Ini: THMInifile;
  I: integer;
begin

  Ini := THMIniFile.Create;
  try
    if FileExists(ConfigFile) then Ini.LoadFromFile(ConfigFile);
    Ini.EncodeSValue := True;
    Ini.RootKey := 'Option';
    Ini.OpenFirstKey;
    if not Ini.ItemKeyOpend then Ini.AppendKey;

    Ini.FValue['OriX'] := edtOriX.Value;
    Ini.FValue['OriY'] := edtOriY.Value;
    Ini.FValue['Width'] := edtWidth.Value;
    Ini.FValue['Height'] := edtHeight.Value;
    Ini.SValue['Filename'] := edtFilename.Text;
    Ini.BValue['Recalculated'] := chkRecalculated.Checked;

    if opnUnitMM.Checked then Ini.IValue['Unit'] := 1;
    if opnUnitCC.Checked then Ini.IValue['Unit'] := 2;
    if opnAbsolute.Checked then Ini.IValue['DataType'] := 1;
    if opnRelative.Checked then Ini.IValue['DataType'] := 2;

    Ini.RootKey := 'FixedPoints';
    Ini.OpenFirstKey;
    if not Ini.ItemKeyOpend then Ini.AppendKey;

    Ini.FValue['Pos1'] := edtPos1.Value;
    Ini.FValue['Pos2'] := edtPos2.Value;
    Ini.FValue['Pos3'] := edtPos3.Value;
    Ini.FValue['Pos4'] := edtPos4.Value;
    Ini.FValue['Pos5'] := edtPos5.Value;
    Ini.FValue['Pos6'] := edtPos6.Value;
    Ini.FValue['Pos7'] := edtPos7.Value;
    Ini.FValue['Pos8'] := edtPos8.Value;
    Ini.FValue['Pos9'] := edtPos9.Value;

    Ini.FValue['Any1'] := UserXY[1].Z;
    Ini.FValue['Any2'] := UserXY[2].Z;
    Ini.FValue['Any3'] := UserXY[3].Z;
    Ini.FValue['Any4'] := UserXY[4].Z;

    Ini.RootKey := 'AnyPoints';
    Ini.ClearKeys;
    if UserCount > 4 then
    begin
      if UserCount > AxisCount then UserCount := AxisCount;

      for i := 5 to UserCount do
      begin
        Ini.AppendKey;
        Ini.FValue['PosX'] := UserXY[i].X;
        Ini.FValue['PosY'] := UserXY[i].Y;
        Ini.FValue['Devi'] := UserXY[i].Z;
      end;
      Ini.CloseKey;
    end;

    Ini.SaveToFile(ConfigFile);
  finally
    Ini.Free;
  end;

end;

procedure TfrmPcsb.edtFilenamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if OpenDialog1.InitialDir = '' then
  begin
    if edtFilename.Text <> '' then
      OpenDialog1.InitialDir := ExtractFilePath(edtFilename.Text)
    else
      OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
  end;
  if OpenDialog1.Execute then edtFilename.Text := OpenDialog1.FileName;
end;

procedure TfrmPcsb.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPcsb.GenerateGCode;
var
  DestCode: TStringList;
  GCode: TGCodeDecode;
  DCC: TDCC;
  i: integer;
  CurMode: TGMode;
  CurLine: string;
  OriZ, Dist, PerDist: Double;
  CurX, CurY, CurZ: Double;
  NextX, NextY, NextZ: Double;
  LineCount: Integer;
begin
  DestCode := TStringList.Create;

  try

    CurMode := gmNotFound;
    CurX := 0;
    CurY := 0;
    CurZ := 0;
    OriZ := 0;
    PerDist := Sqrt(Sqr(PerX) + Sqr(PerY));

    LineCount := SourCode.Count;
    lblStatus.Caption := 'Step 3, Press G-Code: ';
    lblCount.Left := lblStatus.Left + lblStatus.Width + 4;

    for i := 1 to LineCount do
    begin
      CurLine := Trim(SourCode[i - 1]);

      {$IFDEF DEBUG}
      edtTest.Value := i;
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
              CurZ := OriZ + GetMillTable(CurX, CurY);
              CurLine := CurLine + ' Z' + NumToStr(CurZ);
            end
            else if (GCode.XE or GCode.YE) then
            begin
              if not GCode.XE then GCode.X := CurX;
              if not GCode.YE then GCode.Y := CurY;

              DecodeDCC(CurX, CurY, GCode.X, GCode.Y, @DCC);

              if (DCC.Dist > 100) then //Debug
              begin
                edtTstX.Value := DCC.Dist;
              end;

              if (DCC.Dist <= MinDist) then
              begin
                if GCode.XE then
                  CurLine := CurLine + ' X' + NumToStr(GCode.X);
                if GCode.Ye then
                  CurLine := CurLine + ' Y' + NumToStr(GCode.Y);

                NextZ := OriZ + GetMillTable(GCode.X, GCode.Y);

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
                    if DCC.CscX = 0 then //Debug
                    begin
                      {$IFDEF DEBUG}
                      edtTstX.Value := DCC.CscX;
                      {$ENDIF}
                    end
                    else
                      NextX := CurX + Dist / DCC.CscX;
                    CurLine := CurLine + ' X' + NumToStr(NextX);
                  end;

                  if GCode.YE then
                  begin
                    if DCC.CscY = 0 then //Debug
                    begin
                      {$IFDEF DEBUG}
                      edtTstY.Value := DCC.CscY;
                      {$ENDIF}
                    end
                    else
                      NextY := CurY + Dist / DCC.CscY;
                    CurLine := CurLine + ' Y' + NumToStr(NextY);
                  end;

                  NextZ := OriZ + GetMillTable(NextX, NextY);
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

              CurX := GCode.X;
              CurY := GCode.Y;

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
      if (CurX > 100) or (CurY > 100) then //Debug
      begin
        edtTstX.Value := CurX;
        edtTstY.Value := CurY;
      end;
      {$ENDIF}

      DestCode.Add(CurLine);
      lblCount.Caption := Format('%d / %d ...', [i, LineCount]);
      if i mod 100 = 0 then Application.ProcessMessages;
    end;
    Application.ProcessMessages;
    DestCode.SaveToFile(ChangeFileExt(edtFilename.Text, '.pcsb.nc'));
  finally
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
      if ((GPos + 2) <= Length(Line)) then
      begin
        if (Line[GPos + 2] = '0') then
          GCode.GMode := gmG0
        else if (Line[GPos + 2] = '1') then
          GCode.GMode := gmG1
        else if (Line[GPos + 2] in ['2'..'9']) then
          GCode.GMode := gmGX
        else
          GCode.GMode := gmG0;
      end
      else
        GCode.GMode := gmG0;
    end
    else if (Line[GPos + 1] = '1') then
    begin
      if ((GPos + 2) > Length(Line)) then
      begin
        if (Line[GPos + 2] in ['0'..'9']) then
          GCode.GMode := gmGX
        else
          GCode.GMode := gmG1;
      end
      else
        GCode.GMode := gmG1
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

  lblStatus.Caption := 'Step 2, Init mill table data.';
  lblCount.Left := lblStatus.Left + lblStatus.Width + 4;

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

  for i := ColMin to ColMax do
  begin
    for j := (RowMin + 1) to (RowMid - 1) do
    begin
      MillTable[j, i] := MillTable[RowMin, i] / HalfCount * (RowMid - j) + MillTable[RowMid, i] / HalfCount * (j - RowMin);
      MillTable[j, i] := Round(MillTable[j, i] * 100) / 100;
    end;

    for j := (RowMid + 1) to (RowMax - 1) do
    begin
      MillTable[j, i] := MillTable[RowMid, i] / HalfCount * (RowMax - j) + MillTable[RowMax, i] / HalfCount * (j - RowMid);
      MillTable[j, i] := Round(MillTable[j, i] * 100) / 100;
    end;

    MillTable[RowMin, i] := Round(MillTable[RowMin, i] * 100) / 100;
    MillTable[RowMid, i] := Round(MillTable[RowMid, i] * 100) / 100;
    MillTable[RowMax, i] := Round(MillTable[RowMax, i] * 100) / 100;
  end;

end;

procedure TfrmPcsb.btnStartClick(Sender: TObject);
begin
  if not FileExists(edtFilename.Text) then
  begin
    ShowMessage('File not found :' + edtFilename.Text);
    exit;
  end;
  btnStart.Enabled := False;
  SourCode.LoadFromFile(edtFilename.Text);
  lblStatus.Caption := 'Init...';
  lblStatus.Visible := True;
  lblCount.Caption := ' ';
  lblCount.Visible := True;
  SaveUserPoint;
  FindBorder;
  InitTable;
  GenerateGCode;

  //InitTable2;
  //WriteDebugFile;
  //SourCode.SaveToFile('Debug.txt');

  ShowMessage('Success');
  btnStart.Enabled := True;
  lblStatus.Visible := False;
  lblCount.Visible := False;
end;

function TfrmPcsb.GetMillTable(X, Y: Double): Double;
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

function TfrmPcsb.PointToStr(X, Y: Double): string;
begin
  Result := '(' + NumToStr(X) + ' / ' + NumToStr(Y) + ')';
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

procedure TfrmPcsb.FindBorder;
var
  GCode: TGCodeDecode;
  i: integer;
  CurLine: string;
  RightX, RightY: Double;
  LineCount: Integer;
begin

  OriX := 0;
  OriY := 0;
  RightX := 0;
  RightY := 0;
  LineCount := SourCode.Count;
  lblStatus.Caption := 'Step 1, Find border: ';
  lblCount.Left := lblStatus.Left + lblStatus.Width + 4;

  if not chkRecalculated.Checked then
  begin
    OriX := edtOriX.Value;
    OriY := edtOriY.Value;
    LenX := edtWidth.Value;
    LenY := edtHeight.Value;
    exit;
  end;

  for i := 1 to LineCount do
  begin
    CurLine := Trim(SourCode[i - 1]);

    if Length(CurLine) > 0 then
    begin
      if DecodeGCode(CurLine, @GCode) then
      begin
        if GCode.XE then
        begin
          if GCode.X < OriX then OriX := GCode.X;
          if GCode.X > RightX then RightX := GCode.X;
        end;
        if GCode.YE then
        begin
          if GCode.Y < OriY then OriY := GCode.Y;
          if GCode.Y > RightY then RightY := GCode.Y;
        end;
      end;
    end;

    lblCount.Caption := Format('%d / %d ...', [i, LineCount]);
    if i mod 100 = 0 then Application.ProcessMessages;
  end;

  LenX := RightX - OriX;
  LenY := RightY - OriY;

  //{$IFDEF DEBUG}
  edtOriX.Value := OriX;
  edtOriY.Value := OriY;
  edtWidth.Value := LenX;
  edtHeight.Value := LenY;
  Application.ProcessMessages;
end;

procedure TfrmPcsb.opnFixedPointClick(Sender: TObject);
begin
  if opnFixedPoint.Checked then
    cxPageControl2.ActivePageIndex := 0
  else
    cxPageControl2.ActivePageIndex := 1
end;

procedure TfrmPcsb.lstAnyPointsEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

procedure TfrmPcsb.LoadUserPoint;

  procedure AddUserPoint(X, Y, Z: Double; Fixed: Boolean);
  begin
    with lstAnyPoints.Items.Add do
    begin
      Caption := PointToStr(X, Y);
      if Fixed then
        ImageIndex := 0
      else
        ImageIndex := 1;
      SubItems.Add(NumToStr(Z));
    end
  end;

var
  i: integer;

begin
  lstAnyPoints.Items.Clear;
  RepairFixedPoint;

  for i := 1 to UserCount do
  begin
    AddUserPoint(UserXY[i].X, UserXY[i].Y, UserXY[i].Z, i < 5);
  end;

end;

procedure TfrmPcsb.SaveUserPoint;

  procedure SaveFixPoint(Index: Integer; PointCaption: string);
  begin
    if Index <= lstAnyPoints.Items.Count then
      with lstAnyPoints.Items[Index - 1] do
      begin
        if UpperCase(Caption) = UpperCase(PointCaption) then
          UserXY[Index].Z := StrToFloat(SubItems[0])
        else
          UserXY[Index].Z := 0;
      end
    else
      UserXY[Index].Z := 0;
  end;

var
  i: integer;
  XStr, YStr, ZStr: string;
begin

  UserCount := lstAnyPoints.Items.Count;
  if (UserCount >= AxisCount) then UserCount := AxisCount;

  for i := 1 to UserCount do
  begin
    with lstAnyPoints.Items[i - 1] do
    begin
      XStr := Trim(GetArea(Caption, '(', '/'));
      YStr := Trim(GetArea(Caption, '/', ')'));
      ZStr := Trim(SubItems[0]);

      if (XStr <> '') and (YStr <> '') and (ZStr <> '') then
      begin
        UserXY[i].X := StrToFloat(XStr);
        UserXY[i].Y := StrToFloat(YStr);
        UserXY[i].Z := StrToFloat(ZStr);
      end;
    end
  end;

  RepairFixedPoint;

end;

procedure TfrmPcsb.btnAppendClick(Sender: TObject);
begin
  with lstAnyPoints.Items.Add do
  begin
    ImageIndex := 1;
    Caption := PointToStr(edtPointX.Value, edtPointY.Value);
    SubItems.Add(NumToStr(edtDeviation.Value));
  end
end;

procedure TfrmPcsb.btnUpdateClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := lstAnyPoints.Selected;
  if Item = nil then exit;

  with Item do
  begin
    //ImageIndex := 1;
    if Index > 4 then Caption := PointToStr(edtPointX.Value, edtPointY.Value);
    if SubItems.Count = 0 then
      SubItems.Add(NumToStr(edtDeviation.Value))
    else
      SubItems[0] := NumToStr(edtDeviation.Value);
  end
end;

procedure TfrmPcsb.btnDeleteClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := lstAnyPoints.Selected;
  if Item = nil then exit;

  if Item.Index < 5 then
  begin
    ShowMessage('Can not delete Fixed Points.');
    exit;
  end;

  lstAnyPoints.DeleteSelected;

end;

procedure TfrmPcsb.btnClearClick(Sender: TObject);
begin
  lstAnyPoints.Items.Clear;
  RepairFixedPoint(True);
  LoadUserPoint;
end;

procedure TfrmPcsb.lstAnyPointsDblClick(Sender: TObject);
var
  Item: TListItem;
  XStr, YStr, ZStr: string;
begin
  Item := lstAnyPoints.Selected;
  if Item = nil then exit;

  if (Item.Index <= AxisCount) then
    with Item do
    begin
      XStr := Trim(GetArea(Caption, '(', '/'));
      YStr := Trim(GetArea(Caption, '/', ')'));
      ZStr := Trim(SubItems[0]);

      if (XStr <> '') then
        edtPointX.Value := StrToFloat(XStr)
      else
        edtPointX.Value := 0;

      if (YStr <> '') then
        edtPointY.Value := StrToFloat(YStr)
      else
        edtPointY.Value := 0;

      if (ZStr <> '') then
        edtDeviation.Value := StrToFloat(ZStr)
      else
        edtDeviation.Value := 0;
    end;
end;

procedure TfrmPcsb.RepairFixedPoint(RepairZ: Boolean);
var
  i: integer;
begin
  UserXY[1].X := MinFixed;
  UserXY[1].Y := MinFixed;

  UserXY[2].X := MaxFixed;
  UserXY[2].Y := MinFixed;

  UserXY[3].X := MinFixed;
  UserXY[3].Y := MaxFixed;

  UserXY[4].X := MaxFixed;
  UserXY[4].Y := MaxFixed;

  if RepairZ then
  begin
    for i := 1 to 4 do
      UserXY[i].Z := 0;
  end;

end;

procedure TfrmPcsb.InitTable2;
var
  i, j, k: Integer;
  PrevPos, NextPos: Integer;
  PrevData, NextData: PMillData;
  Data: PMillData;
  X, Y: Double;
begin

  lblStatus.Caption := 'Step 2, Init mill table data.';
  lblCount.Left := lblStatus.Left + lblStatus.Width + 4;

  if (LenX > 10) and (LenY > 10) then
  begin
    MillDataRowCount := Round(LenY / 10);
    MillDataColCount := Round(LenX / 10);

    if (LenY / 10) - Round(LenY / 10) > 0 then MillDataRowCount := MillDataRowCount + 1;
    if (LenX / 10) - Round(LenX / 10) > 0 then MillDataColCount := MillDataColCount + 1;

  end
  else
  begin
    MillDataRowCount := 0;
    MillDataColCount := 0;
    exit;
  end;

  if MillData <> nil then
  begin
    FreeMem(MillData);
    MillData := nil;
  end;

  if (MillDataRowCount = 0) or (MillDataColCount = 0) then exit;

  j := (MillDataRowCount) * (MillDataColCount) * SizeOf(TMillData);
  GetMem(MillData, j);
  FillMemory(MillData, j, 0);

  for i := 1 to UserCount do
  begin
    Data := GetMillData(UserXY[i].X, UserXY[i].Y, False);
    Data.EN := True;
    Data.Z := UserXY[i].Z;
  end;

  for i := 1 to MillDataRowCount do
  begin
    PrevPos := 1;
    NextPos := 0;
    PrevData := GetMillData(PrevPos, i, True);

    for k := 2 to MillDataColCount do
    begin
      NextData := GetMillData(k, i, True);
      if NextData.EN then
      begin
        NextPos := k;
        break;
      end;
    end;

    if NextPos = 0 then
    begin
      NextPos := MillDataColCount;
      NextData := GetMillData(NextPos, i, True);
    end;

    for j := 1 to MillDataColCount do
    begin
      Data := GetMillData(j, i, True);

      if Data.EN then
      begin
        PrevPos := j;
        PrevData := Data;
      end
      else
      begin
        Data.Left.Dist := j - PrevPos;
        if PrevData <> nil then
        begin
          Data.Left.Z := PrevData.Z;
          Data.Left.EN := PrevData.EN;
        end;

        if NextPos < j then
        begin
          for k := NextPos to MillDataColCount do
          begin
            NextData := GetMillData(k, i, True);
            if NextData.EN then
            begin
              NextPos := k;
              break;
            end;
          end;

          if NextPos < j then
          begin
            NextPos := MillDataColCount;
            NextData := GetMillData(NextPos, i, True);
          end;
        end;

        Data.Right.Dist := NextPos - j;
        if NextData <> nil then
        begin
          Data.Right.Z := NextData.Z;
          Data.Right.EN := NextData.EN;
        end;
      end;
    end;
  end;

  for i := 1 to MillDataColCount do
  begin
    PrevPos := 1;
    NextPos := 0;
    PrevData := GetMillData(i, PrevPos, True);

    for k := 2 to MillDataRowCount do
    begin
      NextData := GetMillData(i, k, True);
      if NextData.EN then
      begin
        NextPos := k;
        break;
      end;
    end;

    if NextPos = 0 then
    begin
      NextPos := MillDataRowCount;
      NextData := GetMillData(i, NextPos, True);
    end;

    for j := 1 to MillDataRowCount do
    begin
      Data := GetMillData(i, j, True);

      if Data.EN then
      begin
        PrevPos := j;
        PrevData := Data;
      end
      else
      begin
        Data.Bottom.Dist := j - PrevPos;
        Data.Bottom.Z := PrevData.Z;
        Data.Bottom.EN := PrevData.EN;

        if NextPos < j then
        begin
          for k := NextPos to MillDataRowCount do
          begin
            NextData := GetMillData(i, k, True);
            if NextData.EN then
            begin
              NextPos := k;
              break;
            end;
          end;

          if NextPos < j then
          begin
            NextPos := MillDataRowCount;
            NextData := GetMillData(i, NextPos, True);
          end;
        end;

        Data.Top.Dist := NextPos - j;
        if NextData <> nil then
        begin
          Data.Top.Z := NextData.Z;
          Data.Top.EN := NextData.EN;
        end;
      end;
    end;
  end;

  for i := 1 to MillDataRowCount do
  begin
    for j := 1 to MillDataColCount do
    begin
      Data := GetMillData(j, i, True);
      if not Data.EN then
      begin
        X := (Data.Left.Dist * Data.Left.Z + Data.Right.Dist * Data.Right.Z) / MillDataColCount;
        Y := (Data.Bottom.Dist * Data.Bottom.Z + Data.Top.Dist * Data.Top.Z) / MillDataRowCount;
        Data.Z := (X + Y) / 2;
        Data.EN := True;
      end;
    end;
  end;

end;

function TfrmPcsb.GetMillData(X, Y: Double; PosMode: Boolean): PMillData;
var
  XPos, YPos: Integer;
begin
  if (MillData = nil) or (MillDataRowCount = 0) or (MillDataColCount = 0) then
  begin
    Result := MillData;
    exit;
  end;

  if PosMode then
  begin
    XPos := Round(X) - 1;
    YPos := Round(Y) - 1;
  end
  else
  begin
    XPos := Round((X - OriX) / 10);
    YPos := Round((Y - OriY) / 10);
  end;

  if XPos < 0 then XPos := 0;
  if YPos < 0 then YPos := 0;

  if (XPos >= MillDataColCount) then XPos := MillDataColCount - 1;
  if (YPos >= MillDataRowCount) then YPos := MillDataRowCount - 1;

  Result := PMillData(Cardinal(MillData) + (MillDataColCount * YPos + XPos) * Sizeof(TMillData));
end;

procedure TfrmPcsb.WriteDebugFile;
var
  XPos, YPos: Integer;
  Data: PMillData;
  s: string;
begin
  if (MillData = nil) or (MillDataRowCount = 0) or (MillDataColCount = 0) then
  begin
    exit;
  end;

  SourCode.Clear;

  for YPos := MillDataRowCount downto 1 do
  begin
    s := '';

    for XPos := 1 to MillDataColCount do
    begin
      Data := PMillData(Cardinal(MillData) + (MillDataColCount * (YPos - 1) + (XPos - 1)) * SizeOf(TMillData));
      if Data.EN then
        s := s + NumtoStr(Data.Z) + ','
      else
        s := s + '###,';
    end;

    SourCode.Add(s);
  end;

end;

procedure TfrmPcsb.chkRecalculatedPropertiesEditValueChanged(
  Sender: TObject);
begin
  edtOriX.Properties.ReadOnly := chkRecalculated.Checked;
  edtOriY.Properties.ReadOnly := chkRecalculated.Checked;
  edtWidth.Properties.ReadOnly := chkRecalculated.Checked;
  edtHeight.Properties.ReadOnly := chkRecalculated.Checked;

  if chkRecalculated.Checked then
  begin
    edtOriX.Style.Color := clBtnFace;
    edtOriY.Style.Color := clBtnFace;
    edtWidth.Style.Color := clBtnFace;
    edtHeight.Style.Color := clBtnFace;
  end
  else
  begin
    edtOriX.Style.Color := clWindow;
    edtOriY.Style.Color := clWindow;
    edtWidth.Style.Color := clWindow;
    edtHeight.Style.Color := clWindow;
  end;

end;

end.

