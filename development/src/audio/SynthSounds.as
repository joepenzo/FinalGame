package audio
{
	import citrus.core.CitrusObject;
	import citrus.input.InputAction;
	import citrus.utils.AGameData;
	
	import data.consts.Actions;
	
	import flash.utils.*;
	import flash.utils.Dictionary;
	import data.GameData;
	
	public class SynthSounds extends CitrusObject
	{
		
		private const VOLUME : Number = .5;
//		private const AUDIO_FEEDBACK_DELAYTIME:int = 50;
//		private var audioInterval:Number =  0;

		private var _gameData:GameData;

		private var _sounds : Dictionary = new Dictionary();
		
		private var _jump : SfxrSynth = new SfxrSynth();
		private var _shoot : SfxrSynth = new SfxrSynth();
		private var _hit : SfxrSynth = new SfxrSynth();
		private var _coin : SfxrSynth = new SfxrSynth();
		private var _life : SfxrSynth = new SfxrSynth();
		private var _rewind : SfxrSynth = new SfxrSynth();
		
		
		
		
		public function SynthSounds(name : String, params : Object = null) {
			notice("synth init");
			super(name, params);
			updateCallEnabled = true;
			_gameData = _ce.gameData as GameData;
			
			_jump.params.setSettingsString("0,,0.271,,0.18,0.395,,0.201,,,,,,0.284,,,,,0.511,,,,," + VOLUME);
			_jump.cacheSound();
			sounds[Sounds.JUMP] = _jump;

			_shoot.params.setSettingsString("0,,0.2336,0.1885,0.1555,0.7963,0.0253,-0.4479,,,,,,0.1343,0.0064,,,,1,,,,," + VOLUME);
			_shoot.cacheSound();
			sounds[Sounds.SHOOT] = _shoot;
			
			_hit.params.setSettingsString("0,,0.0365,,0.1434,0.5223,,-0.5298,,,,,,,,,,,1,,,0.1867,," + VOLUME);
			_hit.cacheSound();
			sounds[Sounds.HIT] = _hit;
			
			_coin.params.setSettingsString("0,,0.0434,0.5867,0.4062,0.5989,,,,,,0.5636,0.6765,,,,,,1,,,,," + VOLUME);
			_coin.cacheSound();
			sounds[Sounds.COIN] = _coin;
			
			_life.params.setSettingsString("0,,0.1563,,0.4807,0.2028,,0.3691,,,,,,0.569,,0.4727,,,1,,,,," + VOLUME);
			_life.cacheSound();
			sounds[Sounds.LIFE] = _life;
			
			_rewind.params.setSettingsString("3,0.2,1,0.98,1,0.1508,,0.3799,-0.6599,,,0.48,,,,,,,1,,,,," + VOLUME*.65);
			_rewind.cacheSound();
			sounds[Sounds.REWIND] = _rewind;
			
		}
		
		public function get sounds():Dictionary
		{
			return _sounds;
		}

		public function set sounds(value:Dictionary):void
		{
			_sounds = value;
		}

		public function playAudioFeedBack(soundName : String):void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.stop();
			sound.play();
		}
		
//		override public function update(timeDelta:Number):void {
//			super.update(timeDelta);
//			error("sounnnndds");
			
//			if(_ce.input.isDoing(Actions.AUDIO_STARTFREQUENCY)) {
//				error("AUDIO_STARTFREQUENCY");
//				action = _ce.input.getAction(Actions.AUDIO_STARTFREQUENCY) as InputAction;
//				SetStartFrequency(sounds[_gameData.currentAudio], action.value);
//
//				clearTimeout(audioInterval);
//				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, sounds[_gameData.currentAudio]);
//			}
//			
//			if(_ce.input.isDoing(Actions.AUDIO_ENDFREQUENCY)) {
//				error("AUDIO_ENDFREQUENCY");
//				var action :InputAction = _ce.input.getAction(Actions.AUDIO_ENDFREQUENCY) as InputAction;
//				SetEndFrequency(sounds[_gameData.currentAudio], action.value);
//
//				clearTimeout(audioInterval);
//				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, sounds[_gameData.currentAudio]);
//			}
//			
//			if(_ce.input.isDoing(Actions.AUDIO_SLIDE)) {
//				error("AUDIO_SLIDE");
//				action = _ce.input.getAction(Actions.AUDIO_SLIDE) as InputAction;
//				SetSlide(sounds[_gameData.currentAudio], action.value);
//				
//				clearTimeout(audioInterval);
//				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, sounds[_gameData.currentAudio]);
//			}
//		
//			if(_ce.input.isDoing(Actions.AUDIO_DURATION)) {
//				error("AUDIO_DURATION");
//				action = _ce.input.getAction(Actions.AUDIO_DURATION) as InputAction;
//				SetDuration(sounds[_gameData.currentAudio], action.value);
//				
//				clearTimeout(audioInterval);
//				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, sounds[_gameData.currentAudio]);
//			}
			
//		}

		public function getSound(soundName : String) : SfxrSynth {
			if (!sounds[soundName]) return null;
			var sound : SfxrSynth = sounds[soundName];
			return sound
		}
		
		public function play(soundName : String) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.play();
		}
		
		public function stop(soundName : String) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.stop();
		}
		
		
		public function SetEndFrequency(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.squareDuty = val; // TODO CHECK
		}
		
		public function SetStartFrequency(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.startFrequency = val;
		}
		
		public function SetSlide(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.slide = val;
		}
		
		public function SetDuration(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.decayTime = val; // TODO CHECK
		}
		
		


	}
}
