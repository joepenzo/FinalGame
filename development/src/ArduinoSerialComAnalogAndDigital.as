package
{
	
	import citrus.input.InputAction;
	import citrus.input.InputController;
	
	import com.quetwo.Arduino.ArduinoConnector;
	import com.quetwo.Arduino.ArduinoConnectorEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.*;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import utils.Functions;
	import data.PinData;
	
	public class ArduinoSerialComAnalogAndDigital extends InputController
	{ 
		
		private const ANALOG_MARING: int = 2;
		private var NO_CHANGE_DELAY:int = 100;
		
		
		private var _arduinoConnector:ArduinoConnector;
		private var pinData:PinData;
		
		public function ArduinoSerialComAnalogAndDigital(name:String, params:Object=null) {
			super(name, params);
			
			pinData = new PinData();
			
			_arduinoConnector = new ArduinoConnector();
			var comport:String = _arduinoConnector.getComPorts()[0].toString();
			_arduinoConnector.connect(comport,57600);		
			_arduinoConnector.addEventListener("socketData", onSocketData);
			
			_ce.stage.nativeWindow.addEventListener(Event.CLOSE, closeApp);
		}
		
		protected function closeApp(event:Event):void{
			_arduinoConnector.dispose();			
			
		}		
		
		public function sendString(value:String) : void {
			_arduinoConnector.writeString(value+"\n");
		}
		
		
		protected function onSocketData(event:ArduinoConnectorEvent):void{
			var recievedData : String = _arduinoConnector.readBytesAsString();
			
			var item:Array = recievedData.split(" ");
			for(var i in item) {
				item[i] = String(item[i]).charAt(0) + String(item[i]).substr(1, String(item[i]).length);
				var pinType : String = String(item[i]).charAt(0); // a = analog or d = digital
				var pinNumber : int = parseInt(String(item[i]).substr(1, String(item[i]).indexOf("v")-1));
				var value : int = parseInt(String(item[i]).substr(String(item[i]).indexOf("v")+1,String(item[i]).length));
				
				if (pinType == "a" || pinType == "d") {
					switch (pinType){
						case "a":
							if (pinData.usedAnalogPins.indexOf(pinNumber) != -1) handleAnalog(pinNumber, value);
							break;
						case "d":
							if (pinData.usedDigitalPins.indexOf(pinNumber) != -1) handleDigital(pinNumber, value);
							break;
					}
					
				}
			}
			
		}
		
		
		private function handleDigital(pin:int, value:int):void {
//			error(pin + " " + value);
			for each (var p:int in pinData.usedDigitalPins) {
				if (pin == p) {
					switch (value){
						case 1: // HIGH - on
							triggerON(pinData.actionPins[pin], 1);
							break;
						case 0: // LOW - off
							triggerOFF(pinData.actionPins[pin], 0);
							break;
					}					
				}
			}
		}
		
		
		private function handleAnalog(pin:int, value:int):void {
			
			// STOP AND SAVE READING IF IT IS THE FIRST READING
			if (pinData.prevAnalogReads[pin] == "empty") {
				pinData.prevAnalogReads[pin] =  value
				pinData.lastAnalogReads[pin] =  value
				//fatal('first reading ' + pin);
				return;
			} 
			
			// READ AND SEND
			for each (var p:int in pinData.usedAnalogPins) {
				if (pin == p && pinData.prevAnalogReads[p] != "empty") { // if not first time read - you knowwwwws
					
					pinData.analogVals[p] = Functions.map(value, 0, 1023, pinData.analogMinMaxMapVals[p].x,  pinData.analogMinMaxMapVals[p].y);
					pinData.lastAnalogReads[p] = value;
					var action :InputAction = _ce.input.getAction(pinData.actionPins[p]) as InputAction;
					
					if (value != pinData.prevAnalogReads[p] && value != 1023 || value != 0){
						triggerCHANGE(pinData.actionPins[p], pinData.analogVals[p], "ON");
						pinData.prevAnalogReads[p] = value;
												error("ON " + pin + " " + pinData.actionPins[p] + "  " + value + "  " + pinData.prevAnalogReads[p]);
						clearTimeout(pinData.intervals[p]);
						pinData.intervals[p] = setTimeout(myDelayedFunction, NO_CHANGE_DELAY, p);
						function myDelayedFunction(currentpin : int):void { // Kills the input after no change
							if (action && action.message == "ON") {
								triggerOFF(pinData.actionPins[currentpin], pinData.analogVals[currentpin], "OFF");
																fatal("OFF " + pinData.actionPins[currentpin] + "  " + value + "  " + pinData.prevAnalogReads[currentpin]);
							}
						}
						if (value == 1023 || value == 0 ) {
							triggerOFF(pinData.actionPins[p], pinData.analogVals[p], "OFF");
														notice("OFF " + pinData.actionPins[p] + "  " + value + "  " + pinData.prevAnalogReads[p]);
						}
					} else if (action && action.message == "ON") {
						triggerOFF(pinData.actionPins[p], pinData.analogVals[p], "OFF");
												debug("OFF " + pinData.actionPins[p] + "  " + value + "  " + pinData.prevAnalogReads[p]);
					}
				} 
			}
		}
		
		
		
		//		private function handleAnalog(pin:int, value:int):void {
		//			// STOP AND SAVE READING IF IT IS THE FIRST READING
		//			if (_prevAnalogReads[pin] == "empty") {
		//				_prevAnalogReads[pin] =  value
		//				_lastAnalogReads[pin] =  value
		//				//fatal('first reading ' + pin);
		//				return;
		//			} 
		//			
		//			// READ AND SEND
		//			for each (var p:int in _usedAnalogPins) {
		//				if (pin == p && _prevAnalogReads[p] != "empty") {
		//
		//					_analogVals[p] = Functions.map(value, 0, 1023, _analogMinMaxMapVals[p].x,  _analogMinMaxMapVals[p].y);
		//					_lastAnalogReads[p] = value;
		//					var action :InputAction = _ce.input.getAction(_actionPins[p]) as InputAction;
		//					
		//					if (value != _prevAnalogReads[p] && value > (_prevAnalogReads[p] + ANALOG_MARING) || value < (_prevAnalogReads[p] - ANALOG_MARING)){
		//						triggerCHANGE(_actionPins[p], _analogVals[p], "ON");
		//						_prevAnalogReads[p] = value;
		//							error("ON " + pin + "/" + _actionPins[p] + "  " + value + "  " + _prevAnalogReads[p]); 
		//						if (value == 1023 || value == 0 ) {
		//							triggerOFF(_actionPins[p], _analogVals[p], "OFF");
		//								notice("OFF " + _actionPins[pin] + "  " + value + "  " + _prevAnalogReads[pin]);
		//						}
		//						if (_prevAnalogReads[p] == 0) _prevAnalogReads[p] = 1; // BUG FIX - MAG NOG ANDERS :P
		//						if (_prevAnalogReads[p] == 1023) _prevAnalogReads[p] = 1022; // BUG FIX - MAG NOG ANDERS :P
		//					} else if (action && action.message == "ON") {
		//						triggerOFF(_actionPins[p], _analogVals[p], "OFF");
		//							debug("OFF " + _actionPins[p] + "  " + value + "  " + _prevAnalogReads[p]);
		//					}
		//				} 
		//			}
		//		}
		
		
		
	}
}