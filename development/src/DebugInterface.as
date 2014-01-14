package
{
	import citrus.core.CitrusObject;
	
	import com.bit101.components.ComboBox;
	import com.bit101.components.List;
	
	import data.consts.Actions;
	import data.types.SoundRange;
	import data.types.ValueRange;
	
	import flash.display.Sprite;
	
	import uk.co.soulwire.gui.SimpleGUI;

	
	public class DebugInterface extends Sprite {
		private var _gui:SimpleGUI;
		private var _guiInput:GuiInputController;
		
		public var zoom : Number = 0;
		public var gravity : Number = 0;
		public var goal : String = "No Goal";
		
		public var red : int = 0;
		public var green : int = 0;
		public var blue : int = 0;
		
		public var styledItem : String = "Avatar";
		public var audioItem : String = "Jump";
		public var shape : String = "Rectangle";
		
		
		public var heroSize : int;	
		public var heroLives : int;	
		public var heroSpeed : Number;	
		public var shootEnabled : Boolean = true;	
		public var jump : String = "Single";
		
		public var movingPlatPercentage : int;	
		public var trampolinePercentage : int;	
		public var enemyPercentage : int;	
		public var trapPercentage : int;	
		public var livesPercentage : int;	
		public var coinsPercentage : int;	

		public var enemySpeed : Number;	
		public var trapHeight : Number;	
		public var movingPlatSpeed : Number;	
		public var trampolineBoost : Number;	
			
		public var startFreq : Number = 0;	
		public var endFreq : Number = 0;	
		public var slide : Number = 0;	
		public var duration : Number = 0;	
		
		public function DebugInterface() {
			_guiInput = new GuiInputController("guiInput");
			addInterface();
			_gui.hide();
		}
		
		private function addInterface():void {
			_gui = new SimpleGUI(this, "", "C");
			
			_gui.addColumn("Level Settings");
			_gui.addButton("platformLevel", { callback: function ():void{  _guiInput.triggerOnce(Actions.CHANGE_LVL_MARIO, 1);  }});
			_gui.addButton("caveLevel", { callback: function ():void{  _guiInput.triggerOnce(Actions.CHANGE_LVL_CAVE, 1);  }});
			
			_gui.addSlider("zoom", ValueRange.ZOOM.x, ValueRange.ZOOM.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_ZOOM, zoom);  }});
			_gui.addSlider("gravity", ValueRange.GRAVITY.x, ValueRange.GRAVITY.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_GRAVITY, gravity); }});
			
			_gui.addComboBox("goal", [
				{label:"Kill Enemies", data: Actions.GOAL_KILL},
				{label:"Collect Coins", data: Actions.GOAL_COLLECT},
				{label:"A to B", data: Actions.GOAL_A_TO_B},
				{label:"No Goal", data: Actions.GOAL_NO_GOAL}
			], { callback: function ():void{  _guiInput.triggerOnce(goal,1); }});
			
			
			_gui.addGroup("Style");
			_gui.addComboBox("styledItem", [
				{label:"Avatar", data: Actions.SELECTED_CURRENTSTYLING_HERO},
				{label:"Platform", data: Actions.SELECTED_CURRENTSTYLING_PLAT},
				{label:"Background", data: Actions.SELECTED_CURRENTSTYLING_BG},
				{label:"Enemies", data: Actions.SELECTED_CURRENTSTYLING_ENEMIES},
				{label:"Bullets", data: Actions.SELECTED_CURRENTSTYLING_BULLETS},
				{label:"Coins", data: Actions.SELECTED_CURRENTSTYLING_COINS},
				{label:"Lives", data: Actions.SELECTED_CURRENTSTYLING_LIVES},
				{label:"Moving Platorms", data: Actions.SELECTED_CURRENTSTYLING_MOVINGPLATS},
				{label:"Trampolines", data: Actions.SELECTED_CURRENTSTYLING_TRAMPOLINE},
				{label:"Traps", data: Actions.SELECTED_CURRENTSTYLING_TRAPS}
			], { callback: function ():void{  _guiInput.triggerOnce(styledItem,1); }});
			
			_gui.addSlider("red", ValueRange.RED.x, ValueRange.RED.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_RED, red);  }});
			_gui.addSlider("green", ValueRange.GREEN.x, ValueRange.GREEN.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_GREEN, green);  }});
			_gui.addSlider("blue", ValueRange.BLUE.x, ValueRange.BLUE.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_BLUE, blue);  }});
			
			_gui.addComboBox("shape", [
				{label:"Rectangle", data: Actions.CHANGE_SHAPE_RECT},
				{label:"Triangle", data: Actions.CHANGE_SHAPE_TRIANGLE},
				{label:"Hexagon", data: Actions.CHANGE_SHAPE_HEXAGON},
				{label:"Circle", data: Actions.CHANGE_SHAPE_CIRCLE}
			], { callback: function ():void{  _guiInput.triggerOnce(shape,1); }});
			
			_gui.addGroup("Audio");
			_gui.addComboBox("audioItem", [
				{label:"Coins Pickup", data: Actions.SELECTED_CURRENTAUDIO_COINS},
				{label:"Lives Pickup", data: Actions.SELECTED_CURRENTAUDIO_LIFES},
				{label:"Shoot", data: Actions.SELECTED_CURRENTAUDIO_SHOOT},
				{label:"Hit", data: Actions.SELECTED_CURRENTAUDIO_HIT},
				{label:"Jump", data: Actions.SELECTED_CURRENTAUDIO_JUMP}
			], { callback: function ():void{  _guiInput.triggerOnce(audioItem,1); }});
			
			_gui.addSlider("startFreq", 0, 1023, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.AUDIO_STARTFREQUENCY, startFreq);  }});
			_gui.addSlider("endFreq",0, 1023, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.AUDIO_ENDFREQUENCY, endFreq);  }});
			_gui.addSlider("slide", 0, 1023, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.AUDIO_SLIDE, slide);  }});
			_gui.addSlider("duration",0, 1023, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.AUDIO_ENDFREQUENCY, duration);  }});

			
			
			
			
			_gui.addColumn("Level components");

			_gui.addGroup("Avatar");
			_gui.addSlider("heroLives", ValueRange.HERO_LIVES.x, ValueRange.HERO_LIVES.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.HERO_LIVES, heroLives); }});
			_gui.addSlider("heroSize", ValueRange.HERO_SIZE.x, ValueRange.HERO_SIZE.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.HERO_SIZE, heroSize); }});
			_gui.addSlider("heroSpeed", ValueRange.HERO_SPEED.x, ValueRange.HERO_SPEED.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.HERO_SPEED, heroSpeed); }});
			_gui.addToggle("shootEnabled", { callback: function ():void{  _guiInput.triggerOnce(Actions.HERO_SHOOT_ONOFF, int(shootEnabled)); }});
			_gui.addComboBox("jump", [
				{label:"Single", data: Actions.CHANGE_JUMP_SINGLE},
				{label:"Double", data: Actions.CHANGE_JUMP_DOUBLE},
				{label:"Unlimited", data: Actions.CHANGE_JUMP_UNLIMETID},
				{label:"Jetpack", data: Actions.CHANGE_JUMP_JETPACK}
			], { callback: function ():void{  _guiInput.triggerOnce(jump,1); }});
			
			_gui.addGroup("Enemies");
			_gui.addSlider("enemyPercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.ENEMY_PERCANTAGE, enemyPercentage); }});
			_gui.addSlider("enemySpeed", ValueRange.ENEMYSPEED.x, ValueRange.ENEMYSPEED.y, {label:"speed",  callback: function ():void{  _guiInput.triggerUntilRelease(Actions.ENEMY_SPEED, enemySpeed); }});
			
			_gui.addGroup("Traps");
			_gui.addSlider("trapPercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.TRAP_PERCANTAGE, trapPercentage); }});
			_gui.addSlider("trapHeight", ValueRange.TRAP_HEIGHT.x, ValueRange.TRAP_HEIGHT.y, { callback: function ():void{  _guiInput.triggerOnce(Actions.TRAP_HEIGHT, trapHeight); }});
			
			_gui.addGroup("Collectables");
			_gui.addSlider("livesPercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"Lifes amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.LIVES_PERCANTAGE, livesPercentage); }});
			_gui.addSlider("coinsPercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"Coins amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.COINS_PERCANTAGE, coinsPercentage); }});
			
			_gui.addGroup("MovingPlatform");
			_gui.addSlider("movingPlatPercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.MOVINGPLAT_PERCANTAGE, movingPlatPercentage); }});
			_gui.addSlider("movingPlatSpeed", ValueRange.MOVINGPLAT_SPEED.x, ValueRange.MOVINGPLAT_SPEED.y, {label:"speed",  callback: function ():void{  _guiInput.triggerUntilRelease(Actions.MOVINGPLATFORM_SPEED, movingPlatSpeed); }});
			
			_gui.addGroup("Trampoline");
			_gui.addSlider("trampolinePercentage", ValueRange.PERCENTAGE.x, ValueRange.PERCENTAGE.y, {label:"amount",  callback: function ():void{  _guiInput.triggerOnce(Actions.TRAMPOLINE_PERCANTAGE, trampolinePercentage); }});
			_gui.addSlider("trampolineBoost", ValueRange.TRAMP_BOOST.x, ValueRange.TRAMP_BOOST.y, {label:"speed",  callback: function ():void{  _guiInput.triggerUntilRelease(Actions.TRAMPOLINE_BOOST, trampolineBoost); }});
			
			
			
		}
		
	}
}