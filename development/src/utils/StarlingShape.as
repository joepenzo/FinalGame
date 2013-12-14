package utils
{
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Shape;

	public class StarlingShape
	{
		
		public static function Rectangle(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0,width, height);
			shape.graphics.endFill();
			return shape;
		}
		
		
		public static function Circle(radius : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			radius = radius + 1; // FIX
			
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawCircle(radius/2,radius/4,radius/2);
			shape.graphics.endFill();
			
			return shape;
		}
		
		public static function Triangle(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
		
			shape.graphics.moveTo(height/2, 0);
			shape.graphics.lineTo(height, height);
			shape.graphics.lineTo(0, height);
			shape.graphics.lineTo(height/2,0);
			
			shape.graphics.endFill();
			
			return shape;
		}
		
		
		public static function polygon(radius:Number, sides:uint, color : uint = 0x505050, angle:Number=0): Shape {
			radius = radius/2 + 1; // FIX
			var x : int = radius;  // FIX
			var y : int = radius;  // FIX
			
			// check that sides is sufficient to build
			if (sides <= 2) {
				throw ArgumentError("StarlingShape.drawPolygon() - parameter 'sides' needs to be atleast 3");
				return;
			}
			if (sides > 2) {
				var shape: Shape = new Shape();
				shape.graphics.beginFill(color);
				// init vars
				var step:Number, start:Number, n:Number, dx:Number, dy:Number;
				// calculate span of sides
				step = (Math.PI * 2) / sides;
				// calculate starting angle in radians
				start = (angle / 180) * Math.PI;
				shape.graphics.moveTo(x + (Math.cos(start) * radius), y - (Math.sin(start) * radius));
				// draw the polygon
				for (n = 1; n <= sides; ++n)
				{
					dx = x + Math.cos(start + (step * n)) * radius;
					dy = y - Math.sin(start + (step * n)) * radius;
					shape.graphics.lineTo(dx, dy);
				}
			}
			
			return shape;
		}
		
		public static function CombinedShape(type:String, w:int, h:int, color:uint):Shape {
			var shape : Shape = new Shape(); 
		
			if (type == "Triangle") {
				var triangle: Shape = Triangle(w, h, color);
				triangle.x = 0;
				shape.addChild(triangle);
				
				triangle = Triangle(w, h, color);			
				triangle.x = w/2;
				shape.addChild(triangle);
			}
			
			return shape;
		}
		
		
		
	}
}