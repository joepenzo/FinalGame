package
{
	import citrus.core.CitrusObject;
	
	import data.consts.Actions;
	import data.consts.ValueRange;
	
	import flash.display.Sprite;
	
	import uk.co.soulwire.gui.SimpleGUI;
	import com.bit101.components.List;
	import com.bit101.components.ComboBox;

	
	public class DebugInterface extends Sprite {
		private var _gui:SimpleGUI;
		private var _guiInput:GuiInputController;
		
		public var zoom : Number = 0;
		public var gravity : Number = 0;
		
		public var red : int = 0;
		public var green : int = 0;
		public var blue : int = 0;
		
		public var styledItem : String = "platform";
		
			
			
			
		public function DebugInterface() {
			
			
			_guiInput = new GuiInputController("guiInput");
			addInterface();
		}
		
		private function addInterface():void {
			_gui = new SimpleGUI(this, "", "C");
//			_gui.addSaveButton();
			
			_gui.addColumn("Level Settings");
			_gui.addSlider("zoom", ValueRange.ZOOM.x, ValueRange.ZOOM.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_ZOOM, zoom);  }});
			_gui.addSlider("gravity", ValueRange.GRAVITY.x, ValueRange.GRAVITY.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_GRAVITY, gravity); }});
			
			_gui.addGroup("Style");
			_gui.addComboBox("styledItem", [
				{label:"Avatar", data: Actions.SELECTED_COLOROBJ_HERO},
				{label:"Platform", data: Actions.SELECTED_COLOROBJ_PLAT},
				{label:"Background", data: Actions.SELECTED_COLOROBJ_BG}
			], { callback: function ():void{  _guiInput.triggerOn(styledItem); }});
			
			_gui.addSlider("red", ValueRange.RED.x, ValueRange.RED.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_RED, red);  }});
			_gui.addSlider("green", ValueRange.GREEN.x, ValueRange.GREEN.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_GREEN, green);  }});
			_gui.addSlider("blue", ValueRange.BLUE.x, ValueRange.BLUE.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_BLUE, blue);  }});
			
			
			_gui.show();
		}
		
	}
}