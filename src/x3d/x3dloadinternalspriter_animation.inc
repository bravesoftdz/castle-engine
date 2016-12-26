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
  TAnimation = class
  protected
    FId: integer;
    FName: string;
    FLength: single;
    FLooping: boolean;
    FMainlineKeys,
    FTimelines: TFPObjectList;
  public     
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
constructor TAnimation.Create;
begin
  inherited;
  FMainlineKeys := TFPObjectList.Create;
  FTimelines := TFPObjectList.Create;
end;

destructor TAnimation.Destroy;
begin
  FreeAndNil(FMainlineKeys);
  FreeAndNil(FTimelines);
  inherited;
end;

procedure TAnimation.Parse(const ANode: TDOMNode);
var
  MainlineKey: TMainlineKey;
  Timeline: TTimeLine;
  C: TDOMNode;
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FName := ReadString(ANode.Attributes.GetNamedItem('name'));
  FLength := ReadFloat(ANode.Attributes.GetNamedItem('length')) * 0.001;
  FLooping := ReadBool(ANode.Attributes.GetNamedItem('looping'), true);
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  C := ANode.FindNode('mainline').FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'key':
        begin
          MainlineKey := TMainlineKey.Create;
          MainlineKey.Parse(C);
          FMainlineKeys.Add(MainlineKey);
        end;
    end;
    C := C.NextSibling;
  end;
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'timeline':
        begin
          Timeline := TTimeLine.Create;
          Timeline.Parse(C);
          FTimelines.Add(Timeline);
        end;
    end;
    C := C.NextSibling;
  end;
end;
{$endif}
