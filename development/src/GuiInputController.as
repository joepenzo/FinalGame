package
{
	import citrus.input.InputController;
	import flash.utils.*;
	import data.consts.Actions;
	import citrus.input.InputAction;
	
	public class GuiInputController extends InputController
	{
		
		private static const INPUT_DELAY:int = 100;
		private var _intervals : Dictionary = new Dictionary();
			
		public function GuiInputController(name:String, params:Object=null) {
			_intervals[Actions.VALUE_ZOOM] = new Number();
			_intervals[Actions.VALUE_GRAVITY] = new Number();
			_intervals[Actions.SELECTED_COLOROBJ_PLAT] = new Number();
			_intervals[Actions.SELECTED_COLOROBJ_HERO] = new Number();
			_intervals[Actions.SELECTED_COLOROBJ_BG] = new Number();
			_intervals[Actions.VALUE_RED] = new Number();
			_intervals[Actions.VALUE_GREEN] = new Number();
			_intervals[Actions.VALUE_BLUE] = new Number();
			_intervals[Actions.CHANGE_SHAPE_RECT] = new Number();
			_intervals[Actions.CHANGE_SHAPE_TRIANGLE] = new Number();
			_intervals[Actions.CHANGE_SHAPE_HEXAGON] = new Number();
			_intervals[Actions.CHANGE_SHAPE_CIRCLE] = new Number();
			_intervals[Actions.HERO_SIZE] = new Number();
			_intervals[Actions.ENEMY_PERCANTAGE] = new Number();
			
			super(name, params);
		
		}
		
		public function triggerChange(action : String, value : Number) : void {
			triggerCHANGE(action, value, "ON");
		}
		
		public function triggerOff(action : String, value : Number) : void {
			triggerOFF(action, value, "OFF");
		}
		
		public function triggerOnce(action : String, value : Number) : void {
			triggerONCE(action, value, "ON");
			
		}
		

		
		public function triggerUntilRelease(actionName : String, value : Number) : void {
			
			triggerCHANGE(actionName, value, "ON");

			var action :InputAction = _ce.input.getAction(actionName) as InputAction;
			
			clearTimeout(_intervals[actionName]);
			_intervals[actionName] = setTimeout(myDelayedFunction, INPUT_DELAY, action, value);
			
			function myDelayedFunction(action : InputAction, value : Number):void { // Kills the input after no change
				if (action && action.message == "ON") triggerOFF(actionName, value, "OFF");
			}
			
			
		}
		
		
		
		
	}
}