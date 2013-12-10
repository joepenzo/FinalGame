package
{
	import data.Actions;
	import data.Pin;
	import data.SoundParams;
	import data.ValueParams;
	
	import flash.utils.Dictionary;

	public class PinData extends Object
	{
		
		/***************************************\
		**									   **
		**   Add all the pins u want to use!   **
		**	   		  In the Arrays			   **
		\****************************************/
	
//		private var _usedAnalogPins:Array = [Pin.A_AUDIO_SQUAREDUTY,Pin.A_AUDIO_STARTFREQUENCY, Pin.A_AUDIO_SLIDE];
		private var _usedAnalogPins:Array = [Pin.A_AUDIO_SQUAREDUTY,Pin.A_AUDIO_STARTFREQUENCY, Pin.A_AUDIO_SLIDE, Pin.A_GRAVITY, Pin.A_RED,Pin.A_GREEN,Pin.A_BLUE, Pin.A_HERO_SIZE, Pin.A_ZOOM];
		private var _usedDigitalPins:Array = [Pin.CURRENT_COLOROBJ_HERO, Pin.CURRENT_COLOROBJ_BG, Pin.CURRENT_COLOROBJ_PLAT, Pin.LEFT, Pin.RIGHT, Pin.JUMP, Pin.LEVEL_MARIO, Pin.LEVEL_CAVE];
		
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
			
			_actionPins[Pin.A_AUDIO_SQUAREDUTY] = Actions.AUDIO_SQUAREDUTY;
			_actionPins[Pin.A_AUDIO_STARTFREQUENCY] = Actions.AUDIO_STARTFREQUENCY;
			_actionPins[Pin.A_AUDIO_SLIDE] = Actions.AUDIO_SLIDE;
			_actionPins[Pin.A_GRAVITY] = Actions.VALUE_GRAVITY;
			_actionPins[Pin.A_RED] = Actions.VALUE_RED;
			_actionPins[Pin.A_GREEN] = Actions.VALUE_GREEN;
			_actionPins[Pin.A_BLUE] = Actions.VALUE_BLUE;
			_actionPins[Pin.A_HERO_SIZE] = Actions.HERO_SIZE;
			_actionPins[Pin.A_ZOOM] = Actions.VALUE_ZOOM;
			
			_analogMinMaxMapVals[Pin.A_AUDIO_SQUAREDUTY] = SoundParams.JUMP_SQUAREDUTY;
			_analogMinMaxMapVals[Pin.A_AUDIO_STARTFREQUENCY] = SoundParams.JUMP_STARTFREQUENCY;
			_analogMinMaxMapVals[Pin.A_AUDIO_SLIDE] = SoundParams.JUMP_SLIDE;
			_analogMinMaxMapVals[Pin.A_GRAVITY] = ValueParams.GRAVITY;
			_analogMinMaxMapVals[Pin.A_RED] = ValueParams.RED;
			_analogMinMaxMapVals[Pin.A_GREEN] = ValueParams.GREEN;
			_analogMinMaxMapVals[Pin.A_BLUE] = ValueParams.BLUE;
			_analogMinMaxMapVals[Pin.A_HERO_SIZE] = ValueParams.HERO_SIZE;
			_analogMinMaxMapVals[Pin.A_ZOOM] = ValueParams.ZOOM;
			
			
			// DIGITAL STUFFINGS GOING ON DOWN HERE
			_actionPins[Pin.LEFT] = Actions.LEFT;
			_actionPins[Pin.RIGHT] = Actions.RIGHT;
			_actionPins[Pin.JUMP] = Actions.JUMP;
			
			_actionPins[Pin.LEVEL_MARIO] = Actions.CHANGE_LVL_MARIO;
			_actionPins[Pin.LEVEL_CAVE] = Actions.CHANGE_LVL_CAVE;
			_actionPins[Pin.LEVEL_FLAT] = Actions.CHANGE_LVL_FLAT;
			
			_actionPins[Pin.CURRENT_COLOROBJ_BG] = Actions.SELECTED_COLOROBJ_BG;
			_actionPins[Pin.CURRENT_COLOROBJ_HERO] = Actions.SELECTED_COLOROBJ_HERO;
			_actionPins[Pin.CURRENT_COLOROBJ_PLAT] = Actions.SELECTED_COLOROBJ_PLAT;
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


