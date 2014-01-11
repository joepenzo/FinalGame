package objects
{
	import citrus.objects.Box2DPhysicsObject;
	
	import flash.geom.Point;
	
	
	public class ExBox2DPhysicsObject extends Box2DPhysicsObject
	{
		
		private var _tile : Point;
		private var _currentColor : uint;
		private var _currentWidth : uint;
		private var _currentHeight : uint;
		private var _currentShape : String;
		
		public function ExBox2DPhysicsObject(name:String, params:Object=null, tile : Point = null)
		{
			super(name, params);
			_tile = tile;
			_currentWidth = width;
			_currentHeight = height;
		}


		public function get currentWidth():uint
		{
			return _currentWidth;
		}

		public function set currentWidth(value:uint):void
		{
			_currentWidth = value;
		}

		public function get currentHeight():uint
		{
			return _currentHeight;
		}

		public function set currentHeight(value:uint):void
		{
			_currentHeight = value;
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