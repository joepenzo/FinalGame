package
{
	import away3d.debug.Debug;
	
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.sounds.CitrusSoundGroup;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	
	import logmeister.LogMeister;
	import logmeister.connectors.TrazzleConnector;
	import data.GameData;
	import citrus.utils.AGameData;
	import audio.SynthSounds;
	
	
	public class AfstudeerGame extends StarlingCitrusEngine {
		
		
		
		// that unicode range is for basic latin set (upper, lower case chars, numerals and common symbols/punctuations)
		[Embed(source="./assets/PixelUniCode.ttf", embedAsCFF="false", fontFamily="PixelUniCode", unicodeRange = "U+0020-U+007e")]
		private static const PixelUniCode:Class;
		
		private var _gameData:GameData;
		private var _sounds:SynthSounds;
		
		
		public function AfstudeerGame() {
			LogMeister.addLogger(new TrazzleConnector(stage, "AfstudeerGame"));
			setUpStarling(true);
			
			gameData = new GameData();
			_gameData = gameData as GameData;

			
			_gameData.currentStyling = "platform";
			_gameData.lives = 1;
			
			_sounds = new SynthSounds("synthSounds");
			_gameData.synthSounds = _sounds;
			
			state = new GameState();

			var debugInterface = new DebugInterface();
			stage.addChild(debugInterface);
			
			
		}		
		
		
		
		
	}
}