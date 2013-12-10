package
{
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.sounds.CitrusSoundGroup;
	
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import logmeister.LogMeister;
	import logmeister.connectors.TrazzleConnector;
	import uk.co.soulwire.gui.SimpleGUI;
	import flash.display.BlendMode;
	import flash.net.FileFilter;
	
	
	public class AfstudeerGame extends StarlingCitrusEngine {
		
//		private var _gameData:GameData;
//		private var _sounds:SynthSounds;
		private var _gui:SimpleGUI;
		
		public var zoomValue : Number = 80;
		public var gravityValue : Number = 100;
		
		public function AfstudeerGame() {
			LogMeister.addLogger(new TrazzleConnector(stage, "AfstudeerGame"));
			setUpStarling(true);
			
//			gameData = new GameData();
//			_gameData = gameData as GameData;
//			
//			_gameData.currentColoring = "platform";
//			
//			_sounds = new SynthSounds("synthSounds");
//			_gameData.synthSounds = _sounds;
			
			state = new GameState();
			
			addInterface();
		}
		
		private function addInterface():void {
			_gui = new SimpleGUI(this, "", "C");
//			_gui.addSaveButton();
			
			_gui.addColumn("Level Settings");
			_gui.addSlider("zoomValue", 10, 200, { callback: function ():void{ error(zoomValue); }});
			_gui.addSlider("gravityValue", 10, 200, { callback: function ():void{ error(gravityValue); }});
			//_gui.addGroup("Style");
			//_gui.add("Style");
			
			
//			_gui.show();
		}		
		
		private function onValueChanged(value:Number):void{
			notice(value);
		
		}
		
		
	}
}