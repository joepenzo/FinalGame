package utils
{
	import starling.display.Shape;

	public class StarlingShape
	{
		
		public static function RectangleShape(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0,width, height);
			shape.graphics.endFill();
			
			return shape;
		}
		
		
		public static function CircleShape(radius : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawCircle(radius/2,radius/4,radius/2);
			shape.graphics.endFill();
			
			return shape;
		}
		
		
	}
}