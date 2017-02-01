{
  Copyright 2017 Trung Le (kagamma).

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ TiledMap loader. }
unit X3DLoadInternalTiled;

{$I castleconf.inc}

interface

uses X3DNodes, CastleTiledMap;

function LoadTiled(URL: string; out ALoader: TObject): TX3DRootNode;

implementation

uses SysUtils, Classes, FGL, Math,
  CastleVectors, CastleUtils, CastleLog, CastleURIUtils, CastleDownload,
  CastleStringUtils, CastleClassUtils, CastleColors,
  X3DLoadInternalUtils, X3DFields, CastleGenericLists,
  X3DLoad;

const
  VERTEX_BUFFER = 4096;
  HorizontalFlag = $80000000;
  VerticalFlag = $40000000;
  DiagonalFlag = $20000000;
  ClearFlag = $1FFFFFFF;

type
  ETiledReadError = class(Exception);
  { TInternal* ported from cge-tiledmap-scene.
    Ref: https://github.com/Kagamma/cge-tiledmap }
  PInternalTile = ^TInternalTile;
  TInternalTile = record
    GID,
    CoordIndex: cardinal;
    ShapeNode: TShapeNode;
  end;
  TInternalTiles = array of TInternalTile;
  TShapeNodes = array of TShapeNode;
  TShapeNodeMap = specialize TFPGMap<string, TShapeNode>;
  TImageTexNodeMap = specialize TFPGMap<string, TImageTextureNode>;

  { Scene contain tiled map, split into blocks for faster rendering. }
  TInternalTiledMapLoader = class
  private 
    FRoot: TX3DRootNode;
    FURL: string;
    FTiledMap: TTiledMap;
    { Size per partition, default is 128. They should be changed before calling
      LoadTMX(). }
    FTilePartWidth,
    FTilePartHeight: word;

    procedure InitNodeTree;
    { Calculate the exact texture coords of frame from a given frame. }
    procedure CalculateFrameCoords(
        const AWidth, AHeight, AFrameWidth, AFrameHeight, AFrame: cardinal;
        const AData: cardinal;
        out T1, T2, T3, T4: TVector2Single);
    { Check ShapeNodeMap to see if there's a shape for a given key yet, if not,
      create new one for it.
      The method returns shape if existed, or create a new one and then return.
      @param(AParentNode) - Parent of the new shape, in case it doesnt exist.
      @param(AShapeNodeMap) - Map contains all shapes of a layer.
      @param(AImageTexNodeMap) - Map contains image for reusing purpose.
      @param(AImageName) - Name of the image.
      @param(APartSignature) - Partition signature, in "[x-y]" format.
      @param(AGeoLayer) - }
    function CheckExistedShape(
        const AParentNode: TAbstractGroupingNode;
        const AShapeNodeMap: TShapeNodeMap;
        const AImageTexNodeMap: TImageTexNodeMap;
        const AImageName, APartSignature: string): TShapeNode;
    { Construct an orthogonal map from given tiled map. }
    procedure ConstructOrthogonalMap(const AParentNode: TAbstractGroupingNode);
    { Rebase object's Y-axis. }
    procedure RebaseYAxis(const ALayer: PLayer);                               
    { Load object contains "url" property. }
    procedure LoadObjects(const ALayer: PLayer; const AZOrder: single);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadTMX(const AURL: string);

    property TiledMap: TTiledMap read FTiledMap;
    property TilePartWidth: word read FTilePartWidth write FTilePartWidth;
    property TilePartHeight: word read FTilePartHeight write FTilePartHeight;
    property Root: TX3DRootNode read FRoot;
  end;

procedure TInternalTiledMapLoader.InitNodeTree;
var
  ColNode: TCollisionNode;
begin
  FRoot := TX3DRootNode.Create;
  { No collisions for geometry. Collision will be handled by proximy instead. }
  ColNode := TCollisionNode.Create;
  ColNode.Enabled := false;
  FRoot.FdChildren.Add(ColNode);
  { Construct tile batches from layers. }
  case FTiledMap.Orientation of
    moOrthogonal:
      ConstructOrthogonalMap(ColNode);
  end;
end;

procedure TInternalTiledMapLoader.CalculateFrameCoords(
    const AWidth, AHeight, AFrameWidth, AFrameHeight, AFrame: cardinal;
    const AData: cardinal;
    out T1, T2, T3, T4: TVector2Single);
var
  W, H,
  Columns: integer;
  FW, FH,
  FFW, FFH: single;

  procedure SwapVector(var V1, V2: TVector2Single);
  var
    V: TVector2Single;
  begin
    V := V1; V1 := V2; V2 := V;
  end;

begin
  Columns := AWidth div AFrameWidth;
  W := AFrame mod Columns * AFrameWidth;
  H := (AHeight - AFrameHeight) - AFrame div Columns * AFrameHeight;
  FW := 1 / AWidth * W;
  FH := 1 / AHeight * H;
  FFW := 1 / AWidth * AFrameWidth;
  FFH := 1 / AHeight * AFrameHeight;
  T1 := Vector2Single(FW, FH + FFH);
  T2 := Vector2Single(FW + FFW, FH + FFH);
  T3 := Vector2Single(FW + FFW, FH);
  T4 := Vector2Single(FW, FH);
  if (AData and HorizontalFlag) > 0 then
  begin
    SwapVector(T1, T2);
    SwapVector(T3, T4);
  end;
  if (AData and VerticalFlag) > 0 then
  begin
    SwapVector(T1, T4);
    SwapVector(T2, T3);
  end;
end;

function TInternalTiledMapLoader.CheckExistedShape(
    const AParentNode: TAbstractGroupingNode;
    const AShapeNodeMap: TShapeNodeMap;
    const AImageTexNodeMap: TImageTexNodeMap;
    const AImageName, APartSignature: string): TShapeNode;
var
  Key: string;
  i, j: integer;
  ShapeNode: TShapeNode;
  ImageTexNode: TImageTextureNode;
  TexAttrNode: TTexturePropertiesNode;
  TriSetNode: TTriangleSetNode;
  CoordNode: TCoordinateNode;
  TexCoordNode: TTextureCoordinateNode;
begin
  Key := AImageName + APartSignature;
  if not AShapeNodeMap.Find(Key, j) then
  begin
    ShapeNode := TShapeNode.Create(AImageName);
    AShapeNodeMap[Key] := ShapeNode;

    (AParentNode as TGroupNode).FdChildren.Add(ShapeNode);

    ShapeNode.Appearance := TAppearanceNode.Create;
    ShapeNode.Material := TMaterialNode.Create;

    ShapeNode.Material.DiffuseColor := Vector3Single(0, 0, 0);
    ShapeNode.Material.SpecularColor := Vector3Single(0, 0, 0);
    ShapeNode.Material.AmbientIntensity := 0;
    ShapeNode.Material.EmissiveColor := Vector3Single(1, 1, 1);

    if not AImageTexNodeMap.Find(AImageName, j) then
    begin
      ImageTexNode := TImageTextureNode.Create;
      ImageTexNode.RepeatS := false;
      ImageTexNode.RepeatT := false;
      ImageTexNode.FdUrl.Send(ExtractURIPath(FURL) + AImageName);
      TexAttrNode:= TTexturePropertiesNode.Create;
      TexAttrNode.FdMagnificationFilter.Send('NEAREST_PIXEL');
      TexAttrNode.FdMinificationFilter.Send('NEAREST_PIXEL');
      ImageTexNode.FdTextureProperties.Value := TexAttrNode;

      AImageTexNodeMap[AImageName] := ImageTexNode;
    end
    else
      ImageTexNode := AImageTexNodeMap.Data[j];
    ShapeNode.Texture := ImageTexNode;

    TriSetNode := TTriangleSetNode.Create;
    TriSetNode.Solid := false;
    ShapeNode.FdGeometry.Value := TriSetNode;

    CoordNode := TCoordinateNode.Create;
    TexCoordNode := TTextureCoordinateNode.Create;

    TriSetNode.FdCoord.Value := CoordNode;
    TriSetNode.FdTexCoord.Value := TexCoordNode;

    CoordNode.FdPoint.Items.Capacity := VERTEX_BUFFER;
    TexCoordNode.FdPoint.Items.Capacity := VERTEX_BUFFER;
  end
  else
    ShapeNode := AShapeNodeMap.Data[j];
  Result := ShapeNode;
end;

procedure TInternalTiledMapLoader.ConstructOrthogonalMap(const AParentNode: TAbstractGroupingNode);
var
  GID,
  Data: cardinal;
  i, j, k, c: integer;
  TileWidth,
  TileHeight,
  CurTilePartX,
  CurTilePartY: integer;

  Tileset_: PTileset;
  Layer_: PLayer;
  Tile_: PInternalTile;

  GroupNode: TGroupNode;
  ShapeNode: TShapeNode;
  TriSetNode: TTriangleSetNode;
  CoordNode: TCoordinateNode;
  TexCoordNode: TTextureCoordinateNode;
  ShapeNodeMap: TShapeNodeMap;
  ImageTexNodeMap: TImageTexNodeMap;

  V1, V2, V3, V4: TVector3Single;
  T1, T2, T3, T4: TVector2Single;

  W, H: single;
  ZDepth: single = 0;

begin
  ShapeNodeMap := TShapeNodeMap.Create;
  ShapeNodeMap.Sorted := true;
  ImageTexNodeMap := TImageTexNodeMap.Create;
  ImageTexNodeMap.Sorted := true;
  TileWidth := FTiledMap.TileWidth;
  TileHeight := FTiledMap.TileHeight;
  try
    for i := 0 to FTiledMap.Layers.Count-1 do
    begin
      Layer_ := FTiledMap.Layers.Ptr(i);
      if Layer_^.LayerType = ltObjectGroup then
      begin                                   
        RebaseYAxis(Layer_);
        LoadObjects(Layer_, ZDepth);
        ZDepth += 0.1;
        continue;
      end;
      if Layer_^.LayerType = ltImageLayer then
        continue;
      if not Layer_^.Visible then
        continue;

      ShapeNodeMap.Clear;
      GroupNode := TGroupNode.Create(Layer_^.Name);
      (AParentNode as TCollisionNode).FdChildren.Add(GroupNode);

      c := 0;
      for k := 0 to FTiledMap.Height-1 do
      begin
        CurTilePartY := k div FTilePartHeight;
        for j := 0 to FTiledMap.Width-1 do
        begin
          CurTilePartX := j div FTilePartWidth;
          Data := Layer_^.Data.Data[c];
          Inc(c);
          GID := Data and ClearFlag;
          if GID = 0 then
            continue;
          Tileset_ := FTiledMap.GIDToTileset(GID);
          ShapeNode := CheckExistedShape(
              GroupNode, ShapeNodeMap, ImageTexNodeMap,
              Tileset_^.Image.Source,
              '[' + IntToStr(CurTilePartX) + 'x' + IntToStr(CurTilePartY) + ']');

          TriSetNode := ShapeNode.FdGeometry.Value as TTriangleSetNode;
          CoordNode := TriSetNode.FdCoord.Value as TCoordinateNode;
          TexCoordNode :=TriSetNode.FdTexCoord.Value as TTextureCoordinateNode;

          W := j; H := (FTiledMap.Height-1) - k;
          V1 := Vector3Single(W * TileWidth, (H + 1) * TileHeight, ZDepth);
          V2 := Vector3Single((W + 1) * TileWidth, (H + 1) * TileHeight, ZDepth);
          V3 := Vector3Single((W + 1) * TileWidth, (H + 0) * TileHeight, ZDepth);
          V4 := Vector3Single(W * TileWidth, (H + 0) * TileHeight, ZDepth);

          CalculateFrameCoords(
              Tileset_^.Image.Width, Tileset_^.Image.Height,
              TileWidth, TileHeight,
              GID - Tileset_^.FirstGID, Data,
              T1, T2, T3, T4);

          CoordNode.FdPoint.Items.AddArray([V1, V2, V3, V1, V3, V4]);
          TexCoordNode.FdPoint.Items.AddArray([T1, T2, T3, T1, T3, T4]);
        end;
      end;
      ZDepth += 0.1;
    end;
  finally
    FreeAndNil(ShapeNodeMap);
    FreeAndNil(ImageTexNodeMap);
  end;
end;

procedure TInternalTiledMapLoader.RebaseYAxis(const ALayer: PLayer);
var
  i: integer;
  TiledObj: ^TTiledObject;
begin
  if ALayer^.LayerType = ltObjectGroup then
    for i := 0 to ALayer^.Objects.Count-1 do
    begin
      TiledObj := ALayer^.Objects.Ptr(i);
      TiledObj^.Y :=
          FTiledMap.Height * FTiledMap.TileHeight - TiledObj^.Y;
      TiledObj^.CenterY :=
          FTiledMap.Height * FTiledMap.TileHeight - TiledObj^.CenterY;
    end;
end;

procedure TInternalTiledMapLoader.LoadObjects(const ALayer: PLayer;
    const AZOrder: single);
type
  TRootNodeList = specialize TFPGMap<string, TX3DRootNode>;
var
  i, j, Tmp: integer;
  TiledObj: TTiledObject;
  T: TTransformNode;
  R: TX3DRootNode;
  RootNodeList: TRootNodeList;
  s: string;
begin
  RootNodeList := TRootNodeList.Create;
  try
    if ALayer^.LayerType = ltObjectGroup then
      for i := 0 to ALayer^.Objects.Count-1 do
      begin
        TiledObj := ALayer^.Objects[i];
        if TiledObj.Properties <> nil then
          for j := 0 to TiledObj.Properties.Count-1 do
          begin
            if TiledObj.Properties[j].Name = 'url' then
            begin
              T := TTransformNode.Create(TiledObj.Name);
              T.Translation := Vector3Single(
                  TiledObj.CenterX, TiledObj.CenterY, AZOrder);
              s := FTiledMap.DataPath + TiledObj.Properties[j].Value;
              if RootNodeList.Find(s, Tmp) then
                R := RootNodeList.Data[Tmp]
              else
              begin
                R := Load3D(s);
                RootNodeList.Add(s, R);;
              end;
              T.FdChildren.Add(R);
              FRoot.FdChildren.Add(T);
              break;
            end;
          end;
      end;
  finally
    FreeAndNil(RootNodeList);
  end;
end;

constructor TInternalTiledMapLoader.Create;
begin
  inherited;
  FTiledMap := nil;
  FTilePartWidth := 128;
  FTilePartHeight := 128;
end;

destructor TInternalTiledMapLoader.Destroy;
begin
  inherited;
end;

procedure TInternalTiledMapLoader.LoadTMX(const AURL: string);
begin
  FreeAndNil(FTiledMap);
  FTiledMap := TTiledMap.Create(AURL);
  FURL := AURL;
  InitNodeTree;
end;

function LoadTiled(URL: string; out ALoader: TObject): TX3DRootNode;
var
  Loader: TInternalTiledMapLoader;
begin
  Loader := TInternalTiledMapLoader.Create;
  try
    Loader.LoadTMX(URL);
    Result := Loader.Root;
    ALoader := Loader.TiledMap;
  finally
    FreeAndNil(Loader);
  end;
end;

end.
