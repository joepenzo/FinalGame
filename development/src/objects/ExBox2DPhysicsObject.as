package objects
{
	import citrus.objects.Box2DPhysicsObject;
	
	public class ExBox2DPhysicsObject extends Box2DPhysicsObject
	{
		
		private var _currentColor : uint;
		private var _currentShape : String;
		
		public function ExBox2DPhysicsObject(name:String, params:Object=null)
		{
			super(name, params);
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