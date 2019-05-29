unit UnitFormProducts;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids;

type
    TFormProducts = class(TForm)
        StringGrid1: TStringGrid;
        PanelError: TPanel;
        ComboBox1: TComboBox;
        ComboBox2: TComboBox;
        procedure FormCreate(Sender: TObject);
        procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
          Rect: TRect; State: TGridDrawState);
        procedure FormResize(Sender: TObject);
        procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
          const Value: string);
        procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
          var CanSelect: Boolean);
        procedure ComboBox1CloseUp(Sender: TObject);
        procedure ComboBox2CloseUp(Sender: TObject);
        procedure ComboBox2Exit(Sender: TObject);
    private
        { Private declarations }
        FProductsID: array [0 .. 95] of longint;
        Last_Edited_Col, Last_Edited_Row: Integer;
    public
        { Public declarations }
    end;

var
    FormProducts: TFormProducts;

implementation

{$R *.dfm}

uses elcohttpclient, superobject, stringgridutils;

function formatPlace(n: Integer): string;
begin
    result := inttostr((n div 8) + 1) + '.' + inttostr((n mod 8) + 1);
end;

procedure TFormProducts.ComboBox1CloseUp(Sender: TObject);
var
    params: ISuperObject;
begin
    with ComboBox1, StringGrid1 do
    begin
        params := SO;
        params.I['Place'] := Row - 1;
        params.S['ProductTypeName'] := Items[ItemIndex];
        GetResponse('LastPartySvc.SetProductTypeAtPlace', params);
        Cells[col, Row] := Items[ItemIndex];
    end;
end;

procedure TFormProducts.ComboBox2CloseUp(Sender: TObject);
var
    params: ISuperObject;
begin
    with ComboBox2, StringGrid1 do
    begin
        params := SA([Row - 1, ItemIndex]);
        GetResponse('LastPartySvc.SetPointsMethodAtPlace', params);
        Cells[col, Row] := Items[ItemIndex];
    end;
end;

procedure TFormProducts.ComboBox2Exit(Sender: TObject);
begin
    (Sender as TWinControl).Visible := false;
end;

procedure TFormProducts.FormCreate(Sender: TObject);
var
    r, I: Integer;
    xs: TSuperArray;
    x: ISuperObject;
    function asStr(S: string): string;
    begin
        if Assigned(x.O[S]) AND x.O[S].IsType(stString) then
            exit(x.O[S].AsString)
        else
            exit('');
    end;
    function asInt(S: string): string;
    begin
        if Assigned(x.O[S]) AND x.O[S].IsType(stInt) then
            exit(inttostr(x.O[S].AsInteger))
        else
            exit('');
    end;

begin
    xs := GetResponse('LastPartySvc.Products', SO).AsArray;
    with StringGrid1 do
    begin
        ColCount := 5;
        RowCount := 96 + 1;
        FixedCols := 1;
        FixedRows := 1;
        Cells[0, 0] := '№';
        Cells[1, 0] := 'Заводской №';
        Cells[2, 0] := 'Исполнение';
        Cells[3, 0] := 'Расчёт';
        Cells[4, 0] := 'Примечание';

        for r := 1 to 96 do
        begin
            Cells[0, r] := formatPlace(r - 1);
            FProductsID[r - 1] := 0;
            x := xs.O[r - 1];
            if not x.IsType(stObject) then
                Continue;
            Cells[1, r] := asInt('serial');
            Cells[2, r] := asStr('product_type_name');
            Cells[3, r] := asInt('points_method');
            Cells[4, r] := asStr('note');

        end;
    end;

    ComboBox1.Items.Clear;
    ComboBox1.Items.Add('');

    xs := GetResponse('EccInfoSvc.ProductTypeNames', SO).AsArray;
    for I := 0 to xs.Length - 1 do
        ComboBox1.Items.Add(xs[I].AsString);

end;

procedure TFormProducts.FormResize(Sender: TObject);
begin
    with StringGrid1 do
    begin
        ColWidths[0] := 60;
        ColWidths[1] := 120;
        ColWidths[2] := 120;
        ColWidths[3] := 60;
        ColWidths[4] := self.Width - ColWidths[0] - ColWidths[1] - ColWidths[2]
          - ColWidths[3] - 50;
    end;
end;

procedure TFormProducts.StringGrid1DrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    grd: TStringGrid;
    cnv: TCanvas;
    ta: TAlignment;

