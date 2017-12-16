unit ImageListEx;

interface

uses
  Classes, Controls, Graphics;

type
  TImageListEx = class helper for TImageList
  public
    procedure LoadAndSplitImages(filename: string);
  end;

implementation

(*
If Images < 1 then entire AGraphic will be split up into
individual images, otherwise only NumberOfImages will
be added to the ImageList.

Images are processed from left to right and top to bottom.

Source: http://www.delphipages.com/forum/showpost.php?p=154601&postcount=8
*)
procedure SetImageList(AGraphic: TGraphic; ImageList: TImageList; ClearList: boolean; NumberOfImages: integer = 0);
var
  mask, image, bmp: TBitmap;
  AColor: TColor;
  modX, modY, x, y, xx, yy, imgWid, imgHgt: integer;
  cnt: integer;
begin
  Assert((AGraphic <> nil) and Assigned(ImageList));
  if ClearList then ImageList.Clear;

  mask := TBitmap.Create;
  image := TBitmap.Create;
  bmp := TBitmap.Create;
  try
    image.PixelFormat := pf24bit;
    image.Width := AGraphic.Width;
    image.Height := AGraphic.Height;
    image.Canvas.Draw(0, 0, AGraphic);
    //Get the lower left pixel color (the transparent color).
    AColor := image.Canvas.Pixels[0, image.Height -1];

    x := ImageList.Width;
    y := ImageList.Height;
    modX := x -(image.Width mod x);
    modY := y -(image.Height mod y);

    if (modX <> x) or (modY <> y) then
    begin
      //Resize image bitmap so that it's width and height
      //are a multiple of the imagelist's width and height.
      image.Width := AGraphic.Width +modX;
      image.Height := AGraphic.Height +modY;
      image.Canvas.Brush.Color := AColor;
      image.Canvas.FillRect(Rect(0, 0, image.Width, image.Height));
      //Draw the graphic centered on the image bitmap.
      image.Canvas.Draw(modX div 2, modY div 2, AGraphic);
    end;

    imgWid := image.Width;
    imgHgt := image.Height;

    //Size bmp to the imagelist's sizes.
    bmp.Width := x;
    bmp.Height := y;

    if NumberOfImages > 0 then
      cnt := NumberOfImages
    else
      cnt := (imgWid div x) *(imgHgt div y);

    xx := 0;
    yy := 0;
    while (cnt > 0) and (yy < imgHgt) do
    begin
      //Draw at negative xx/yy (only the portion that overlaps
      //the canvas will be drawn.
      bmp.Canvas.Draw(-xx, -yy, image);
      //Create the mask for transparency.
      mask.Assign(bmp);
      mask.Canvas.Brush.Color := AColor;
      mask.Monochrome := true;

      //Add the bmp to the imagelist.
      ImageList.Add(bmp, mask);
      Dec(cnt);

      Inc(xx, x);
      if xx +x > imgWid then
      begin
        //Get the next row.
        xx := 0;
        Inc(yy, y);
      end;
    end;
  finally
    bmp.Free;
    mask.Free;
    image.Free;
  end;
end;

procedure TImageListEx.LoadAndSplitImages(filename: string);
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.LoadFromFile(filename);
    SetImageList(bmp, Self, true);
  finally
    bmp.Free;
  end;
end;

end.
