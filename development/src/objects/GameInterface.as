package objects
{
	import citrus.core.starling.StarlingState;
	
	import data.GameData;
	import data.consts.Goals;
	
	import starling.display.BlendMode;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class GameInterface 
	{
		
		private static const COLOR : uint = 0xffffff;
		
		private var _goal:TextField;
		private var _goalTarget:TextField;
		private var _lives:TextField;
		
		public var x : int;
		public var y : int;
		
		public function GameInterface(state : StarlingState, x : int, y : int) {
		
			_lives = new TextField(200, 40, "Lives x", "PixelUniCode", 35, COLOR, true);
			_lives.vAlign = VAlign.TOP;
			_lives.hAlign = HAlign.LEFT;
			_lives.x = x;
			_lives.y = y;
			_lives.bold = true;
			state.addChild(_lives);
			
			_goal = new TextField(200, 35, "", "PixelUniCode", 30, COLOR);
//			_goal.border = true;
			_goal.vAlign = VAlign.TOP;
			_goal.hAlign = HAlign.LEFT;
			_goal.x = x;
			_goal.y = _lives.y + _lives.height + 10;
			state.addChild(_goal);
			
			_goalTarget = new TextField(200, 35, "", "PixelUniCode", 30, COLOR);
//			_goalTarget.border = true;
			_goalTarget.vAlign = VAlign.TOP;
			_goalTarget.hAlign = HAlign.LEFT;
			_goalTarget.x = x;
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