package data
{
	import Box2D.Common.Math.b2Vec2;
	
	import citrus.utils.AGameData;
	
	public class GameData extends AGameData
	{
		
		
		protected var _synthSounds : SynthSounds;

		protected var _currentLevelColorType : String = "";
		protected var _currentLevelType : String = "";
		protected var _currentGravity : b2Vec2;
		
		protected var _currentColoring : String = "";

		protected var _levelColor : uint;
		
		protected var _red : int = 0;
		protected var _green : int = 0;
		protected var _blue : int = 0;
		
		public function GameData() {
			super();
		}

		public function get levelColor():uint
		{
			return _levelColor;
		}

		public function set levelColor(value:uint):void
		{
			_levelColor = value;
		}

		public function get currentColoring():String
		{
			return _currentColoring;
		}

		public function set currentColoring(value:String):void
		{
			_currentColoring = value;
		}

		public function get red():int
		{
			return _red;
		}

		public function set red(value:int):void
		{
			_red = value;
		}

		public function get green():int
		{
			return _green;
		}

		public function set green(value:int):void
		{
			_green = value;
		}

		public function get blue():int
		{
			return _blue;
		}

		public function set blue(value:int):void
		{
			_blue = value;
		}

		public function get synthSounds():SynthSounds
		{
			return _synthSounds;
		}

		public function set synthSounds(value:SynthSounds):void
		{
			_synthSounds = value;
		}

		public function get currentLevelType():String
		{
			return _currentLevelType;
		}

		public function set currentLevelType(value:String):void
		{
			_currentLevelType = value;
		}

		public function get currentLevelColorType():String
		{
			return _currentLevelColorType;
		}

		public function set currentLevelColorType(value:String):void
		{
			_currentLevelColorType = value;
		}

		public function get currentGravity():b2Vec2
		{
			return _currentGravity;
		}

		public function set currentGravity(value:b2Vec2):void
		{
			_currentGravity = value;
		}


	}
}
