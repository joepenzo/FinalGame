package
{
	import citrus.input.InputController;
	import flash.utils.*;
	import data.consts.Actions;
	import citrus.input.InputAction;
	
	public class GuiInputController extends InputController
	{
		
		private var _interval:uint = 0;
		public function GuiInputController(name:String, params:Object=null) {
			super(name, params);
		}
		
		public function triggerChange(action : String, value : Number) : void {
			triggerCHANGE(action, value, "ON");
		}
		
		public function triggerOff(action : String, value : Number) : void {
			triggerOFF(action, value, "OFF");
		}
		
		public function triggerOn(action : String) : void {
			triggerONCE(action, 1);
			
		}
		

		
		public function triggerUntilRelease(actionName : String, value : Number) : void {
			triggerCHANGE(actionName, value, "ON");
			
			var action :InputAction = _ce.input.getAction(actionName) as InputAction;
			clearTimeout(_interval);
			_interval = setTimeout(myDelayedFunction, 100, action, value);
			
			function myDelayedFunction(action : InputAction, value : Number):void { // Kills the input after no change
				if (action && action.message == "ON") triggerOFF(actionName, value, "OFF");
			}
//			
			
		}
		
		
		
		
	}
}