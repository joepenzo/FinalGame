package data
{
	import citrus.core.CitrusObject;
	import citrus.input.InputAction;
	import citrus.utils.AGameData;
	import flash.utils.*;
	import flash.utils.Dictionary;
	import data.consts.Actions;
	import data.consts.Sounds;
	
	public class SynthSounds extends CitrusObject
	{
		
		private const AUDIO_FEEDBACK_DELAYTIME:int = 50;

		private var sounds : Dictionary = new Dictionary();
		
		private var _jump : SfxrSynth = new SfxrSynth();
		private var audioInterval:Number =  0;
		
		public function SynthSounds(name : String, params : Object = null) {
			updateCallEnabled = true;
			super(name, params);
			
			_jump.params.setSettingsString("0,,0.271,,0.18,0.395,,0.201,,,,,,0.284,,,,,0.511,,,,,0.5");
			_jump.cacheSound();
			sounds[Sounds.JUMP] = _jump;
			
			/*
			if(_ce.input.isDoing("do-zoom")) {
				var action :InputAction = _ce.input.getAction("do-zoom") as InputAction;
				_log.text = action.value.toString()  + "  " +  Math.random().toString();
			}
			*/
		}
		
		private function playAudioFeedBack(soundName : String):void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.stop();
			sound.play();
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			if(_ce.input.isDoing(Actions.AUDIO_SQUAREDUTY)) {
				var action :InputAction = _ce.input.getAction(Actions.AUDIO_SQUAREDUTY) as InputAction;
				SetSquareDuty(Sounds.JUMP, action.value);

				clearTimeout(audioInterval);
				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, Sounds.JUMP);
						
				//notice("AUDIO_SQUAREDUTY " + action.value);
			}
			if(_ce.input.isDoing(Actions.AUDIO_STARTFREQUENCY)) {
				action = _ce.input.getAction(Actions.AUDIO_STARTFREQUENCY) as InputAction;
				SetStartFrequency(Sounds.JUMP, action.value);
				
				clearTimeout(audioInterval);
				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, Sounds.JUMP);
				//notice("AUDIO_STARTFREQUENCY " + action.value);
			}
			if(_ce.input.isDoing(Actions.AUDIO_SLIDE)) {
				action = _ce.input.getAction(Actions.AUDIO_SLIDE) as InputAction;
				SetSlide(Sounds.JUMP, action.value);
				
				clearTimeout(audioInterval);
				audioInterval = setTimeout(playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, Sounds.JUMP);
				//notice("AUDIO_SLIDE " + action.value);
			}
			if(_ce.input.isDoing(Actions.AUDIO_SUSTAINTIME)) {
				action = _ce.input.getAction(Actions.AUDIO_SUSTAINTIME) as InputAction;
			}
			if(_ce.input.isDoing(Actions.AUDIO_DECAYTIME)) {
				action = _ce.input.getAction(Actions.AUDIO_DECAYTIME) as InputAction;
			}
		}

		public function getSound(soundName : String) : SfxrSynth {
			if (!sounds[soundName]) return null;
			var sound : SfxrSynth = sounds[soundName];
			return sound
		}
		
		public function play(soundName : String) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.play();
			
			/*
			trace("\nwaveType " +  sound.params.waveType);
			trace("squareDuty " + sound.params.squareDuty);
			trace("startFrequency " + sound.params.startFrequency);
			trace("slide " + sound.params.slide);
			trace("sustainTime " + sound.params.sustainTime);
			trace("decayTime " + sound.params.decayTime);
			*/
		}
		
		public function SetSquareDuty(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.squareDuty = val;
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
		
		public function SetSustainTime(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.sustainTime = val;
		}

		public function SetDecayTime(soundName : String, val : Number) : void {
			if (!sounds[soundName]) return;
			var sound : SfxrSynth = sounds[soundName];
			sound.params.decayTime = val;
		}
		
		
		
		/* JUMP
		_waveType = 0;
		_squareDuty = Math.random() * 0.6;
		_startFrequency = 0.3 + Math.random() * 0.3;
		_slide = 0.1 + Math.random() * 0.2;
		
		_sustainTime = 0.1 + Math.random() * 0.3;
		_decayTime = 0.1 + Math.random() * 0.2;
		*/


	}
}
