{
  Copyright 2003-2006 Michalis Kamburelis.

  This file is part of "Kambi's 3dgraph Pascal units".

  "Kambi's 3dgraph Pascal units" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "Kambi's 3dgraph Pascal units" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "Kambi's 3dgraph Pascal units"; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{ Type TBox3d (rectangular prism with all sides
  parallel to basic planes X = 0, Y = 0 and Z = 0) and many operations on it.
  This is sometimes called AABB, "axis-aligned bounding box".

  This is a handy type, because it's easy to implement many
  operations on it in a fast manner.
}
unit Boxes3d;

interface

uses VectorMath, SysUtils, KambiUtils;

{$define read_interface}

type
  { First point always has all the smaller coords, second point has all
    the larger coords. I.e. always
@preformatted(
  Box[0, 0] <= Box[1, 0] and
  Box[0, 1] <= Box[1, 1] and
  Box[0, 2] <= Box[1, 2]
)
    The only exception is the special value EmptyBox3d. }
  TBox3d = array[0..1]of TVector3Single;
  PBox3d = ^TBox3d;

  TObjectBBox = class
  public
    function BoundingBox: TBox3d; virtual; abstract;
  end;

const
  { Special value for TBox3d meaning "bounding box doesn't exist".
    This is used when the object has no points, so bounding box
    doesn't exist. }
  EmptyBox3d: TBox3d = ((0, 0, 0), (-1, -1, -1));

{ Check is box empty.
  You can think of this function as "compare Box with EmptyBox3d".

  But actually it works a little faster, by utilizing the assumption
  that EmptyBox3d is the only allowed value that breaks
  Box[0, 0] <= Box[1, 0] rule. }
function IsEmptyBox3d(const Box: TBox3d): boolean;

function Box3d(const p0, p1: TVector3Single): TBox3d;
function Box3dOrderUp(const p0, p1: TVector3Single): TBox3d;

{ These functions calculate the middle point, average size, max size
  and particular sizes of given bounding box.
  When given Box is empty (IsEmptyBox3d), they raise some exception.

  @groupBegin }
function Box3dMiddle(const Box: TBox3d): TVector3Single;
function Box3dAvgSize(const Box: TBox3d): Single;
function Box3dMaxSize(const box: TBox3d): Single;
function Box3dMinSize(const box: TBox3d): Single;
function Box3dSizeX(const box: TBox3d): Single;
function Box3dSizeY(const box: TBox3d): Single;
function Box3dSizeZ(const box: TBox3d): Single;
{ @groupEnd }

{ This decreases Box[0, 0], Box[0, 1], Box[0, 2] by Expand
   and increases Box[1, 0], Box[1, 1], Box[1, 2] by Expand.
  So you get Box with all sizes increased by 2 * Expand.

  Box must not be empty.
  Note that Expand may be negative, but then you must be sure
  that it doesn't make Box empty. }
procedure BoxExpandTo1st(var Box: TBox3d; const Expand: Single); overload;

{ This decreases Box[0] by Expand, and increases Box[1] by Expand.
  So you get Box with all sizes increased by 2 * Expand.

  Box must not be empty.
  Note that Expand may be negative, but then you must be sure
  that it doesn't make Box empty. }
procedure BoxExpandTo1st(var box: TBox3d; const Expand: TVector3Single); overload;

function BoxExpand(var Box: TBox3d; const Expand: Single): TBox3d; overload;
function BoxExpand(var box: TBox3d; const Expand: TVector3Single): TBox3d; overload;

{ Check is the point inside the box.
  Always false if Box is empty (obviously, no point is inside an empty box).

  @groupBegin }
function Box3dPointInside(const pt: TVector3Single; const box: TBox3d): boolean; overload;
function Box3dPointInside(const pt: TVector3Double; const box: TBox3d): boolean; overload;
{ @groupEnd }

function Box3dCubeAroundPoint(const pt: TVector3Single; CubeSize: Single): TBox3d;

type
  TGetIndexFromIndexNumFunc = function(indexNum: integer): integer of object;
  TGetVertexFromIndexFunc = function(index: integer): TVector3Single of object;

{ oblicz bounding box (czyli najmniejszy prostopadloscian o bokach
  rownoleglych do plaszczyzn wspolrzednych) dla zbioru punktow 3d.
  Jesli VertsCount = 0 to zwroci EmptyBox3d.
  Wersja z matryca mnozy kazdy punkt przez zadane matrix.
  Wersja z funkcja jako parametrem - funkcja jest odpytywana dla indeksow
  0..VertsCount-1.

  As usual, VertsStride = 0 means VertsStride = SizeOf(TVector3Single) }
function CalculateBoundingBox(
  Verts: PVector3Single; VertsCount: Cardinal; VertsStride: Cardinal): TBox3d; overload;
function CalculateBoundingBox(
  Verts: PVector3Single; VertsCount: Cardinal; VertsStride: Cardinal;
  const Transform: TMatrix4Single): TBox3d; overload;
function CalculateBoundingBox(
  GetVertex: TGetVertexFromIndexFunc;
  VertsCount: integer): TBox3d; overload;

{ inna wersja CalculateBoundingBox : funkcja GetVertIndex
    zwraca dla liczb od 0 do VertsIndicesCount-1 kolejne indeksy.
    Jezeli indeks jest >=0 to z kolei funkcja GetVertex zwraca vertex
    o takim numerze (jezeli indeks jest < 0 to ignorujemy go, to znaczy
    taki indeks nie generuje nam zadnego vertexu).
    Zwracamy bounding box wszystkich tak otrzymanych vertexow.
  Wersja z ostatnim parametrem - matryca mnozy kazdy element przez ta matrix. }
function CalculateBoundingBoxFromIndices(
  GetVertIndex: TGetIndexFromIndexNumFunc;
  VertsIndicesCount: integer;
  GetVertex: TGetVertexFromIndexFunc): TBox3d; overload;
function CalculateBoundingBoxFromIndices(
  GetVertIndex: TGetIndexFromIndexNumFunc;
  VertsIndicesCount: integer;
  GetVertex: TGetVertexFromIndexFunc;
  const Transform: TMatrix4Single): TBox3d; overload;

{ Box3dSum (i To1st, gdzie wynik jest umieszczany z powrotem w pierwszym
  argumencie) : oblicz najmniejszy box3d taki ktory by obejmowal oba
  zadane box'y. }
function Box3dSum(const box1, box2: TBox3d): TBox3d;
procedure Box3dSumTo1st(var box1: TBox3d; const box2: TBox3d);

{ trzy rozmiary box'a }
function Box3dSizes(const box: TBox3d): TVector3Single;

{ wstawia pod allpoints[0], [1], .. [7] wszystkie rogi pudelka box}
procedure Box3dGetAllPoints(allpoints: PVector3Single; const box: TBox3d);

{ bierze bbbox, transformuje je matryca Matrix (a wiec byc moze skaluje,
  przesuwa i obraca) (tak otrzymany prostopadloscian juz nie jest
  box3d bo jego scianki niekoniecznie sa rownolegle do plaszczyzn
  x = 0, y = 0 i z = 0) i oblicza bounding box obejmujace tak otrzymany
  prostopadloscian. }
function BoundingBoxTransform(const bbox: TBox3d;
  const Matrix: TMatrix4Single): TBox3d;

{ Move Box. Does nothing if Box is empty. }
function Box3dTranslate(const Box: TBox3d;
  const Translation: TVector3Single): TBox3d;

function Box3dToNiceStr(const box: TBox3d): string;

procedure Box3dClamp(var point: TVector3Single; const box: TBox3d); overload;
procedure Box3dClamp(var point: TVector3Double; const box: TBox3d); overload;

{ TryBoxRayClosestIntersection znajduje przeciecie Boxa z promieniem
  najblizsze do Ray0, traktujac Box jako szesc wielokatow (tzn.
  przeciecie musi sie znalezc na ktoryms z bokow, nawet jezeli Ray0
  jest w srodku Boxa).

  Returns also IntersectionDistance, which is the distance to the Intersection
  relative to RayVector (i.e. Intersection is always = Ray0 +
  IntersectionDistance * RayVector). }
function TryBoxRayClosestIntersection(
  out Intersection: TVector3Single;
  out IntersectionDistance: Single;
  const Box: TBox3d; const Ray0, RayVector: TVector3Single): boolean; overload;
function TryBoxRayClosestIntersection(
  out Intersection: TVector3Single;
  const Box: TBox3d; const Ray0, RayVector: TVector3Single): boolean; overload;
function TryBoxRayClosestIntersection(
  out IntersectionDistance: Single;
  const Box: TBox3d; const Ray0, RayVector: TVector3Single): boolean; overload;

{ TryBoxRayEntrance traktuje Box jako zamknieta bryle - jezeli Ray0
  jest na zewnatrz Boxa to odpowiedz jest taka sama jak
  TryBoxRayClosestIntersection, jezeli Ray0 jest w Boxie to
  TryBoxRayEntrance zwroci po prostu Ray0. }
function TryBoxRayEntrance(out Entrance: TVector3Single;
  const Box: TBox3d; const Ray0, RayVector: TVector3Single): boolean;

function IsBox3dSegmentCollision(
  const Box: TBox3d;
  const Segment1, Segment2: TVector3Single): boolean;

function IsBox3dPlaneCollision(const Box3d: TBox3d;
  const Plane: TVector4Single): boolean;

{ This is equivalent to @link(FrustumSphereCollisionPossible),
  but here it takes a box instead of a sphere. }
function FrustumBox3dCollisionPossible(const Frustum: TFrustum;
  const Box: TBox3d): TFrustumCollisionPossible;

{ This is like @link(FrustumBox3dCollisionPossible)
  but it returns true when FrustumBox3dCollisionPossible
  would return fcSomeCollisionPossible or fcInsideFrustum.
  Otherwise (when FrustumBox3dCollisionPossible would return
  fcNoCollision) this returns false.

  So this returns less detailed result, but is a little faster. }
function FrustumBox3dCollisionPossibleSimple(const Frustum: TFrustum;
  const Box: TBox3d): boolean;

{ This calculates smallest possible sphere completely
  enclosing given Box.
  SphereRadiusSqr = 0 and SphereCenter is undefined if Box is empty. }
procedure Box3dBoundingSphere(const Box3d: TBox3d;
  var SphereCenter: TVector3Single; var SphereRadiusSqr: Single);

function Boxes3dCollision(const Box1, Box2: TBox3d): boolean;

{ This is just like Boxes3dCollision, but it takes into account only
  XY plane. I.e. it works like Box1 and Box2 are infinitely large in the
  Z coordinate. Or, in other words, this actually checks collision
  of 2D rectangles obtained by projecting both boxes on plane XY. }
function Boxes3dXYCollision(const Box1, Box2: TBox3d): boolean;

{ This calculates maximum Sqr(distance) of 8 box points to the (0, 0, 0)
  point. This can be useful when you want to get bounding sphere,
  centered in (0, 0, 0), around this Box. }
function Box3dSqrRadius(const Box: TBox3d): Single;

{ Just like Box3dSqrRadius, but this returns correct value
  (not it's Sqr). Speed note: you pay here one Sqrt operation. }
function Box3dRadius(const Box: TBox3d): Single;

{ This is like projecting Box on XY plane (i.e. we just ignore Z
  coords of Box points here), and then calculates maximum Sqr(distance)
  in place XY of 4 Box corners to point (0, 0). }
function Box3dXYSqrRadius(const Box: TBox3d): Single;

{ Just like Box3dXYSqrRadius, but this returns correct value
  (not it's Sqr). Speed note: you pay here one Sqrt operation. }
function Box3dXYRadius(const Box: TBox3d): Single;

type
  TDynArrayItem_1 = TBox3d;
  PDynArrayItem_1 = PBox3d;
  {$define DYNARRAY_1_IS_STRUCT}
  {$I dynarray_1.inc}
  TArray_Box3d = TInfiniteArray_1;
  PArray_Box3d = PInfiniteArray_1;
  TDynBox3dArray = TDynArray_1;

{$undef read_interface}

implementation

{$define read_implementation}
{$I dynarray_1.inc}

function IsEmptyBox3d(const Box: TBox3d): boolean;
begin
 result := Box[0, 0] > Box[1, 0];
end;

function Box3d(const p0, p1: TVector3Single): TBox3d;
begin
 result[0] := p0;
 result[1] := p1;
end;

function Box3dOrderUp(const p0, p1: TVector3Single): TBox3d;
begin
 OrderUp(p0[0], p1[0], result[0, 0], result[1, 0]);
 OrderUp(p0[1], p1[1], result[0, 1], result[1, 1]);
 OrderUp(p0[2], p1[2], result[0, 2], result[1, 2]);
end;

function Box3dMiddle(const Box: TBox3d): TVector3Single;
begin
 Check(not IsEmptyBox3d(Box), 'Empty box 3d - no middle point');
 {petla for i := 0 to 2 rozwinieta aby zyskac tycityci na czasie}
 result[0] := (Box[0, 0]+Box[1, 0])/2;
 result[1] := (Box[0, 1]+Box[1, 1])/2;
 result[2] := (Box[0, 2]+Box[1, 2])/2;
end;

function Box3dAvgSize(const Box: TBox3d): Single;
begin
 Check(not IsEmptyBox3d(Box), 'Empty box 3d - no average size');
 {korzystamy z faktu ze Box3d ma wierzcholki uporzadkowane
  i w zwiazku z tym w roznicach ponizej nie musimy robic abs() }
 result := ((Box[1, 0]-Box[0, 0]) +
            (Box[1, 1]-Box[0, 1]) +
            (Box[1, 2]-Box[0, 2]))/3;
end;

function Box3dMaxSize(const box: TBox3d): Single;
var sizes: TVector3Single;
begin
 Check(not IsEmptyBox3d(Box), 'Empty box 3d - no maximum size');
 sizes := Box3dSizes(box);
 result := sizes[MaxVectorCoord(sizes)];
end;

function Box3dMinSize(const box: TBox3d): Single;
begin
 Check(not IsEmptyBox3d(Box), 'Empty box 3d - no maximum size');

 Result := Min(
   Box[1, 0] - Box[0, 0],
   Box[1, 1] - Box[0, 1],
   Box[1, 2] - Box[0, 2]);

 { Another version is below (but this is slower without any benefit...)

   var sizes: TVector3Single;
     sizes := Box3dSizes(box);
     result := sizes[MaxVectorCoord(sizes)];
 }
end;

function Box3dSizeX(const box: TBox3d): Single;
begin
  Check(not IsEmptyBox3d(Box), 'Empty box 3d - no size');
  Result := Box[1, 0] - Box[0, 0];
end;

function Box3dSizeY(const box: TBox3d): Single;
begin
  Check(not IsEmptyBox3d(Box), 'Empty box 3d - no size');
  Result := Box[1, 1] - Box[0, 1];
end;

function Box3dSizeZ(const box: TBox3d): Single;
begin
  Check(not IsEmptyBox3d(Box), 'Empty box 3d - no size');
  Result := Box[1, 2] - Box[0, 2];
end;

function Box3dCubeAroundPoint(const pt: TVector3Single; cubeSize: Single): TBox3d;
begin
 result[0] := VectorSubtract(pt, Vector3Single(-cubeSize, -cubeSize, -cubeSize));
 result[1] := VectorAdd(pt, Vector3Single(cubeSize, cubeSize, cubeSize));
end;

procedure BoxExpandTo1st(var Box: TBox3d; const Expand: Single);
begin
 Box[0, 0] -= Expand;
 Box[0, 1] -= Expand;
 Box[0, 2] -= Expand;

 Box[1, 0] += Expand;
 Box[1, 1] += Expand;
 Box[1, 2] += Expand;
end;

procedure BoxExpandTo1st(var box: TBox3d; const Expand: TVector3Single);
begin
 Box[0, 0] -= Expand[0];
 Box[0, 1] -= Expand[1];
 Box[0, 2] -= Expand[2];

 Box[1, 0] += Expand[0];
 Box[1, 1] += Expand[1];
 Box[1, 2] += Expand[2];
end;

function BoxExpand(var Box: TBox3d; const Expand: Single): TBox3d;
begin
  Result[0, 0] := Box[0, 0] - Expand;
  Result[0, 1] := Box[0, 1] - Expand;
  Result[0, 2] := Box[0, 2] - Expand;

  Result[1, 0] := Box[1, 0] + Expand;
  Result[1, 1] := Box[1, 1] + Expand;
  Result[1, 2] := Box[1, 2] + Expand;
end;

function BoxExpand(var box: TBox3d; const Expand: TVector3Single): TBox3d;
begin
  Result[0, 0] := Box[0, 0] - Expand[0];
  Result[0, 1] := Box[0, 1] - Expand[1];
  Result[0, 2] := Box[0, 2] - Expand[2];

  Result[1, 0] := Box[1, 0] + Expand[0];
  Result[1, 1] := Box[1, 1] + Expand[1];
  Result[1, 2] := Box[1, 2] + Expand[2];
end;

{$define Box3dPointInside_IMPLEMENT:=
begin
 if IsEmptyBox3d(box) then exit(false);
 result := Between(pt[0], box[0, 0], box[1, 0]) and
           Between(pt[1], box[0, 1], box[1, 1]) and
           Between(pt[2], box[0, 2], box[1, 2]);
end;}

function Box3dPointInside(const pt: TVector3Single; const box: TBox3d): boolean;
Box3dPointInside_IMPLEMENT

function Box3dPointInside(const pt: TVector3Double; const box: TBox3d): boolean;
Box3dPointInside_IMPLEMENT

{ MinSingleTo1st i MaxSingleTo1st will be useful for CalculateBoundingBox }
type
  TChooseOneTo1st_Single = procedure (var A: Single; const B: Single);

procedure MaxSingleTo1st(var A: Single; const B: Single);
begin
  if A < B then A := B;
end;

procedure MinSingleTo1st(var A: Single; const B: Single);
begin
  if A > B then A := B;
end;

function CalculateBoundingBox(
  GetVertex: TGetVertexFromIndexFunc;
  VertsCount: integer): TBox3d;

{ TODO: sprawdzic - czy jest realny sens w implementowaniu tu
  algorytmu MinMax ktory znajduje min i max jednoczesnie w czasie
  3/2*n zamiast 2*n ? }

  function find_extremum(ChooseFuncTo1st: TChooseOneTo1st_Single;
    coord: integer): Single;
  var i: integer;
  begin
   result := GetVertex(0)[coord];
   for i := 1 to VertsCount-1 do
     ChooseFuncTo1st(Result, GetVertex(i)[coord]);
  end;

begin
 if VertsCount = 0 then
 begin
  result := EmptyBox3d;
  exit
 end;

 result[0, 0] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MinSingleTo1st, 0);
 result[0, 1] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MinSingleTo1st, 1);
 result[0, 2] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MinSingleTo1st, 2);
 result[1, 0] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MaxSingleTo1st, 0);
 result[1, 1] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MaxSingleTo1st, 1);
 result[1, 2] := find_extremum({$ifdef FPC_OBJFPC} @ {$endif} MaxSingleTo1st, 2);
end;

type
  {klasa do wewnetrznego uzytku w CalculateBoundingBox}
  TBBox_Calculator = class
    Verts: PVector3Single;
    VertsStride: Cardinal; { tutaj VertsStride juz nie moze byc = 0 }
    PMatrix: PMatrix4Single;
    function GetVertexNotTransform(index: integer): TVector3Single;
    function GetVertexTransform(index: integer): TVector3Single;
  end;

  function TBBox_Calculator.GetVertexNotTransform(index: integer): TVector3Single;
  begin
   result := PVector3Single(PointerAdd(Verts, VertsStride*Cardinal(index)))^;
  end;

  function TBBox_Calculator.GetVertexTransform(index: integer): TVector3Single;
  begin
   result := MultMatrixPoint(
     PMatrix^, PVector3Single(PointerAdd(Verts, VertsStride*Cardinal(index)))^ );
  end;

function CalculateBoundingBox(
  Verts: PVector3Single; VertsCount: Cardinal; VertsStride: Cardinal): TBox3d;
var Calculator: TBBox_Calculator;
begin
 if VertsStride = 0 then VertsStride := SizeOf(TVector3Single);
 Calculator := TBBox_Calculator.Create;
 try
  Calculator.VertsStride := VertsStride;
  Calculator.Verts := Verts;
  result := CalculateBoundingBox(
    {$ifdef FPC_OBJFPC} @ {$endif} Calculator.GetVertexNotTransform, VertsCount);
 finally Calculator.Free end;
end;

function CalculateBoundingBox(
  Verts: PVector3Single; VertsCount: Cardinal; VertsStride: Cardinal;
  const Transform: TMatrix4Single): TBox3d;
var Calculator: TBBox_Calculator;
begin
 if VertsStride = 0 then VertsStride := SizeOf(TVector3Single);
 Calculator := TBBox_Calculator.Create;
 try
  Calculator.VertsStride := VertsStride;
  Calculator.Verts := Verts;
  Calculator.PMatrix := @Transform;
  result := CalculateBoundingBox(
    {$ifdef FPC_OBJFPC} @ {$endif} Calculator.GetVertexTransform, VertsCount);
 finally Calculator.Free end;
end;

function CalculateBoundingBoxFromIndices(
  GetVertIndex: TGetIndexFromIndexNumFunc;
  VertsIndicesCount: integer;
  GetVertex: TGetVertexFromIndexFunc): TBox3d;
var
  { pozycja pierwszego nieujemnego indexu.
    Zwracamy EmptyBox3d wtw. gdy firstIndex nie istnieje }
  FirstIndexNum: integer;

  IndexNum, Index: integer;
  ThisVertex: TVector3Single;
begin
 {seek for firstIndex}
 firstIndexNum := 0;
 while (firstIndexNum < VertsIndicesCount) and (GetVertIndex(firstIndexNum) < 0) do
  Inc(firstIndexNum);

 if firstIndexNum = VertsIndicesCount then {firstIndex not found ?}
 begin
  result := EmptyBox3d;
  exit;
 end;

 { Note that I do only one pass, getting all vertexes.

   This is important, because GetVertex may be quite expensive
   operation (in case of e.g. TVertTransform_Calculator.GetTransformed,
   this is MultMatrixPoint for every vertex). At the beginning
   I implemented this by caling 6 time find_extremum function,
   and each call to find_extremum was iterating over every vertex.
   This was obviously wrong, because this caused calling GetVertex
   6 times more often than necessary. In some cases (like preparing
   TVRMLGLAnimation in "The Castle") this can cause really significant
   slowdown. }

 ThisVertex := GetVertex(GetVertIndex(firstIndexNum));
 Result[0] := ThisVertex;
 Result[1] := ThisVertex;
 for IndexNum := FirstIndexNum+1 to VertsIndicesCount - 1 do
 begin
   Index := GetVertIndex(IndexNum);
   if Index >= 0 then
   begin
     ThisVertex := GetVertex(Index);
     if ThisVertex[0] < Result[0, 0] then Result[0, 0] := ThisVertex[0];
     if ThisVertex[1] < Result[0, 1] then Result[0, 1] := ThisVertex[1];
     if ThisVertex[2] < Result[0, 2] then Result[0, 2] := ThisVertex[2];
     if ThisVertex[0] > Result[1, 0] then Result[1, 0] := ThisVertex[0];
     if ThisVertex[1] > Result[1, 1] then Result[1, 1] := ThisVertex[1];
     if ThisVertex[2] > Result[1, 2] then Result[1, 2] := ThisVertex[2];
   end;
 end;
end;

type
  TVertTransform_Calculator = class
    PTransform: PMatrix4Single;
    GetNotTransformed: TGetVertexFromIndexFunc;
    function GetTransformed(index: integer): TVector3Single;
  end;
  function TVertTransform_Calculator.GetTransformed(index: integer): TVector3Single;
  begin
   result := MultMatrixPoint(PTransform^, GetNotTransformed(index));
  end;

function CalculateBoundingBoxFromIndices(
  GetVertIndex: TGetIndexFromIndexNumFunc;
  VertsIndicesCount: integer;
  GetVertex: TGetVertexFromIndexFunc;
  const Transform: TMatrix4Single): TBox3d;
var Calculator: TVertTransform_Calculator;
begin
 Calculator := TVertTransform_Calculator.Create;
 try
  Calculator.PTransform := @Transform;
  Calculator.GetNotTransformed := GetVertex;
  result := CalculateBoundingBoxFromIndices(
    GetVertIndex,
    VertsIndicesCount,
    {$ifdef FPC_OBJFPC} @ {$endif} Calculator.GetTransformed);
 finally Calculator.Free end;
end;

function Box3dSum(const box1, box2: TBox3d): TBox3d;
begin
  if IsEmptyBox3d(box1) then
    Result := box2 else
  if IsEmptyBox3d(box2) then
    Result := box1 else
  begin
    result[0, 0] := min(box1[0, 0], box2[0, 0]);
    result[1, 0] := max(box1[1, 0], box2[1, 0]);
    result[0, 1] := min(box1[0, 1], box2[0, 1]);
    result[1, 1] := max(box1[1, 1], box2[1, 1]);
    result[0, 2] := min(box1[0, 2], box2[0, 2]);
    result[1, 2] := max(box1[1, 2], box2[1, 2]);
  end;
end;

procedure Box3dSumTo1st(var box1: TBox3d; const box2: TBox3d);
begin
  if IsEmptyBox3d(box2) then
    Exit else
  if IsEmptyBox3d(box1) then
    box1 := box2 else
  begin
    MinTo1st(box1[0, 0], box2[0, 0]);
    MaxTo1st(box1[1, 0], box2[1, 0]);
    MinTo1st(box1[0, 1], box2[0, 1]);
    MaxTo1st(box1[1, 1], box2[1, 1]);
    MinTo1st(box1[0, 2], box2[0, 2]);
    MaxTo1st(box1[1, 2], box2[1, 2]);
  end;
end;

function Box3dSizes(const box: TBox3d): TVector3Single;
begin
 result[0] := box[1, 0]-box[0, 0];
 result[1] := box[1, 1]-box[0, 1];
 result[2] := box[1, 2]-box[0, 2];
end;

procedure Box3dGetAllPoints(allpoints: PVector3Single; const box: TBox3d);
const
  {zapisy dwojkowe liczb od 0 do 7 czyli wszystkie kombinacje 0 i 1-nek
   na 3 pozycjach.}
  kombinacje: array[0..7, 0..2]of 0..1 =
  ((0, 0, 0), (0, 0, 1), (0, 1, 0), (0, 1, 1), (1, 0, 0), (1, 0, 1), (1, 1, 0), (1, 1, 1));
var i, j: integer;
begin
 for i := 0 to 7 do
  for j := 0 to 2 do
   PArray_Vector3Single(allpoints)^[i][j] := box[kombinacje[i, j], j];
end;

function BoundingBoxTransform(const bbox: TBox3d; const Matrix: TMatrix4Single): TBox3d;
var boxpoints: array[0..7]of TVector3Single;
    i: integer;
begin
 Box3dGetAllPoints(@boxpoints, bbox);
 for i := 0 to 7 do boxpoints[i] := MultMatrixPoint(Matrix, boxpoints[i]);
 result := CalculateBoundingBox(@boxpoints, 8, 0);
end;

function Box3dTranslate(const Box: TBox3d;
  const Translation: TVector3Single): TBox3d;
begin
  if not IsEmptyBox3d(Box) then
  begin
    Result[0] := VectorAdd(Box[0], Translation);
    Result[1] := VectorAdd(Box[1], Translation);
  end else
    Result := EmptyBox3d;
end;

function Box3dToNiceStr(const box: TBox3d): string;
begin
 if IsEmptyBox3d(box) then
  result := 'EMPTY' else
  result := VectorToniceStr(box[0])+' - '+VectorToNiceStr(box[1]);
end;

{$define CLAMP_IMPLEMENTATION:=
  var i: integer;
  begin
   for i := 0 to 2 do
   begin
    if point[i] < box[0, i] then point[i] := box[0, i] else
     if point[i] > box[1, i] then point[i] := box[1, i];
   end;
  end;}

procedure Box3dClamp(var point: TVector3Single; const box: TBox3d); CLAMP_IMPLEMENTATION
procedure Box3dClamp(var point: TVector3Double; const box: TBox3d); CLAMP_IMPLEMENTATION

function TryBoxRayClosestIntersection(
  out Intersection: TVector3Single;
  out IntersectionDistance: Single;
  const Box: TBox3d;
  const Ray0, RayVector: TVector3Single): boolean;
var
  IntrProposed: boolean absolute result;

  procedure ProposeBoxIntr(const PlaneConstCoord: integer;
    const PlaneConstValue: Single);
  var
    NowIntersection: TVector3Single;
    NowIntersectionDistance: Single;
    c1, c2: integer;
  begin
    if TrySimplePlaneRayIntersection(NowIntersection, NowIntersectionDistance,
      PlaneConstCoord, PlaneConstValue, Ray0, RayVector) then
    begin
      RestOf3dCoords(PlaneConstCoord, c1, c2);
      if Between(NowIntersection[c1], Box[0, c1], Box[1, c1]) and
         Between(NowIntersection[c2], Box[0, c2], Box[1, c2]) then
      begin
        if (not IntrProposed) or
           (NowIntersectionDistance < IntersectionDistance) then
        begin
          IntrProposed := true;
          Intersection := NowIntersection;
          IntersectionDistance := NowIntersectionDistance;
        end;
      end;
    end;
  end;

var
  I: integer;
begin
  IntrProposed := false;
  for I := 0 to 2 do
  begin
    { wykorzystujemy ponizej fakt ze jezeli Ray0[i] < Box[0, i] to na pewno
      promien ktory przecinalby scianke Box[1, i] pudelka przecinalby najpierw
      tez inna scianke. Wiec jezeli Ray0[i] < Box[0, i] to nie musimy sprawdzac
      przeciecia z plaszczyzna Box[1, i]. }
    if Ray0[i] < Box[0, i] then
      ProposeBoxIntr(i, Box[0, i]) else
    if Ray0[i] > Box[1, i] then
      ProposeBoxIntr(i, Box[1, i]) else
    begin
      ProposeBoxIntr(i, Box[0, i]);
      ProposeBoxIntr(i, Box[1, i]);
    end;
  end;
end;

function TryBoxRayClosestIntersection(
  out Intersection: TVector3Single;
  const Box: TBox3d;
  const Ray0, RayVector: TVector3Single): boolean;
var
  IntersectionDistance: Single;
begin
  Result := TryBoxRayClosestIntersection(
    Intersection, IntersectionDistance, Box, Ray0, RayVector);
end;

function TryBoxRayClosestIntersection(
  out IntersectionDistance: Single;
  const Box: TBox3d;
  const Ray0, RayVector: TVector3Single): boolean;
var
  Intersection: TVector3Single;
begin
  Result := TryBoxRayClosestIntersection(
    Intersection, IntersectionDistance, Box, Ray0, RayVector);
end;

function TryBoxRayEntrance(out Entrance: TVector3Single;
  const Box: TBox3d; const Ray0, RayVector: TVector3Single): boolean;
begin
 if Box3dPointInside(Ray0, Box) then
 begin
  Entrance := Ray0;
  result := true;
 end else
  result := TryBoxRayClosestIntersection(Entrance, Box, Ray0, RayVector);
end;

function IsBox3dSegmentCollision(
  const Box: TBox3d;
  const Segment1, Segment2: TVector3Single): boolean;

  function IsCollisionWithBoxPlane(const PlaneConstCoord: integer;
    const PlaneConstValue: Single): boolean;
  var
    NowIntersection: TVector3Single;
    c1, c2: integer;
  begin
    if TrySimplePlaneSegmentIntersection(NowIntersection,
      PlaneConstCoord, PlaneConstValue, Segment1, Segment2) then
    begin
      RestOf3dCoords(PlaneConstCoord, c1, c2);
      Result :=
        Between(NowIntersection[c1], Box[0, c1], Box[1, c1]) and
        Between(NowIntersection[c2], Box[0, c2], Box[1, c2]);
    end else
      Result := false;
  end;

var
  I: integer;
begin
  for I := 0 to 2 do
  begin
    { wykorzystujemy ponizej fakt ze jezeli Segment1[i] < Box[0, i] to na pewno
      promien ktory przecinalby scianke Box[1, i] pudelka przecinalby najpierw
      tez inna scianke. Wiec jezeli Segment1[i] < Box[0, i] to nie musimy sprawdzac
      przeciecia z plaszczyzna Box[1, i]. }
    if Segment1[i] < Box[0, i] then
    begin
      if IsCollisionWithBoxPlane(i, Box[0, i]) then Exit(true);
    end else
    if Segment1[i] > Box[1, i] then
    begin
      if IsCollisionWithBoxPlane(i, Box[1, i]) then Exit(true);
    end else
    begin
      if IsCollisionWithBoxPlane(i, Box[0, i]) then Exit(true);
      if IsCollisionWithBoxPlane(i, Box[1, i]) then Exit(true);
    end;
  end;

  Result := false;
end;

function IsBox3dPlaneCollision(const Box3d: TBox3d; const Plane: TVector4Single): boolean;

  function Corner(const x01, y01, z01: boolean): TVector3Single;
  { zwroc odpowiedni z 8 rogow Box3d, dodatkowo dodajac
    lub odejmujac SingleEqualityEpsilon tak zeby Box3d wydawal sie wiekszy
    o SingleEqualityEpsilon }
  begin
   if x01 then result[0] := Box3d[0, 0]-SingleEqualityEpsilon else result[0] := Box3d[1, 0]+SingleEqualityEpsilon;
   if y01 then result[1] := Box3d[0, 1]-SingleEqualityEpsilon else result[1] := Box3d[1, 1]+SingleEqualityEpsilon;
   if z01 then result[2] := Box3d[0, 2]-SingleEqualityEpsilon else result[2] := Box3d[1, 2]+SingleEqualityEpsilon;
  end;

  function CalcCornerPlaneSide(const x01, y01, z01: boolean): Single;
  { po prostu podstaw punkt Corner(x01, y01, z01) do rownania Plane }
  var corn: TVector3Single;
  begin
   corn := Corner(x01, y01, z01);
   result := Plane[0]*corn[0] + Plane[1]*corn[1] + Plane[2]*corn[2] + Plane[3];
  end;

var bits: byte;
    cornerPlaneSide: Single;
    side: boolean;
begin
 { zeby box nie przecial plane, kazdy punkt boxa musi byc po tej samej
   stronie plane (i zaden nie moze lezec na plane). To jest warunek
   konieczny i dostateczny. }

 { najpierw policz side uzywajac punktu Corner(false, false, false).
   Wszystkie pozostale punkty beda musialy miec takie samo Side.
   Zwroc uwage ze porownuje cornerPlaneSide z zerem normalnie (nie uzywam
   FloatsEqual) bo juz w samej funkcji Corner zawarlem SingleEpsilonEquality. }
 cornerPlaneSide := CalcCornerPlaneSide(false, false, false);
 if cornerPlaneSide = 0 then Exit(true);
 Side := cornerPlaneSide > 0;

 for bits := 1 to 7 do
 begin
  cornerPlaneSide := CalcCornerPlaneSide(
    (bits and 1) <> 0,
    (bits and 2) <> 0,
    (bits and 4) <> 0);
  if cornerPlaneSide = 0 then Exit(true);
  if (cornerPlaneSide > 0) <> Side then Exit(true);
 end;

 result := false;
end;

function FrustumBox3dCollisionPossible(const Frustum: TFrustum;
  const Box: TBox3d): TFrustumCollisionPossible;

{ Note: I tried to optimize this function,
  since it's crucial for TOctree.EnumerateCollidingOctreeItems,
  and this is crucial for TVRMLFlatSceneGL.RenderFrustumOctree,
  and this is crucial for overall speed of rendering. }

var
  fp: TFrustumPlane;
  FrustumMultiplyBox: TBox3d;

  function CheckOutsideCorner(const XIndex, YIndex, ZIndex: Cardinal): boolean;
  begin
   Result :=
     { Frustum[fp][0] * Box[XIndex][0] +
       Frustum[fp][1] * Box[YIndex][1] +
       Frustum[fp][2] * Box[ZIndex][2] +
       optimized version : }
     FrustumMultiplyBox[XIndex][0] +
     FrustumMultiplyBox[YIndex][1] +
     FrustumMultiplyBox[ZIndex][2] +
     Frustum[fp][3] < 0;
  end;

var InsidePlanesCount: Cardinal;
begin
 InsidePlanesCount := 0;

 { The login goes like this:
     if box is on the "outside" of *any* of 6 planes, result is NoCollision
     if box is on the "inside" of *all* 6 planes, result is InsideFrustum
     else SomeCollisionPossible. }

 for fp := Low(fp) to High(fp) do
 begin
  { This way I need 6 multiplications instead of 8*3=24
    (in case I would have to execute CheckOutsideCorner 8 times) }
  FrustumMultiplyBox[0][0] := Frustum[fp][0] * Box[0][0];
  FrustumMultiplyBox[0][1] := Frustum[fp][1] * Box[0][1];
  FrustumMultiplyBox[0][2] := Frustum[fp][2] * Box[0][2];
  FrustumMultiplyBox[1][0] := Frustum[fp][0] * Box[1][0];
  FrustumMultiplyBox[1][1] := Frustum[fp][1] * Box[1][1];
  FrustumMultiplyBox[1][2] := Frustum[fp][2] * Box[1][2];

  { I'm splitting code below to two possilibilities.
    This way I can calculate 7 remaining CheckOutsideCorner
    calls using code  like
      "... and ... and ..."
    or
      "... or ... or ..."
    , and this means that short-circuit boolean evaluation
    may usually reduce number of needed CheckOutsideCorner calls
    (i.e. I will not need to actually call CheckOutsideCorner 8 times
    per frustum plane). }

  if CheckOutsideCorner(0, 0, 0) then
  begin
   if CheckOutsideCorner(0, 0, 1) and
      CheckOutsideCorner(0, 1, 0) and
      CheckOutsideCorner(0, 1, 1) and
      CheckOutsideCorner(1, 0, 0) and
      CheckOutsideCorner(1, 0, 1) and
      CheckOutsideCorner(1, 1, 0) and
      CheckOutsideCorner(1, 1, 1) then
    { All 8 corners outside }
    Exit(fcNoCollision);
  end else
  begin
   if not (
      CheckOutsideCorner(0, 0, 1) or
      CheckOutsideCorner(0, 1, 0) or
      CheckOutsideCorner(0, 1, 1) or
      CheckOutsideCorner(1, 0, 0) or
      CheckOutsideCorner(1, 0, 1) or
      CheckOutsideCorner(1, 1, 0) or
      CheckOutsideCorner(1, 1, 1) ) then
    { All 8 corners inside }
    Inc(InsidePlanesCount);
  end;
 end;

 if InsidePlanesCount = 6 then
  Result := fcInsideFrustum else
  Result := fcSomeCollisionPossible;
end;

function FrustumBox3dCollisionPossibleSimple(const Frustum: TFrustum;
  const Box: TBox3d): boolean;

{ Implementation is obviously based on
  FrustumBox3dCollisionPossible above, see there for more comments. }

var
  fp: TFrustumPlane;
  FrustumMultiplyBox: TBox3d;

  function CheckOutsideCorner(const XIndex, YIndex, ZIndex: Cardinal): boolean;
  begin
   Result :=
     { Frustum[fp][0] * Box[XIndex][0] +
       Frustum[fp][1] * Box[YIndex][1] +
       Frustum[fp][2] * Box[ZIndex][2] +
       optimized version : }
     FrustumMultiplyBox[XIndex][0] +
     FrustumMultiplyBox[YIndex][1] +
     FrustumMultiplyBox[ZIndex][2] +
     Frustum[fp][3] < 0;
  end;

begin
 for fp := Low(fp) to High(fp) do
 begin
  { This way I need 6 multiplications instead of 8*3=24 }
  FrustumMultiplyBox[0][0] := Frustum[fp][0] * Box[0][0];
  FrustumMultiplyBox[0][1] := Frustum[fp][1] * Box[0][1];
  FrustumMultiplyBox[0][2] := Frustum[fp][2] * Box[0][2];
  FrustumMultiplyBox[1][0] := Frustum[fp][0] * Box[1][0];
  FrustumMultiplyBox[1][1] := Frustum[fp][1] * Box[1][1];
  FrustumMultiplyBox[1][2] := Frustum[fp][2] * Box[1][2];

  if CheckOutsideCorner(0, 0, 0) and
     CheckOutsideCorner(0, 0, 1) and
     CheckOutsideCorner(0, 1, 0) and
     CheckOutsideCorner(0, 1, 1) and
     CheckOutsideCorner(1, 0, 0) and
     CheckOutsideCorner(1, 0, 1) and
     CheckOutsideCorner(1, 1, 0) and
     CheckOutsideCorner(1, 1, 1) then
    Exit(false);
 end;

 Result := true;
end;

procedure Box3dBoundingSphere(const Box3d: TBox3d;
  var SphereCenter: TVector3Single; var SphereRadiusSqr: Single);
begin
 if IsEmptyBox3d(Box3d) then
 begin
  SphereRadiusSqr := 0;
 end else
 begin
  SphereCenter := Box3dMiddle(Box3d);
  SphereRadiusSqr := PointsDistanceSqr(SphereCenter, Box3d[0]);
 end;
end;

function Boxes3dCollision(const Box1, Box2: TBox3d): boolean;
begin
  Result :=
    (not IsEmptyBox3d(Box1)) and
    (not IsEmptyBox3d(Box2)) and
    (not ((Box1[1, 0] < Box2[0, 0]) or (Box2[1, 0] < Box1[0, 0]))) and
    (not ((Box1[1, 1] < Box2[0, 1]) or (Box2[1, 1] < Box1[0, 1]))) and
    (not ((Box1[1, 2] < Box2[0, 2]) or (Box2[1, 2] < Box1[0, 2])));
end;

function Boxes3dXYCollision(const Box1, Box2: TBox3d): boolean;
begin
  Result :=
    (not IsEmptyBox3d(Box1)) and
    (not IsEmptyBox3d(Box2)) and
    (not ((Box1[1, 0] < Box2[0, 0]) or (Box2[1, 0] < Box1[0, 0]))) and
    (not ((Box1[1, 1] < Box2[0, 1]) or (Box2[1, 1] < Box1[0, 1])));
end;

function Box3dSqrRadius(const Box: TBox3d): Single;
begin
  Result := Max(
    Max(Max(VectorLenSqr(Vector3Single(Box[0, 0], Box[0, 1], Box[0, 2])),
            VectorLenSqr(Vector3Single(Box[1, 0], Box[0, 1], Box[0, 2]))),
        Max(VectorLenSqr(Vector3Single(Box[1, 0], Box[1, 1], Box[0, 2])),
            VectorLenSqr(Vector3Single(Box[0, 0], Box[1, 1], Box[0, 2])))),
    Max(Max(VectorLenSqr(Vector3Single(Box[0, 0], Box[0, 1], Box[1, 2])),
            VectorLenSqr(Vector3Single(Box[1, 0], Box[0, 1], Box[1, 2]))),
        Max(VectorLenSqr(Vector3Single(Box[1, 0], Box[1, 1], Box[1, 2])),
            VectorLenSqr(Vector3Single(Box[0, 0], Box[1, 1], Box[1, 2])))));
end;

function Box3dRadius(const Box: TBox3d): Single;
begin
  Result := Sqrt(Box3dSqrRadius(Box));
end;

function Box3dXYSqrRadius(const Box: TBox3d): Single;
begin
  Result := Max(
    Max(VectorLenSqr(Vector2Single(Box[0, 0], Box[0, 1])),
        VectorLenSqr(Vector2Single(Box[1, 0], Box[0, 1]))),
    Max(VectorLenSqr(Vector2Single(Box[1, 0], Box[1, 1])),
        VectorLenSqr(Vector2Single(Box[0, 0], Box[1, 1]))));
end;

function Box3dXYRadius(const Box: TBox3d): Single;
begin
  Result := Sqrt(Box3dXYSqrRadius(Box));
end;

end.