begin
    grd := StringGrid1;
    cnv := grd.Canvas;
    cnv.Font.Assign(grd.Font);

    if gdFixed in State then
        grd.Canvas.Brush.Color := cl3DLight
    else if gdSelected in State then
        cnv.Brush.Color := clGradientInactiveCaption
    else
        cnv.Brush.Color := grd.Color;

    case ACol of
        1:
            ta := TAlignment.taRightJustify;
        4:
            ta := TAlignment.taLeftJustify;
    else
        ta := TAlignment.taCenter;
    end;

    if ARow = 0 then
        ta := TAlignment.taCenter;

    StringGrid_DrawCellText(grd, ACol, ARow, Rect, ta,
      StringGrid1.Cells[ACol, ARow]);
    StringGrid_DrawCellBounds(cnv, ACol, ARow, Rect);
end;

procedure TFormProducts.StringGrid1SelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
    r: TRect;
    grd: TStringGrid;

begin
    grd := Sender as TStringGrid;

    // When selecting a cell
    if grd.EditorMode then
    begin // It was a cell being edited
        grd.EditorMode := false; // Deactivate the editor
        // Do an extra check if the LastEdited_ACol and LastEdited_ARow are not -1 already.
        // This is to be able to use also the arrow-keys up and down in the Grid.
        if (Last_Edited_Col <> -1) and (Last_Edited_Row <> -1) then
            StringGrid1SetEditText(grd, Last_Edited_Col, Last_Edited_Row,
              grd.Cells[Last_Edited_Col, Last_Edited_Row]);
        // Just make the call
    end;
    // Do whatever else wanted

    if (ARow > 0) AND (ACol in [1, 4]) then
        grd.Options := grd.Options + [goEditing]
    else
        grd.Options := grd.Options - [goEditing];

    case ACol of
        3:
            begin
                r := grd.CellRect(ACol, ARow);
                r.Left := r.Left + grd.Left;
                r.Right := r.Right + grd.Left;
                r.Top := r.Top + grd.Top;
                r.Bottom := r.Bottom + grd.Top;

                with ComboBox2 do
                begin
                    ItemIndex := Items.IndexOf(grd.Cells[ACol, ARow]);
                    if (ItemIndex = -1) then
                    begin
                        Items.Add(grd.Cells[ACol, ARow]);
                        ItemIndex := Items.IndexOf(grd.Cells[ACol, ARow]);
                    end;

                    Width := r.Width;
                    Left := r.Left;
                    Top := r.Top;
                    Visible := True;
                end;
                ComboBox1.Visible := false;
            end;
        2:
            begin
                r := grd.CellRect(ACol, ARow);
                r.Left := r.Left + grd.Left;
                r.Right := r.Right + grd.Left;
                r.Top := r.Top + grd.Top;
                r.Bottom := r.Bottom + grd.Top;

                with ComboBox1 do
                begin
                    ItemIndex := Items.IndexOf(grd.Cells[ACol, ARow]);
                    if (ItemIndex = -1) then
                    begin
                        Items.Add(grd.Cells[ACol, ARow]);
                        ItemIndex := Items.IndexOf(grd.Cells[ACol, ARow]);
                    end;

                    Width := r.Width;
                    Left := r.Left;
                    Top := r.Top;
                    Visible := True;
                end;
                ComboBox2.Visible := false;
            end;
    else
        begin
            ComboBox1.Visible := false;
            ComboBox2.Visible := false;
        end;
    end;

end;

procedure TFormProducts.StringGrid1SetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
var
    params: ISuperObject;
begin
    if ARow = 0 then
        exit;
    With StringGrid1 do
        // Fired on every change
        if Not EditorMode // goEditing must be 'True' in Options
        then
        begin // Only after user ends editing the cell
            Last_Edited_Col := -1; // Indicate no cell is edited
            Last_Edited_Row := -1; // Indicate no cell is edited
            // Do whatever wanted after user has finish editing a cell

            params := SO;
            params.I['Place'] := ARow - 1;
            params.S['Serial'] := Value;
            with StringGrid1 do
            begin
                OnSetEditText := nil;
                try
                    GetResponse('LastPartySvc.SetSerialAtPlace', params);
                    PanelError.Hide;
                except
                    on E: ERemoteError do
                    begin
                        params := SA([ARow-1]);
                        Cells[ACol, ARow] := IntToStr(
                            GetResponse('LastPartySvc.GetSerialAtPlace', params).AsInteger );
                        PanelError.Caption :=
                          Format('%s: %s', [formatPlace(ARow - 1), E.Message]);
                        PanelError.Show;
                    end;

                end;
                OnSetEditText := StringGrid1SetEditText;
            end;

        end
        else
        begin // The cell is being editted
            Last_Edited_Col := ACol; // Remember column of cell being edited
            Last_Edited_Row := ARow; // Remember row of cell being edited
        end;
end;

end.
