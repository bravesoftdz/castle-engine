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
    function GetAmbientIntensity: Single;
    procedure SetAmbientIntensity(const Value: Single);
    function GetColor: TCastleColorRGB;
    procedure SetColor(const Value: TCastleColorRGB);
    function GetGlobal: boolean;
    procedure SetGlobal(const Value: boolean);
    function GetIntensity: Single;
    procedure SetIntensity(const Value: Single);
    function GetIsOn: boolean;
    procedure SetIsOn(const Value: boolean);
    function GetShadows: boolean;
    procedure SetShadows(const Value: boolean);
    function GetShadowVolumes: boolean;
    procedure SetShadowVolumes(const Value: boolean);
    function GetShadowVolumesMain: boolean;
    procedure SetShadowVolumesMain(const Value: boolean);
    function GetProjectionNear: Single;
    procedure SetProjectionNear(const Value: Single);
    function GetProjectionFar: Single;
    procedure SetProjectionFar(const Value: Single);
    function GetUp: TVector3Single;
    procedure SetUp(const Value: TVector3Single);
  public
    property AmbientIntensity: Single read GetAmbientIntensity write SetAmbientIntensity;
    property Color: TCastleColorRGB read GetColor write SetColor;
    property Global: boolean read GetGlobal write SetGlobal;
    property Intensity: Single read GetIntensity write SetIntensity;
    property IsOn: boolean read GetIsOn write SetIsOn;
    property Shadows: boolean read GetShadows write SetShadows;
    property ShadowVolumes: boolean read GetShadowVolumes write SetShadowVolumes;
    property ShadowVolumesMain: boolean read GetShadowVolumesMain write SetShadowVolumesMain;
    property ProjectionNear: Single read GetProjectionNear write SetProjectionNear;
    property ProjectionFar: Single read GetProjectionFar write SetProjectionFar;
    property Up: TVector3Single read GetUp write SetUp;

{$endif read_interface}

{$ifdef read_implementation}

{ TAbstractLightNode ----------------------------------------------- }

function TAbstractLightNode.GetAmbientIntensity: Single;
begin
  Result := FdAmbientIntensity.Value;
end;

procedure TAbstractLightNode.SetAmbientIntensity(const Value: Single);
begin
  FdAmbientIntensity.Send(Value);
end;

function TAbstractLightNode.GetColor: TCastleColorRGB;
begin
  Result := FdColor.Value;
end;

procedure TAbstractLightNode.SetColor(const Value: TCastleColorRGB);
begin
  FdColor.Send(Value);
end;

function TAbstractLightNode.GetGlobal: boolean;
begin
  Result := FdGlobal.Value;
end;

procedure TAbstractLightNode.SetGlobal(const Value: boolean);
begin
  FdGlobal.Send(Value);
end;

function TAbstractLightNode.GetIntensity: Single;
begin
  Result := FdIntensity.Value;
end;

procedure TAbstractLightNode.SetIntensity(const Value: Single);
begin
  FdIntensity.Send(Value);
end;

function TAbstractLightNode.GetIsOn: boolean;
begin
  Result := FdOn.Value;
end;

procedure TAbstractLightNode.SetIsOn(const Value: boolean);
begin
  FdOn.Send(Value);
end;

function TAbstractLightNode.GetShadows: boolean;
begin
  Result := FdShadows.Value;
end;

procedure TAbstractLightNode.SetShadows(const Value: boolean);
begin
  FdShadows.Send(Value);
end;

function TAbstractLightNode.GetShadowVolumes: boolean;
begin
  Result := FdShadowVolumes.Value;
end;

procedure TAbstractLightNode.SetShadowVolumes(const Value: boolean);
begin
  FdShadowVolumes.Send(Value);
end;

function TAbstractLightNode.GetShadowVolumesMain: boolean;
begin
  Result := FdShadowVolumesMain.Value;
end;

procedure TAbstractLightNode.SetShadowVolumesMain(const Value: boolean);
begin
  FdShadowVolumesMain.Send(Value);
end;

function TAbstractLightNode.GetProjectionNear: Single;
begin
  Result := FdProjectionNear.Value;
end;

procedure TAbstractLightNode.SetProjectionNear(const Value: Single);
begin
  FdProjectionNear.Send(Value);
end;

function TAbstractLightNode.GetProjectionFar: Single;
begin
  Result := FdProjectionFar.Value;
end;

procedure TAbstractLightNode.SetProjectionFar(const Value: Single);
begin
  FdProjectionFar.Send(Value);
end;

function TAbstractLightNode.GetUp: TVector3Single;
begin
  Result := FdUp.Value;
end;

procedure TAbstractLightNode.SetUp(const Value: TVector3Single);
begin
  FdUp.Send(Value);
end;

{$endif read_implementation}
