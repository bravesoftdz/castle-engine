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
  TMainlineKey = class
  protected 
    FId: integer;
    FTime: single;
    FBoneRefs,
    FObjectRefs: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const ANode: TDOMNode);
  end;

  TRef = class
  protected
    FId,
    FParent,
    FTimeline,
    FKey,
    FZIndex: integer;
  public
    procedure Parse(const ANode: TDOMNode);
  end;
{$endif}

{$ifdef read_implementation}
constructor TMainlineKey.Create;
begin
  inherited;
  FBoneRefs := TObjectList.Create;
  FObjectRefs := TObjectList.Create;
end;

destructor TMainlineKey.Destroy;
begin
  FreeAndNil(FBoneRefs);
  FreeAndNil(FObjectRefs);
  inherited;
end;

procedure TMainlineKey.Parse(const ANode: TDOMNode);
var
  C: TDOMNode;
  Ref: TRef;
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FTime := ReadInteger(ANode.Attributes.GetNamedItem('time'), 0) * 0.001;
  C := ANode.FirstChild;
  while C <> nil do
  begin
    case C.NodeName of
      'bone_ref':
        begin
          Ref := TRef.Create;  
          Ref.Parse(C);
          FBoneRefs.Add(Ref);
        end;
      'object_ref':
        begin
          Ref := TRef.Create;
          Ref.Parse(C);
          FObjectRefs.Add(Ref);
        end;
    end;
    C := C.NextSibling;
  end;
end;

procedure TRef.Parse(const ANode: TDOMNode);
begin
  FId := ReadInteger(ANode.Attributes.GetNamedItem('id'));
  FParent := ReadInteger(ANode.Attributes.GetNamedItem('parent'), -1);
  FTimeline := ReadInteger(ANode.Attributes.GetNamedItem('timeline'));
  FKey := ReadInteger(ANode.Attributes.GetNamedItem('key'));
  FZIndex := ReadInteger(ANode.Attributes.GetNamedItem('z_index'));
end;
{$endif}
