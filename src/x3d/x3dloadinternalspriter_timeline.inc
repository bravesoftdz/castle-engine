{
  Copyright 2016 Trung Le (kagamma).

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{$ifdef read_interface}
  TObjectType = (otSprite, otBone, otBox, otPoint, otSound, otEntity,
      otVariable);
  TCurveType = (ctInstant, ctLinear, ctQuadratic, ctCubic);

  TSpatialInfo = record
    X, Y, Angle, ScaleX, ScaleY, A: single;
    Spin: integer;
  end;

  TTimelineKey = class
  protected
    FId,
    FTime: integer;
    FCurveType: TCurveType;
    FC1, FC2: single;
  public
    procedure Parse(const ANode: TDOMNode); virtual;
  end;

  TSpatialTimelineKey = class(TTimelineKey)
  protected     
    FInfo: TSpatialInfo;
  public    
    procedure Parse(const ANode: TDOMNode); override;
  end;

  TBoneTimelineKey = class(TSpatialTimelineKey)
  protected
    FLength,
    FWidth: integer;
  public
    procedure Parse(const ANode: TDOMNode); override;
  end;  

  TSpriteTimelineKey = class(TSpatialTimelineKey)
  protected
    FFolder,
    FFile: integer;
    FUseDefaultPivot: boolean;
    FPivotX,
    FPivotY: single;
  public
    procedure Parse(const ANode: TDOMNode); override;
  end;

  TTimeline = class 
  protected
    FId: integer;
    FName: string;
    FObjectType: TObjectType;
    FKeys: TFPObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
procedure TTimelineKey.Parse(const ANode: TDOMNode);
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FTime := ReadInteger(ANode.Attributes.GetNamedItem('time'));
  FC1 := ReadFloat(ANode.Attributes.GetNamedItem('c1'));
  FC2 := ReadFloat(ANode.Attributes.GetNamedItem('c2'));
  case ReadString(ANode.Attributes.GetNamedItem('curve_type'), 'linear') of
    'instant': FCurveType := ctInstant;
    'quadratic': FCurveType := ctQuadratic;
    'cubic': FCurveType := ctCubic;
    else FCurveType := ctLinear;
  end;
end;

procedure TSpatialTimelineKey.Parse(const ANode: TDOMNode);
begin
  inherited;
  FInfo.X := ReadFloat(ANode.Attributes.GetNamedItem('x'), 0);
  FInfo.Y := ReadFloat(ANode.Attributes.GetNamedItem('y'), 0);
  FInfo.Angle := ReadFloat(ANode.Attributes.GetNamedItem('angle'), 0);
  FInfo.ScaleX := ReadFloat(ANode.Attributes.GetNamedItem('scale_x'), 1);
  FInfo.ScaleY := ReadFloat(ANode.Attributes.GetNamedItem('scale_y'), 1);
  FInfo.A := ReadFloat(ANode.Attributes.GetNamedItem('a'), 1);
  FInfo.Spin := ReadInteger(ANode.Attributes.GetNamedItem('spin'), 1);
end;  

procedure TBoneTimelineKey.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
begin
  inherited;
  C := ANode.FindNode('bone');
  if C <> nil then
  begin
    FLength := ReadInteger(C.Attributes.GetNamedItem('length'));
    FWidth := ReadInteger(C.Attributes.GetNamedItem('width'));
  end;
end;

procedure TSpriteTimelineKey.Parse(const ANode: TDOMNode); 
var
  C, PivotXAttr, PivotYAttr: TDOMNode;
begin  
  inherited;     
  C := ANode.FindNode('object');
  if C <> nil then
  begin
    FFile := ReadInteger(C.Attributes.GetNamedItem('file'));
    FFolder := ReadInteger(C.Attributes.GetNamedItem('folder'));
    PivotXAttr := C.Attributes.GetNamedItem('pivot_x');              
    PivotYAttr := C.Attributes.GetNamedItem('pivot_y');
    if (PivotXAttr = nil) and (PivotYAttr = nil) then
    begin
      FPivotX := 0;
      FPivotY := 1;
      FUseDefaultPivot := true
    end
    else
    begin
      FUseDefaultPivot := false;
      FPivotX := ReadFloat(PivotXAttr, 0);
      FPivotY := ReadFloat(PivotYAttr, 1);
    end;
  end;
end;

constructor TTimeline.Create;
begin
  inherited;
  FKeys := TFPObjectList.Create;
end;

destructor TTimeline.Destroy;
begin
  FreeAndNil(FKeys);
  inherited;
end;

procedure TTimeline.Parse(const ANode: TDOMNode);
var
  TimelineKey: TTimelineKey;
  C: TDOMNode;
  i: integer;
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FName := ReadString(ANode.Attributes.GetNamedItem('name'));
  case ReadString(ANode.Attributes.GetNamedItem('type'), 'sprite') of
    'sprite':
      begin
        FObjectType := otSprite;
        C := ANode.FirstChild;
        while C <> nil do
        begin
          TimelineKey := TSpriteTimelineKey.Create;
          TimelineKey.Parse(C);
          FKeys.Add(TimelineKey);
          C := C.NextSibling;
        end;
      end;
    'bone':
      begin
        FObjectType := otBone;
        C := ANode.FirstChild;
        while C <> nil do
        begin
          TimelineKey := TBoneTimelineKey.Create;
          TimelineKey.Parse(C);
          FKeys.Add(TimelineKey);
          C := C.NextSibling;
        end;
      end;
    'box': FObjectType := otBox;               // Unsupported object type
    'point': FObjectType := otPoint;           // Unsupported object type
    'sound': FObjectType := otSound;           // Unsupported object type
    'entity': FObjectType := otEntity;         // Unsupported object type
    'variable': FObjectType := otVariable;     // Unsupported object type
  end;
end;
{$endif}
