{ -*- buffer-read-only: t -*-

  Copyright 2015-2017 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated node properties.

  Do not edit this file manually!
  To add new properties, add them to text files in nodes_specification/components/ ,
  and regenerate include files by running
  nodes_specification/generate_x3d_nodes_to_pascal.lpr .

  The documentation for properties should go to x3dnodes_documentation.txt . }

{$ifdef read_interface}

  private
    function GetEnabled: boolean;
    procedure SetEnabled(const Value: boolean);
    function GetRotation: TVector4Single;
    procedure SetRotation(const Value: TVector4Single);
    function GetTranslation: TVector3Single;
    procedure SetTranslation(const Value: TVector3Single);
    function GetBboxCenter: TVector3Single;
    procedure SetBboxCenter(const Value: TVector3Single);
    function GetBboxSize: TVector3Single;
    procedure SetBboxSize(const Value: TVector3Single);
  public
    property Enabled: boolean read GetEnabled write SetEnabled;
    property Rotation: TVector4Single read GetRotation write SetRotation;
    property Translation: TVector3Single read GetTranslation write SetTranslation;
    property BboxCenter: TVector3Single read GetBboxCenter write SetBboxCenter;
    property BboxSize: TVector3Single read GetBboxSize write SetBboxSize;

{$endif read_interface}

{$ifdef read_implementation}

{ TAbstractNBodyCollidableNode ----------------------------------------------- }

function TAbstractNBodyCollidableNode.GetEnabled: boolean;
begin
  Result := FdEnabled.Value;
end;

procedure TAbstractNBodyCollidableNode.SetEnabled(const Value: boolean);
begin
  FdEnabled.Send(Value);
end;

function TAbstractNBodyCollidableNode.GetRotation: TVector4Single;
begin
  Result := FdRotation.Value;
end;

procedure TAbstractNBodyCollidableNode.SetRotation(const Value: TVector4Single);
begin
  FdRotation.Send(Value);
end;

function TAbstractNBodyCollidableNode.GetTranslation: TVector3Single;
begin
  Result := FdTranslation.Value;
end;

procedure TAbstractNBodyCollidableNode.SetTranslation(const Value: TVector3Single);
begin
  FdTranslation.Send(Value);
end;

function TAbstractNBodyCollidableNode.GetBboxCenter: TVector3Single;
begin
  Result := FdBboxCenter.Value;
end;

procedure TAbstractNBodyCollidableNode.SetBboxCenter(const Value: TVector3Single);
begin
  FdBboxCenter.Send(Value);
end;

function TAbstractNBodyCollidableNode.GetBboxSize: TVector3Single;
begin
  Result := FdBboxSize.Value;
end;

procedure TAbstractNBodyCollidableNode.SetBboxSize(const Value: TVector3Single);
begin
  FdBboxSize.Send(Value);
end;

{$endif read_implementation}
