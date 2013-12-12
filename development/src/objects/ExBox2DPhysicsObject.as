package objects
{
	import citrus.objects.Box2DPhysicsObject;
	import flash.geom.Point;
	
	public class ExBox2DPhysicsObject extends Box2DPhysicsObject
	{
		
		private var _tile : Point;
		private var _currentColor : uint;
		private var _currentShape : String;
		
		public function ExBox2DPhysicsObject(name:String, params:Object=null, tile : Point = null)
		{
			super(name, params);
			_tile = tile;
		}


		public function get tile():Point
		{
			return _tile;
		}

		public function set tile(value:Point):void
		{
			_tile = value;
		}

		public function get currentColor():uint
		{
			return _currentColor;
		}

		public function set currentColor(value:uint):void
		{
			_currentColor = value;
		}

		public function get currentShape():String
		{
			return _currentShape;
		}

		public function set currentShape(value:String):void
		{
			_currentShape = value;
		}

	}
}