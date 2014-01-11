package objects
{
	import citrus.objects.CitrusSprite;
	
	public class HeroView extends CitrusSprite
	{
		private var _currentColor : uint;
		private var _currentShape : String;
		private var _heroW : int;
		private var _heroH : int;
		
		public function HeroView(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		public function get heroW():int
		{
			return _heroW;
		}

		public function set heroW(value:int):void
		{
			_heroW = value;
		}

		public function get heroH():int
		{
			return _heroH;
		}

		public function set heroH(value:int):void
		{
			_heroH = value;
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