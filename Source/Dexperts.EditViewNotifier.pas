unit Dexperts.EditViewNotifier;

interface

uses
  System.Types,
  ToolsAPI,
  VCL.Graphics;

type
  TEditViewNotifier = class(TNotifierObject, INTAEditViewNotifier)
  private
  public
    procedure BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
    procedure EditorIdle(const View: IOTAEditView);
    procedure EndPaint(const View: IOTAEditView);
    procedure PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar;
      const TextWidth: Word; const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas;
      const TextRect: TRect; const LineRect: TRect; const CellSize: TSize);
  end;

implementation

uses
  System.Character,
  System.Math,
  System.StrUtils,
  Winapi.Windows,
  Dexperts.Dictionary,
  Dexperts.Settings;

{ TEditViewNotifier }

procedure TEditViewNotifier.BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
begin

end;

procedure TEditViewNotifier.EditorIdle(const View: IOTAEditView);
begin

end;

procedure TEditViewNotifier.EndPaint(const View: IOTAEditView);
begin

end;

procedure TEditViewNotifier.PaintLine(const View: IOTAEditView; LineNumber: Integer;
  const LineText: PAnsiChar; const TextWidth: Word; const LineAttributes: TOTAAttributeArray;
  const Canvas: TCanvas; const TextRect, LineRect: TRect; const CellSize: TSize);

  procedure HighlighIfSpellingError(const Line: string; Index, Len: Integer);
  begin
    var W := Copy(Line, Index, Len);
    if TDexpertsDictionary.IsValid(W) then
      Exit;

    var X0 := LineRect.Left + (Index - 1) * CellSize.Width + TextRect.Left;
    var X1 := X0 + Len * CellSize.Width;
    var Y := LineRect.Bottom - 1;
    Canvas.Pen.Color := TSettings.Instance.SpellingErrorColor;
    Canvas.MoveTo(X0, Y);
    case TSettings.Instance.SpellingErrorStyle of
      usLine:
        begin
          Canvas.Pen.Style := psSolid;
          Canvas.LineTo(X1, Y);
        end;
      usDashes:
        begin
          Canvas.Pen.Style := psDash;
          Canvas.LineTo(X1, Y);
        end;
      usDots:
        begin
          // TODO: Does not actually produce dots
          Canvas.Pen.Style := psDot;
          Canvas.LineTo(X1, Y);
        end;
      usSin:
        begin
          var PointCount := (X1 - X0) div 2 + 1;
          var Points: TArray<TPoint>;
          SetLength(Points, PointCount);
          for var i := 0 to PointCount - 1 do
            Points[i] := Point(X0 + i * 2, Y - (i and 1) * 2);
          Canvas.Polyline(Points);
        end;
    end;
  end;

begin
  // TODO: move data processing out of rendering
  Canvas.Brush.Style := bsClear;
  var Line: string := UTF8ToString(LineText);
  var WordStart := 0;
  for var i := 1 to TextWidth + 1 do
  begin
    var Current: Char := ' ';
    if (i <= TextWidth) then
      Current := Line[i];

    if Current.IsLetter then
    begin
      if Current.ToUpper = Current then
      begin
        if (WordStart > 0) and (i > WordStart + 1) then
          HighlighIfSpellingError(Line, WordStart, i - WordStart);
        WordStart := i;
      end
      else if WordStart = 0 then
        WordStart := i;
    end
    else if WordStart > 0 then
    begin
      HighlighIfSpellingError(Line, WordStart, i - WordStart);
      WordStart := 0;
    end;
  end;
end;

end.
