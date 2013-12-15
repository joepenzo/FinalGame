package objects
{
	import citrus.core.starling.StarlingState;
	
	import data.GameData;
	import data.types.Goals;
	
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class GameInterface 
	{
		
		private var _goal:TextField;
		private var _goalTarget:TextField;
		private var _lives:TextField;
		
		public var x : int;
		public var y : int;
		
		public function GameInterface(state : StarlingState, x : int, y : int) {
		
			_goal = new TextField(200, 30, "", "PixelUniCode", 25, 0x0000ff);
//			_goal.border = true;
			_goal.vAlign = VAlign.TOP;
			_goal.hAlign = HAlign.LEFT;
			_goal.x = x;
			_goal.y = y + 5;
			state.addChild(_goal);
			
			_goalTarget = new TextField(200, 30, "", "PixelUniCode", 25, 0x0000ff);
//			_goalTarget.border = true;
			_goalTarget.vAlign = VAlign.TOP;
			_goalTarget.hAlign = HAlign.LEFT;
			_goalTarget.x = _goal.x;
			_goalTarget.y = _goal.y + _goal.height;
			state.addChild(_goalTarget);
			
			_lives = new TextField(200, 30, "Lives x", "PixelUniCode", 30, 0x0000ff);
			_lives.vAlign = VAlign.TOP;
			_lives.hAlign = HAlign.LEFT;
			_lives.x = _goalTarget.x;
			_lives.y = _goalTarget.y + _goalTarget.height + 25;
			state.addChild(_lives);
			
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
				case Goals.KILL_ENEMIES:
					_goal.text = Goals.KILL_ENEMIES.toString();
					_goalTarget.text = gameData.enemiesKilled.toString() + " / " + gameData.totalEnemies.toString(); 
					break;
				case Goals.COLLECT_COINS:
					_goal.text = Goals.COLLECT_COINS.toString();
					break;
				case Goals.A_TO_B:
					_goal.text = Goals.A_TO_B.toString();
					break;
				case Goals.NO_GOAL:
					_goal.text = Goals.NO_GOAL.toString();
					break;
			}
			
		}
		
		
		public function updateGoalStatus(txt:String):void {
			_goalTarget.text = txt;
		}
		
		public function changesLives(lives : int) : void {
			_lives.text = "Lives x" + lives;
		}
		
		
	}
}