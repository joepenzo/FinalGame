
package utils
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	
	public class StarlingDraw
	{
		
		
		public static function RectangleQuadBatch(width : int, height : int, color : uint) : QuadBatch {
			var quadBatch:QuadBatch = new QuadBatch();
			
			var tex:Texture = Texture.fromBitmapData(new BitmapData(width, height, true));
			var image:Image = new Image(tex);
			image.color = color;
			
			quadBatch.addImage(image);
			
			return quadBatch;
		}
		
		/*
		This looks more heavy
		*/
		public static function RectangleImage(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : * {
			if (width > 2048) return;
			var shape:Sprite = new Sprite();
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0,width, height);
			shape.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(width, height, false);
			bmd.draw(shape);
			var tex:Texture = Texture.fromBitmapData(bmd);
			var img:Image = new Image(tex);
			
			return img;
		}
		
		public static function ColorImage(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : * {
			if (width > 2048) return;
		
			var tex:Texture = Texture.fromBitmapData(new BitmapData(width, height, true));
			
			var img:Image = new Image(tex);
			img.color = color;
			
			return img;
		}
		
		
		public static function Polygon(points: *, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : * {
			var shape:Sprite = new Sprite();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			
			for(var i : int = 0; i < points.length; ++i) {
				if(i == 0) {
					shape.graphics.moveTo(points[i].x, points[i].y);
				} else {
					shape.graphics.lineTo(points[i].x, points[i].y);
				}    
			}
			shape.graphics.lineTo(points[0].x, points[0].y);
			shape.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(shape.width, shape.height, true);
			bmd.draw(shape);
			var tex:Texture = Texture.fromBitmapData(bmd);
			var img:Image = new Image(tex);
			
			return img;
		}
		
		public static function fromSWC(swcObject : flash.display.MovieClip, w : int , h : int = 0) : Image {
			if (h == 0) h = w;
			Functions.resizeDisplayObject(swcObject, w, h);
			var mat:Matrix=new Matrix();
			mat.scale(swcObject.scaleX,swcObject.scaleY);
			var bd:BitmapData = new BitmapData(swcObject.width, swcObject.height, true, 0xff0000);
			bd.draw(swcObject, mat);
			return new Image(Texture.fromBitmapData(bd));
		}
	}
}