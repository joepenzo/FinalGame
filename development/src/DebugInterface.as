package
{
	import citrus.core.CitrusObject;
	
	import com.bit101.components.ComboBox;
	import com.bit101.components.List;
	
	import data.consts.Actions;
	import data.consts.ValueRange;
	
	import flash.display.Sprite;
	
	import uk.co.soulwire.gui.SimpleGUI;

	
	public class DebugInterface extends Sprite {
		private var _gui:SimpleGUI;
		private var _guiInput:GuiInputController;
		
		public var zoom : Number = 0;
		public var gravity : Number = 0;
		
		public var red : int = 0;
		public var green : int = 0;
		public var blue : int = 0;
		
		public var styledItem : String = "Platform";
		public var shape : String = "Rectangle";
		
		public var heroSize : int;	
			
			
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
				{label:"Platform", data: Actions.SELECTED_COLOROBJ_PLAT},
				{label:"Avatar", data: Actions.SELECTED_COLOROBJ_HERO},
				{label:"Background", data: Actions.SELECTED_COLOROBJ_BG}
			], { callback: function ():void{  _guiInput.triggerOnce(styledItem); }});
			
			_gui.addSlider("red", ValueRange.RED.x, ValueRange.RED.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_RED, red);  }});
			_gui.addSlider("green", ValueRange.GREEN.x, ValueRange.GREEN.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_GREEN, green);  }});
			_gui.addSlider("blue", ValueRange.BLUE.x, ValueRange.BLUE.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.VALUE_BLUE, blue);  }});
			
			_gui.addComboBox("shape", [
				{label:"Rectangle", data: Actions.CHANGE_SHAPE_RECT},
				{label:"Triangle", data: Actions.CHANGE_SHAPE_TRIANGLE},
				{label:"Hexagon", data: Actions.CHANGE_SHAPE_HEXAGON},
				{label:"Circle", data: Actions.CHANGE_SHAPE_CIRCLE}
			], { callback: function ():void{  _guiInput.triggerOnce(shape); }});
			
			
			_gui.addGroup("Avatar");
			_gui.addSlider("heroSize", ValueRange.HERO_SIZE.x, ValueRange.HERO_SIZE.y, { callback: function ():void{  _guiInput.triggerUntilRelease(Actions.HERO_SIZE, heroSize); }});
			
			_gui.show();
		}
		
	}
}