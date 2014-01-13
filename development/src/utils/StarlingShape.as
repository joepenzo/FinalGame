package utils
{
	import data.consts.Shapes;
	
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
		
		public static function Ellipse(radiusW : int, radiusH : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawEllipse(radiusW/2,radiusH/2,radiusW, radiusH*2);
			shape.graphics.endFill();
			
			return shape;
		}
		
		public static function Triangle(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
		
			shape.graphics.moveTo(width/2, 0);
			shape.graphics.lineTo(width, height);
			shape.graphics.lineTo(0, height);
			shape.graphics.lineTo(width/2,0);
			
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
		
			if (type == Shapes.TRIANGLE) {
				var triangle: Shape = Triangle(w/2, h, color);
				triangle.x = 0;
				shape.addChild(triangle);
				
				triangle = Triangle(w/2, h, color);			
				triangle.x = w/2;
				shape.addChild(triangle);
			} 
			else if (type == Shapes.CIRCLE) {
				var circle: Shape = Ellipse(w/2, h/2, color);
				circle.x = 0;
				shape.addChild(circle);
				
				circle = Ellipse(w/2, h/2, color);			
				circle.x = w/2;
				shape.addChild(circle);
			}
			else if (type == Shapes.HEXAGON) {
				var hexagon: Shape = polygon(w/2, 6, color);
				hexagon.x = 0;
				shape.addChild(hexagon);
				
				hexagon = polygon(w/2, 6, color);			
				hexagon.x = w/2;
				shape.addChild(hexagon);
				
				shape.height = h;
			}  
			else if (type == Shapes.RECTANGLE) {
				var rect: Shape = Rectangle(w, h, color);
				rect.x = 0;
				shape.addChild(rect);
			}  
			
			return shape;
		}
		
		
		
	}
}