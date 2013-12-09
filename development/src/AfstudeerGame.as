package
{
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.sounds.CitrusSoundGroup;
	
//	
//	import data.GameData;
//	import data.SynthSounds;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import logmeister.LogMeister;
	import logmeister.connectors.TrazzleConnector;
	
	
	public class AfstudeerGame extends StarlingCitrusEngine {
		
//		private var _gameData:GameData;
//		private var _sounds:SynthSounds;
		
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
		}
		
		
		
		
	}
}