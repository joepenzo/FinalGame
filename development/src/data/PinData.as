package data
{
	
	import data.types.Actions;
	import data.types.Pin;
	import data.types.SoundRange;
	import data.types.ValueRange;
	
	import flash.utils.Dictionary;

	public class PinData extends Object
	{
		
		/***************************************\
		**									   **
		**   Add all the pins u want to use!   **
		**	   		  In the Arrays			   **
		\****************************************/
	
		private var _usedAnalogPins:Array = [
			Pin.PERCANTAGE_ENEMY,Pin.PERCANTAGE_LIVE, Pin.PERCANTAGE_TRAP, 
			Pin.A_GRAVITY, Pin.A_ZOOM,
			Pin.A_RED,Pin.A_GREEN,Pin.A_BLUE, 
			Pin.A_HERO_SIZE,
		];
		
		private var _usedDigitalPins:Array = [
			Pin.CURRENT_COLOROBJ_HERO, Pin.CURRENT_COLOROBJ_BG, Pin.CURRENT_COLOROBJ_PLAT, Pin.CURRENT_COLOROBJ_EMENIES, Pin.CURRENT_COLOROBJ_TRAPS,
			Pin.LEFT, Pin.RIGHT, Pin.JUMP, Pin.SHOOT, 
			Pin.LEVEL_MARIO, Pin.LEVEL_CAVE
		];
		
		private var _prevAnalogReads:Dictionary = new Dictionary();
		private var _lastAnalogReads:Dictionary = new Dictionary();
		
		
		
		private var AUDIO_SQUAREDUTY_VAL:Number;
		private var AUDIO_STARTFREQUENCY_VAL:Number;
		private var AUDIO_SLIDE_VAL:Number;
		
		private var GRAV_VAL:Number;
		private var ZOOM_VAL:Number;
		private var HEROSIZE_VAL:Number;
		private var RED_VAL:Number;
		private var GREEN_VAL:Number;
		private var BLUE_VAL:Number;
		
		
		private var TRAP_PER:int;
		private var LIVE_PER:int;
		private var ENEMY_PER:int;
		
		
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
			_analogVals[Pin.A_AUDIO_SQUAREDUTY] = AUDIO_SQUAREDUTY_VAL;
			_analogVals[Pin.A_AUDIO_STARTFREQUENCY] = AUDIO_STARTFREQUENCY_VAL;
			_analogVals[Pin.A_AUDIO_SLIDE] = AUDIO_SLIDE_VAL;
			_analogVals[Pin.A_GRAVITY] = GRAV_VAL;
			_analogVals[Pin.A_RED] = RED_VAL;
			_analogVals[Pin.A_GREEN] = GREEN_VAL;
			_analogVals[Pin.A_BLUE] = BLUE_VAL;
			_analogVals[Pin.A_HERO_SIZE] = HEROSIZE_VAL;
			_analogVals[Pin.A_ZOOM] = ZOOM_VAL;
			_analogVals[Pin.PERCANTAGE_ENEMY] = ENEMY_PER;
			_analogVals[Pin.PERCANTAGE_LIVE] = LIVE_PER;
			_analogVals[Pin.PERCANTAGE_TRAP] = TRAP_PER;
			
			
			_actionPins[Pin.A_AUDIO_SQUAREDUTY] = Actions.AUDIO_SQUAREDUTY;
			_actionPins[Pin.A_AUDIO_STARTFREQUENCY] = Actions.AUDIO_STARTFREQUENCY;
			_actionPins[Pin.A_AUDIO_SLIDE] = Actions.AUDIO_SLIDE;
			_actionPins[Pin.A_GRAVITY] = Actions.VALUE_GRAVITY;
			_actionPins[Pin.A_RED] = Actions.VALUE_RED;
			_actionPins[Pin.A_GREEN] = Actions.VALUE_GREEN;
			_actionPins[Pin.A_BLUE] = Actions.VALUE_BLUE;
			_actionPins[Pin.A_HERO_SIZE] = Actions.HERO_SIZE;
			_actionPins[Pin.A_ZOOM] = Actions.VALUE_ZOOM;
			_actionPins[Pin.PERCANTAGE_ENEMY] = Actions.ENEMY_PERCANTAGE;
			_actionPins[Pin.PERCANTAGE_LIVE] = Actions.LIVES_PERCANTAGE;
			_actionPins[Pin.PERCANTAGE_TRAP] = Actions.TRAP_PERCANTAGE;
			
			_analogMinMaxMapVals[Pin.A_AUDIO_SQUAREDUTY] = SoundRange.JUMP_SQUAREDUTY;
			_analogMinMaxMapVals[Pin.A_AUDIO_STARTFREQUENCY] = SoundRange.JUMP_STARTFREQUENCY;
			_analogMinMaxMapVals[Pin.A_AUDIO_SLIDE] = SoundRange.JUMP_SLIDE;
			_analogMinMaxMapVals[Pin.A_GRAVITY] = ValueRange.GRAVITY;
			_analogMinMaxMapVals[Pin.A_RED] = ValueRange.RED;
			_analogMinMaxMapVals[Pin.A_GREEN] = ValueRange.GREEN;
			_analogMinMaxMapVals[Pin.A_BLUE] = ValueRange.BLUE;
			_analogMinMaxMapVals[Pin.A_HERO_SIZE] = ValueRange.HERO_SIZE;
			_analogMinMaxMapVals[Pin.A_ZOOM] = ValueRange.ZOOM;
			_analogMinMaxMapVals[Pin.PERCANTAGE_ENEMY] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.PERCANTAGE_LIVE] = ValueRange.PERCENTAGE;
			_analogMinMaxMapVals[Pin.PERCANTAGE_TRAP] = ValueRange.PERCENTAGE;
			
			
			// DIGITAL STUFFINGS GOING ON DOWN HERE
			_actionPins[Pin.LEFT] = Actions.LEFT;
			_actionPins[Pin.RIGHT] = Actions.RIGHT;
			_actionPins[Pin.JUMP] = Actions.JUMP;
			_actionPins[Pin.SHOOT] = Actions.SHOOT;
			
			
			_actionPins[Pin.LEVEL_MARIO] = Actions.CHANGE_LVL_MARIO;
			_actionPins[Pin.LEVEL_CAVE] = Actions.CHANGE_LVL_CAVE;
			
			_actionPins[Pin.CURRENT_COLOROBJ_BG] = Actions.SELECTED_COLOROBJ_BG;
			_actionPins[Pin.CURRENT_COLOROBJ_HERO] = Actions.SELECTED_COLOROBJ_HERO;
			_actionPins[Pin.CURRENT_COLOROBJ_PLAT] = Actions.SELECTED_COLOROBJ_PLAT;
			_actionPins[Pin.CURRENT_COLOROBJ_EMENIES] = Actions.SELECTED_COLOROBJ_ENEMIES;
			_actionPins[Pin.CURRENT_COLOROBJ_TRAPS] = Actions.SELECTED_COLOROBJ_TRAPS;
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


