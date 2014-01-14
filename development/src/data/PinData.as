package data
{
	
	import data.consts.Actions;
	import data.consts.Pin;
	import data.types.SoundRange;
	import data.types.ValueRange;
	
	import flash.utils.Dictionary;
	import flash.geom.Point;

	public class PinData extends Object
	{
		
		/***************************************\
		**									   **
		**   Add all the pins u want to use!   **
		**	   		  In the Arrays			   **
		\****************************************/
	
		private var _usedAnalogPins:Array = [
			Pin.A_AUDIO_STARTFREQUENCY,
			Pin.A_AUDIO_ENDFREQUENCY,
			Pin.A_AUDIO_SLIDE,
			Pin.A_AUDIO_DURATION,
			
			Pin.A_RED,
			Pin.A_GREEN,
			Pin.A_BLUE,
			
			Pin.A_GRAVITY,
			Pin.A_ZOOM,
			
			Pin.A_HERO_LIVES,
			Pin.A_HERO_SPEED,
			Pin.A_HERO_SIZE,
			
			Pin.A_PERCANTAGE_ENEMY,
			Pin.A_PERCANTAGE_TRAP,
			Pin.A_PERCANTAGE_LIVE,
			Pin.A_PERCANTAGE_COIN,
			Pin.A_PERCANTAGE_MOVINGPLAT,
			Pin.A_PERCANTAGE_TRAMPOLINE,
			
			Pin.A_ENEMY_SPEED,
			Pin.A_TRAP_HEIGT,
			Pin.A_MOVINGPLAT_SPEED,
			Pin.A_TRAMPOLINE_BOOST
		];
		
		private var _usedDigitalPins:Array = [
			Pin.LEFT,
			Pin.RIGHT,
			Pin.JUMP,
			Pin.SHOOT,
			
			Pin.SHOOTING_ON,
			Pin.SHOOTING_OFF,
			
			Pin.LEVEL_MARIO,
			Pin.LEVEL_CAVE,
			
			Pin.CURRENT_COLOROBJ_BG,
			Pin.CURRENT_COLOROBJ_PLAT,
			Pin.CURRENT_COLOROBJ_MOVINGPLAT,
			Pin.CURRENT_COLOROBJ_TRAMPOLINE,
			Pin.CURRENT_COLOROBJ_EMENIES,
			Pin.CURRENT_COLOROBJ_TRAPS,
			Pin.CURRENT_COLOROBJ_LIVES,
			Pin.CURRENT_COLOROBJ_COINS,
			Pin.CURRENT_COLOROBJ_BULLETS,
			Pin.CURRENT_COLOROBJ_HERO,
			
			Pin.SHAPE_RECT,
			Pin.SHAPE_HEX,
			Pin.SHAPE_TRIANGLE,
			Pin.SHAPE_CIRClE,
			
			Pin.SOUND_COIN,
			Pin.SOUND_LIFE,
			Pin.SOUND_SHOOT,
			Pin.SOUND_HIT,
			Pin.SOUND_JUMP,
			
			Pin.JUMP_SINGLE,
			Pin.JUMP_DOUBLE,
			Pin.JUMP_UNLIMITED,
			Pin.JUMP_JETPACK,
			
			Pin.GOAL_KILL_ENEMIES,
			Pin.GOAL_COLLECT_COINS,
			Pin.GOAL_FINISH,
			Pin.GOAL_NOGOAL
		];
		
		private var _prevAnalogReads:Dictionary = new Dictionary();
		private var _lastAnalogReads:Dictionary = new Dictionary();
		
		
		
		private var AUDIO_STARTFREQUENCY_VAL:Number;
		private var AUDIO_ENDFREQUENCY_VAL:Number;
		private var AUDIO_SLIDE_VAL:Number;
		private var AUDIO_DURATION_VAL:Number;
		
		private var RED_VAL:Number;
		private var GREEN_VAL:Number;
		private var BLUE_VAL:Number;

		private var GRAV_VAL:Number;
		private var ZOOM_VAL:Number;
		
		private var HEROSIZE_VAL:Number;
		private var HEROLIVES_VAL:Number;
		private var HEROSPEED_VAL:Number;
		
		private var TRAP_PER:int;
		private var LIVE_PER:int;
		private var COIN_PER:int;
		private var ENEMY_PER:int;
		private var TRAMPS_PER:int;
		private var MOVINGPLATS_PER:int;
		
		private var ENEMY_SPEED_VAL:int;
		private var TRAP_HEIGHT_VAL:int;
		private var MOVINGPLAT_SPEED_VAL:int;
		private var TRAMP_BOOST_VAL:int;
		
		
		
		private var _analogVals:Dictionary = new Dictionary();
		private var _analogMinMaxMapVals:Dictionary = new Dictionary();
		private var _actionPins:Dictionary = new Dictionary();
		private var _intervals : Dictionary = new Dictionary();
		public function PinData() 	{
			
			for each (var pin : int in _usedAnalogPins) {
				_prevAnalogReads[pin] = "empty";
				_intervals[pin] = new Number();
			}
			
			// ANALOG STUFF DOWN HERE
			_analogVals[Pin.A_AUDIO_STARTFREQUENCY] = AUDIO_STARTFREQUENCY_VAL;
			_analogVals[Pin.A_AUDIO_ENDFREQUENCY] = AUDIO_ENDFREQUENCY_VAL;
			_analogVals[Pin.A_AUDIO_SLIDE] = AUDIO_SLIDE_VAL;
			_analogVals[Pin.A_AUDIO_DURATION] = AUDIO_DURATION_VAL;
			
			_analogVals[Pin.A_RED] = RED_VAL;
			_analogVals[Pin.A_GREEN] = GREEN_VAL;
			_analogVals[Pin.A_BLUE] = BLUE_VAL;
			
			_analogVals[Pin.A_GRAVITY] = GRAV_VAL;
			_analogVals[Pin.A_ZOOM] = ZOOM_VAL;
			
			_analogVals[Pin.A_HERO_LIVES] = HEROLIVES_VAL;
			_analogVals[Pin.A_HERO_SPEED] = HEROSPEED_VAL;
			_analogVals[Pin.A_HERO_SIZE] = HEROSIZE_VAL;
			
			_analogVals[Pin.A_PERCANTAGE_ENEMY] = ENEMY_PER;
			_analogVals[Pin.A_PERCANTAGE_TRAP] = TRAP_PER;
			_analogVals[Pin.A_PERCANTAGE_LIVE] = LIVE_PER;
			_analogVals[Pin.A_PERCANTAGE_COIN] = COIN_PER;
			_analogVals[Pin.A_PERCANTAGE_MOVINGPLAT] = MOVINGPLATS_PER;
			_analogVals[Pin.A_PERCANTAGE_TRAMPOLINE] = TRAMPS_PER;
			
			_analogVals[Pin.A_ENEMY_SPEED] = ENEMY_SPEED_VAL;
			_analogVals[Pin.A_TRAP_HEIGT] = TRAP_HEIGHT_VAL;
			_analogVals[Pin.A_MOVINGPLAT_SPEED] = MOVINGPLAT_SPEED_VAL;
			_analogVals[Pin.A_TRAMPOLINE_BOOST] = TRAMP_BOOST_VAL;
			
			//----			
			
			_actionPins[Pin.A_AUDIO_STARTFREQUENCY] = Actions.AUDIO_STARTFREQUENCY;
			_actionPins[Pin.A_AUDIO_ENDFREQUENCY] =  Actions.AUDIO_ENDFREQUENCY;
			_actionPins[Pin.A_AUDIO_SLIDE] =  Actions.AUDIO_SLIDE;
			_actionPins[Pin.A_AUDIO_DURATION] =  Actions.AUDIO_DURATION;
			
			_actionPins[Pin.A_RED] = Actions.VALUE_RED;
			_actionPins[Pin.A_GREEN] = Actions.VALUE_GREEN;
			_actionPins[Pin.A_BLUE] = Actions.VALUE_BLUE;
			
			_actionPins[Pin.A_GRAVITY] = Actions.VALUE_GRAVITY;
			_actionPins[Pin.A_ZOOM] = Actions.VALUE_ZOOM;
			
			_actionPins[Pin.A_HERO_LIVES] = Actions.HERO_LIVES;
			_actionPins[Pin.A_HERO_SPEED] = Actions.HERO_SPEED;
			_actionPins[Pin.A_HERO_SIZE] = Actions.HERO_SIZE;
			
			_actionPins[Pin.A_PERCANTAGE_ENEMY] = Actions.ENEMY_PERCANTAGE;
			_actionPins[Pin.A_PERCANTAGE_TRAP] = Actions.TRAP_PERCANTAGE;
			_actionPins[Pin.A_PERCANTAGE_LIVE] = Actions.LIVES_PERCANTAGE;
			_actionPins[Pin.A_PERCANTAGE_COIN] = Actions.COINS_PERCANTAGE;
			_actionPins[Pin.A_PERCANTAGE_MOVINGPLAT] = Actions.MOVINGPLAT_PERCANTAGE;
			_actionPins[Pin.A_PERCANTAGE_TRAMPOLINE] = Actions.TRAMPOLINE_PERCANTAGE;
			
			_actionPins[Pin.A_ENEMY_SPEED] = Actions.ENEMY_SPEED;
			_actionPins[Pin.A_TRAP_HEIGT] = Actions.TRAP_HEIGHT;
			_actionPins[Pin.A_MOVINGPLAT_SPEED] = Actions.MOVINGPLATFORM_SPEED;
			_actionPins[Pin.A_TRAMPOLINE_BOOST] = Actions.TRAMPOLINE_BOOST;
			
			//----
			
			_analogMinMaxMapVals[Pin.A_AUDIO_STARTFREQUENCY] = new Point(0, 1023);
			_analogMinMaxMapVals[Pin.A_AUDIO_ENDFREQUENCY] = new Point(0, 1023);
			_analogMinMaxMapVals[Pin.A_AUDIO_SLIDE] = new Point(0, 1023);
			_analogMinMaxMapVals[Pin.A_AUDIO_DURATION] = new Point(0, 1023);
			
			_analogMinMaxMapVals[Pin.A_RED] = ValueRange.RED;
			_analogMinMaxMapVals[Pin.A_GREEN] = ValueRange.GREEN;
			_analogMinMaxMapVals[Pin.A_BLUE] = ValueRange.BLUE;
			
			_analogMinMaxMapVals[Pin.A_GRAVITY] = ValueRange.GRAVITY;
			_analogMinMaxMapVals[Pin.A_ZOOM] = ValueRange.ZOOM;
			
			_analogMinMaxMapVals[Pin.A_HERO_LIVES] = ValueRange.HERO_LIVES;
			_analogMinMaxMapVals[Pin.A_HERO_SPEED] = ValueRange.HERO_SPEED;
			_analogMinMaxMapVals[Pin.A_HERO_SIZE] = ValueRange.HERO_SIZE;
			
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_ENEMY] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_TRAP] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_LIVE] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_COIN] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_MOVINGPLAT] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.A_PERCANTAGE_TRAMPOLINE] = ValueRange.PERCENTAGE;
			
			_analogMinMaxMapVals[Pin.A_ENEMY_SPEED] = ValueRange.ENEMYSPEED;
			_analogMinMaxMapVals[Pin.A_TRAP_HEIGT] = ValueRange.TRAP_HEIGHT;
			_analogMinMaxMapVals[Pin.A_MOVINGPLAT_SPEED] = ValueRange.MOVINGPLAT_SPEED;
			_analogMinMaxMapVals[Pin.A_TRAMPOLINE_BOOST] = ValueRange.TRAMP_BOOST;
			
			
			
			
			// DIGITAL STUFFINGS GOING ON DOWN HERE
			_actionPins[Pin.LEFT] = Actions.LEFT;
			_actionPins[Pin.RIGHT] = Actions.RIGHT;
			_actionPins[Pin.JUMP] = Actions.JUMP;
			_actionPins[Pin.SHOOT] = Actions.SHOOT;
			
			_actionPins[Pin.SHOOTING_ON] = Actions.HERO_SHOOT_ON;
			_actionPins[Pin.SHOOTING_OFF] = Actions.HERO_SHOOT_OFF;
			
			_actionPins[Pin.LEVEL_MARIO] = Actions.CHANGE_LVL_MARIO;
			_actionPins[Pin.LEVEL_CAVE] = Actions.CHANGE_LVL_CAVE;
			
			_actionPins[Pin.CURRENT_COLOROBJ_BG] = Actions.SELECTED_CURRENTSTYLING_BG;
			_actionPins[Pin.CURRENT_COLOROBJ_PLAT] = Actions.SELECTED_CURRENTSTYLING_PLAT;
			_actionPins[Pin.CURRENT_COLOROBJ_MOVINGPLAT] = Actions.SELECTED_CURRENTSTYLING_MOVINGPLATS;
			_actionPins[Pin.CURRENT_COLOROBJ_TRAMPOLINE] = Actions.SELECTED_CURRENTSTYLING_TRAMPOLINE;
			_actionPins[Pin.CURRENT_COLOROBJ_EMENIES] = Actions.SELECTED_CURRENTSTYLING_ENEMIES;
			_actionPins[Pin.CURRENT_COLOROBJ_TRAPS] = Actions.SELECTED_CURRENTSTYLING_TRAPS;
			_actionPins[Pin.CURRENT_COLOROBJ_LIVES] = Actions.SELECTED_CURRENTSTYLING_LIVES;
			_actionPins[Pin.CURRENT_COLOROBJ_COINS] = Actions.SELECTED_CURRENTSTYLING_COINS;
			_actionPins[Pin.CURRENT_COLOROBJ_BULLETS] = Actions.SELECTED_CURRENTSTYLING_BULLETS;
			_actionPins[Pin.CURRENT_COLOROBJ_HERO] = Actions.SELECTED_CURRENTSTYLING_HERO;
			
			_actionPins[Pin.SHAPE_RECT] = Actions.CHANGE_SHAPE_RECT;
			_actionPins[Pin.SHAPE_HEX] = Actions.CHANGE_SHAPE_HEXAGON;
			_actionPins[Pin.SHAPE_TRIANGLE] = Actions.CHANGE_SHAPE_TRIANGLE;
			_actionPins[Pin.SHAPE_CIRClE] = Actions.CHANGE_SHAPE_CIRCLE;
			
			_actionPins[Pin.SOUND_COIN] = Actions.SELECTED_CURRENTAUDIO_COINS;
			_actionPins[Pin.SOUND_LIFE] = Actions.SELECTED_CURRENTAUDIO_LIFES;
			_actionPins[Pin.SOUND_SHOOT] = Actions.SELECTED_CURRENTAUDIO_SHOOT;
			_actionPins[Pin.SOUND_HIT] = Actions.SELECTED_CURRENTAUDIO_HIT;
			_actionPins[Pin.SOUND_JUMP] = Actions.SELECTED_CURRENTAUDIO_JUMP;
			
			_actionPins[Pin.JUMP_SINGLE] = Actions.CHANGE_JUMP_SINGLE;
			_actionPins[Pin.JUMP_DOUBLE] = Actions.CHANGE_JUMP_DOUBLE;
			_actionPins[Pin.JUMP_UNLIMITED] = Actions.CHANGE_JUMP_UNLIMETID;
			_actionPins[Pin.JUMP_JETPACK] = Actions.CHANGE_JUMP_JETPACK;
			
			_actionPins[Pin.GOAL_KILL_ENEMIES] = Actions.GOAL_KILL;
			_actionPins[Pin.GOAL_COLLECT_COINS] = Actions.GOAL_COLLECT;
			_actionPins[Pin.GOAL_FINISH] = Actions.GOAL_A_TO_B;
			_actionPins[Pin.GOAL_NOGOAL] = Actions.GOAL_NO_GOAL;
			
		}
		
		
		public function get intervals():Dictionary
		{
			return _intervals;
		}

		public function set intervals(value:Dictionary):void
		{
			_intervals = value;
		}

		public function get prevAnalogReads():Dictionary
		{
			return _prevAnalogReads;
		}

		public function get lastAnalogReads():Dictionary
		{
			return _lastAnalogReads;
		}

		public function get analogMinMaxMapVals():Dictionary {
			return _analogMinMaxMapVals;
		}
		
		public function get actionPins():Dictionary {
			return _actionPins;
		}
		
		public function get analogVals():Dictionary {
			return _analogVals;
		}
		
		
		public function get usedAnalogPins():Array {
			return _usedAnalogPins;
		}

		public function get usedDigitalPins():Array {
			return _usedDigitalPins;
		}
		
		
	}
}


