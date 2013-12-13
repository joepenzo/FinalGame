package objects
{
	import citrus.core.starling.StarlingState;
	
	import data.GameData;
	
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class GameInterface 
	{
		
		private var _goal:TextField;
		private var _goalTarget:TextField;
		
		public function GameInterface(state : StarlingState) {
		
			_goal = new TextField(200, 30, "", "PixelUniCode", 25, 0x0000ff);
			_goal.border = true;
			_goal.vAlign = VAlign.TOP;
			_goal.hAlign = HAlign.LEFT;
			_goal.x = 10;
			_goal.y = 35;
			state.addChild(_goal);
			
			_goalTarget = new TextField(200, 30, "", "PixelUniCode", 25, 0x0000ff);
			_goalTarget.border = true;
			_goalTarget.vAlign = VAlign.TOP;
			_goalTarget.hAlign = HAlign.LEFT;
			_goalTarget.x = 10;
			_goalTarget.y = _goal.y + _goal.height;
			state.addChild(_goalTarget);
			
		}

		public function get goal():TextField
		{
			return _goal;
		}

		public function get goalTarget():TextField
		{
			return _goalTarget;
		}

		public function updateGoalType(gameData:GameData):void
		{
			switch(gameData.goal){
				case "KILL":
					_goal.text = "Kill Enemies";
					break;
				case "COLLECT":
					_goal.text = "Collect Coins";
					break;
				case "ATOB":
					_goal.text = "Go To Finish";
					break;
				case "NOGOAL":
					_goal.text = "No Goal";
					break;
			}
		}
	}
}