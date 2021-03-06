package data
{
	import Box2D.Common.Math.b2Vec2;
	
	import citrus.utils.AGameData;
	import audio.SynthSounds;
	
	public class GameData extends AGameData
	{
		
		
		protected var _synthSounds : SynthSounds;

		protected var _currentLevelColorType : String = "";
		protected var _currentLevelType : String = "";
		protected var _currentGravity : b2Vec2;
		
		protected var _currentAudio : String = "";
		protected var _currentStyling : String = "";
		protected var _currentShape:String = "";
		
		protected var _bulletColor:uint;
		protected var _bulletShape:String = "";
		
		protected var _coinColor:uint;
		protected var _coinShape:String = "";

		protected var _lifeColor:uint;
		protected var _lifeShape:String = "";
		
		protected var _trapColor:uint;
		protected var _trapShape:String = "";
		
		protected var _enemyColor:uint;
		protected var _enemyShape:String = "";

		protected var _trampolineColor:uint;
		
		protected var _movingPlatColor:uint;
		
		protected var _movingPlatformSpeed : Number = 3;
		protected var _trampolineBoost : Number = 5;
		
		protected var _goal:String = "";
		protected var _enemiesKilled:int;
		protected var _totalEnemiesInState:int;
		
		protected var _levelColor : uint;
		
		protected var _red : int = 0;
		protected var _green : int = 0;
		protected var _blue : int = 0;
		
		protected var _enemyPercentage : int = 0;
		protected var _trapPercantage : int = 0;
		protected var _livesPercantage : int = 0;
		protected var _coinsPercantage : int = 0;
		protected var _trampolinePercantage : int = 0;
		protected var _movingPlatsPercantage : int = 0;

		
		
		
		
		public function GameData() {
			super();
		}
		
	
		public function get movingPlatColor():uint
		{
			return _movingPlatColor;
		}

		public function set movingPlatColor(value:uint):void
		{
			_movingPlatColor = value;
		}

		public function get trampolineColor():uint
		{
			return _trampolineColor;
		}

		public function set trampolineColor(value:uint):void
		{
			_trampolineColor = value;
		}

		public function get trapColor():uint
		{
			return _trapColor;
		}

		public function set trapColor(value:uint):void
		{
			_trapColor = value;
		}

		public function get trapShape():String
		{
			return _trapShape;
		}

		public function set trapShape(value:String):void
		{
			_trapShape = value;
		}

		public function get enemyShape():String
		{
			return _enemyShape;
		}

		public function set enemyShape(value:String):void
		{
			_enemyShape = value;
		}

		public function get enemyColor():uint
		{
			return _enemyColor;
		}

		public function set enemyColor(value:uint):void
		{
			_enemyColor = value;
		}

		public function get trampolinePercantage():int
		{
			return _trampolinePercantage;
		}

		public function set trampolinePercantage(value:int):void
		{
			_trampolinePercantage = value;
		}

		public function get currentAudio():String
		{
			return _currentAudio;
		}

		public function set currentAudio(value:String):void
		{
			_currentAudio = value;
		}

		public function get coinColor():uint
		{
			return _coinColor;
		}

		public function set coinColor(value:uint):void
		{
			_coinColor = value;
		}

		public function get coinShape():String
		{
			return _coinShape;
		}

		public function set coinShape(value:String):void
		{
			_coinShape = value;
		}

		public function get lifeShape():String
		{
			return _lifeShape;
		}

		public function set lifeShape(value:String):void
		{
			_lifeShape = value;
		}

		public function get lifeColor():uint
		{
			return _lifeColor;
		}

		public function set lifeColor(value:uint):void
		{
			_lifeColor = value;
		}

		public function get bulletShape():String
		{
			return _bulletShape;
		}

		public function set bulletShape(value:String):void
		{
			_bulletShape = value;
		}

		public function get bulletColor():uint
		{
			return _bulletColor;
		}

		public function set bulletColor(value:uint):void
		{
			_bulletColor = value;
		}

		public function get trampolineBoost():Number
		{
			return _trampolineBoost;
		}

		public function set trampolineBoost(value:Number):void
		{
			_trampolineBoost = value;
		}

		public function get movingPlatformSpeed():Number
		{
			return _movingPlatformSpeed;
		}

		public function set movingPlatformSpeed(value:Number):void
		{
			_movingPlatformSpeed = value;
		}

		public function get movingPlatsPercantage():int
		{
			return _movingPlatsPercantage;
		}

		public function set movingPlatsPercantage(value:int):void
		{
			_movingPlatsPercantage = value;
		}

		public function get coinsPercantage():int
		{
			return _coinsPercantage;
		}

		public function set coinsPercantage(value:int):void
		{
			_coinsPercantage = value;
		}

		public function get livesPercantage():int
		{
			return _livesPercantage;
		}

		public function set livesPercantage(value:int):void
		{
			_livesPercantage = value;
		}

		override public function set lives(lives:int):void {
			_lives = lives;
			if (_lives < 0) {
				_lives = 0;
				return;
			}
			dataChanged.dispatch("lives", _lives);
		}

		public function get trapPercantage():int
		{
			return _trapPercantage;
		}

		public function set trapPercantage(value:int):void
		{
			_trapPercantage = value;
		}

		public function get totalEnemies():int
		{
			return _totalEnemiesInState;
		}

		public function set totalEnemies(value:int):void
		{
			_totalEnemiesInState = value;
			dataChanged.dispatch("totalEnemiesInState", _totalEnemiesInState);
		}

		public function get enemiesKilled():int
		{
			return _enemiesKilled;
		}

		public function set enemiesKilled(value:int):void
		{
			_enemiesKilled = value;
			dataChanged.dispatch("totalEnemiesKilled", _enemiesKilled);	
		}

		public function get goal():String
		{
			return _goal;
		}

		public function set goal(value:String):void
		{
			_goal = value;
		}

		public function get enemyPercentage():int
		{
			return _enemyPercentage;
		}

		public function set enemyPercentage(value:int):void
		{
			_enemyPercentage = value;
		}

		public function get currentShape():String
		{
			return _currentShape;
		}

		public function set currentShape(value:String):void
		{
			_currentShape = value;
		}

		public function get levelColor():uint
		{
			return _levelColor;
		}

		public function set levelColor(value:uint):void
		{
			_levelColor = value;
		}

		public function get currentStyling():String
		{
			return _currentStyling;
		}

		public function set currentStyling(value:String):void
		{
			_currentStyling = value;
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
