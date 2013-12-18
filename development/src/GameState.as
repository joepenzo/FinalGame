package
{
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingState;
	import citrus.input.InputAction;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.utils.AGameData;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import data.GameData;
	import data.types.Actions;
	import data.types.Goals;
	import data.types.Shapes;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import generators.CaveGenerator;
	import generators.MarioGenerator;
	
	import objects.EdgeDetectorEnemy;
	import objects.ExBox2DPhysicsObject;
	import objects.ExEnemy;
	import objects.ExHero;
	import objects.ExPlatform;
	import objects.GameInterface;
	import objects.Level;
	import objects.StaticTrap;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Shape;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.FlashShape;
	import utils.Functions;
	import utils.StarlingDraw;
	import utils.StarlingShape;
	
	public class GameState extends StarlingState
	{
		private var _gameData:GameData;

		private var _tileSize:int = 32; // 32 
		private var _mapW:int = 100;
		private var _mapH:int = 40;
		
		private var _box2D:Box2D;
		private var _lvl:Level;
		private var _camera:StarlingCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		private var _debugSprite:flash.display.Sprite;
		private var ENEMY_AMOUNT_INTERVAL:Number = new Number();
		private var _gameInterface:GameInterface;
		
		private var _arduinoConnector:ArduinoSerialComAnalogAndDigital;

		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			_gameData = _ce.gameData as GameData;
			
			_box2D = new Box2D("box2D");
			_box2D.visible = false;
			add(_box2D);
			
			_mapW = 40;//_mapW = 150;
			_mapH = 25;
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1);

//			_mapW = 100;
//			_mapH = 50;			
//			_lvl = CaveGenerator.createlevel(_mapW, _mapH);
			
			_lvl.drawMapPlaftormsToGameState(this, _tileSize, 0x000000);
//			_lvl.drawDebugGrid(this);
			
			var heroStartPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {
				group:3,
				x:heroStartPos.x * _tileSize, 
				y:heroStartPos.y* _tileSize, 
				width:_tileSize/2, 
				height: _tileSize/2
			});
			_hero.enemyClass = EdgeDetectorEnemy;
			_hero.hurtVelocityX = _tileSize*.07;
			_hero.hurtVelocityY = _tileSize*.09;
			_hero.currentColor = 0x000050;
			_hero.currentShape = Shapes.RECTANGLE;
			_hero.view = StarlingShape.Rectangle(_hero.width, _hero.height, _hero.currentColor);
			_hero.jumpType = "Unlimited";
			add(_hero);
			
			
			
			_bounds = new Rectangle(0, 0, _mapW*_tileSize, _mapH*_tileSize);
			_camera = view.camera as StarlingCamera;
			_camera.setUp(_hero, new Point(stage.stageWidth/2, stage.stageHeight/2), _bounds, new Point(.5, .5));
			_camera.allowRotation = true;
			_camera.allowZoom = true;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			_camera.rotationEasing = .3;
			_camera.zoomEasing = .1;
			_camera.setZoom(2);
			
			// CREATE MINIMAP DEBUG SPRITE
			_debugSprite = new flash.display.Sprite();
			_debugSprite.scaleX = 0.2 * 0.6;
			_debugSprite.scaleY = 0.2 * 0.6;
			_debugSprite.graphics.lineStyle(20, 0xFFFFFF, 0.4);
			// DETERMINE SIZE OF SPRITE
			_camera.renderDebug(_debugSprite as flash.display.Sprite)
			// ADD AND PLACE MINIMAP
			_ce.stage.addChild(_debugSprite);
			_debugSprite.x = stage.stageWidth - _debugSprite.width - 10;
			_debugSprite.y = 10;
			
			_gameInterface = new GameInterface(this, _debugSprite.x , _debugSprite.y + _debugSprite.height);
			
			_gameData.dataChanged.add(onDataChanged);
	
//			_arduinoConnector = new ArduinoSerialComAnalogAndDigital("arduinoConnector");

		}
		
		private function onDataChanged(data:String, value:Object):void {
			//error(data + "  " + value); 

			if (_gameData.goal == Goals.KILL_ENEMIES) {
				if (data == "totalEnemiesInState" || data == "totalEnemiesKilled") {
					_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );	
					if (_gameData.enemiesKilled == _gameData.totalEnemies) { // MADE YOUR GOAL, RESET THE MOTHERFUCKER
						_gameInterface.updateGoalStatus("DONE - RESETTING");
						setTimeout(function():void {
							_gameData.enemiesKilled = _gameData.totalEnemies = 0;
							_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );
						}, 2000);
					}
				}
			} else if (_gameData.goal == Goals.COLLECT_COINS && data == "score") {
				_gameInterface.updateGoalStatus( ("Coins / " + value.toString()) );
			}
			
			
			if (data == "lives") {
				_gameInterface.changesLives(int(value));
			}
			
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			//camera render debug 
			_camera.renderDebug(_debugSprite as flash.display.Sprite)
			drawPlatformsToMiniMap();
			drawEnemiesToMiniMap();
			// ENDOFF MINIMAP DEBUG RENDERING
			
			// GAME GOAL
			if (_ce.input.justDid(Actions.GOAL_KILL)) {
				_gameData.goal = Goals.KILL_ENEMIES;
				_gameInterface.updateGoalType(_gameData);
				_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );
			}
			if(_ce.input.justDid(Actions.GOAL_COLLECT)) {
				_gameData.goal = Goals.COLLECT_COINS;
				_gameInterface.updateGoalType(_gameData);
			}
			if(_ce.input.justDid(Actions.GOAL_A_TO_B)) {
				_gameData.goal = Goals.A_TO_B;
				_gameInterface.updateGoalType(_gameData);
			} 
			if(_ce.input.justDid(Actions.GOAL_NO_GOAL)) {
				_gameData.goal = Goals.NO_GOAL;
				_gameInterface.updateGoalType(_gameData);
			}
			
			
			// PLATFORM LEVEL - CHANGE
			if(_ce.input.justDid(Actions.CHANGE_LVL_MARIO)) {
				var action:InputAction = _ce.input.getAction(Actions.CHANGE_LVL_MARIO) as InputAction;
				redrawLevel("mario");
			}
			// CAVE LEVEL - CHANGE
			else if(_ce.input.justDid(Actions.CHANGE_LVL_CAVE)) {
				var action:InputAction = _ce.input.getAction(Actions.CHANGE_LVL_CAVE) as InputAction;
				redrawLevel("cave");
			}

			// GRAVITY - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_GRAVITY)) {
				var action:InputAction = _ce.input.getAction(Actions.VALUE_GRAVITY) as InputAction;
				_box2D.gravity.Set(0, action.value); 
			}
			// ZOOM - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_ZOOM)) {
				action = _ce.input.getAction(Actions.VALUE_ZOOM) as InputAction;
				_camera.setZoom(action.value);
			}

			
			// HERO SIZE - CHANGE
			if(_ce.input.isDoing(Actions.HERO_SIZE)) {
				action = _ce.input.getAction(Actions.HERO_SIZE) as InputAction;
				Functions.ResizeObjectValue(this, action.value/30/2, action.value/30/2, "hero");
			}
			// HERO LIVES - CHANGE
			if(_ce.input.isDoing(Actions.HERO_LIVES)) {
				action = _ce.input.getAction(Actions.HERO_LIVES) as InputAction;
				_gameData.lives = action.value;
			}
			// HERO SHOOTING _ONOFF
			if(_ce.input.justDid(Actions.HERO_SHOOT)) {
				action = _ce.input.getAction(Actions.HERO_SHOOT) as InputAction;
				_hero.shootingEnabled = action.value;
			}
			// HERO JUMPS
			if(_ce.input.justDid(Actions.CHANGE_JUMP_SINGLE)) {
				_hero.jumpType = "Single";
				fatal(_hero.jumpType);
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_DOUBLE)) {
				_hero.jumpType = "Double";
				fatal(_hero.jumpType);
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_UNLIMETID)) {
				_hero.jumpType = "Unlimited";
				fatal(_hero.jumpType);
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_JETPACK)) {
				_hero.jumpType = "Jetpack";
				fatal(_hero.jumpType);
			}

			
			// ENEMY AMOUNT - CHANGE
			if(_ce.input.hasDone(Actions.ENEMY_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.ENEMY_PERCANTAGE) as InputAction;
				_gameData.enemyPercentage = action.value;			
				
				clearTimeout(ENEMY_AMOUNT_INTERVAL);
				ENEMY_AMOUNT_INTERVAL = setTimeout(myDelayedFunction, 100, this, action);
				function myDelayedFunction(state : StarlingState, action : InputAction):void { 
					_lvl.placeEnemies(state, _gameData.enemyPercentage, new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize)) );
					_gameData.totalEnemies = _lvl.getTotalEnemiesAmount; // save total enemies for the enemy kill counter
				}
			}
			
			// TRAP AMOUNT
			if(_ce.input.hasDone(Actions.TRAP_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.TRAP_PERCANTAGE) as InputAction;
				_gameData.trapPercantage = action.value;			
				
				clearTimeout(ENEMY_AMOUNT_INTERVAL);
				ENEMY_AMOUNT_INTERVAL = setTimeout(function (state : StarlingState):void { 
					_lvl.placeStaticTraps(state, _gameData.trapPercantage, new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize) ));
				}, 100, this);
				
			}
		
			// LIVE AMOUNT
			if(_ce.input.hasDone(Actions.LIVES_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.LIVES_PERCANTAGE) as InputAction;
				_gameData.livesPercantage = action.value;			
				
				clearTimeout(ENEMY_AMOUNT_INTERVAL);
				ENEMY_AMOUNT_INTERVAL = setTimeout(function (state : StarlingState):void { 
					_lvl.placeLiveCollectables(state, _gameData.livesPercantage, new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize) ));
				}, 100, this);
				
			}
			
			
			
			
			
			//RED GREEN BLUE - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_RED)) {
				action = _ce.input.getAction(Actions.VALUE_RED) as InputAction;
				_gameData.red = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}if(_ce.input.isDoing(Actions.VALUE_GREEN)) {
				action = _ce.input.getAction(Actions.VALUE_GREEN) as InputAction;
				_gameData.green = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}if(_ce.input.isDoing(Actions.VALUE_BLUE)) {
				action = _ce.input.getAction(Actions.VALUE_BLUE) as InputAction;
				_gameData.blue = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}
			
			// CHANGE CURRENT STYLING OBJECT
			if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_HERO)) {
				_gameData.currentStyling = "hero";
			} if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_BG)) {
				_gameData.currentStyling = "bg";
			} if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_PLAT)) {
				_gameData.currentStyling = "platform";
			} if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_ENEMIES)) {
				_gameData.currentStyling = "enemies";
			}
			
			// CHANGE SHAPE OF SELECTED ITEM
			if (_ce.input.justDid(Actions.CHANGE_SHAPE_RECT)) {
				_gameData.currentShape = Shapes.RECTANGLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_TRIANGLE)) {
				_gameData.currentShape = Shapes.TRIANGLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_CIRCLE)) {
				_gameData.currentShape = Shapes.CIRCLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_HEXAGON)) {
				_gameData.currentShape = Shapes.HEXAGON;
				changeObjectShape();
			}
			
			
				
		}
		
		
		private function drawPlatformsToMiniMap():void{
			_debugSprite.graphics.lineStyle();
			_debugSprite.graphics.beginFill(0x000000, 0.2);
			var platforms:Vector.<CitrusObject> = getObjectsByType(Platform);
			var platfromm:CitrusObject;
			for each (platfromm in platforms) {
				_debugSprite.graphics.drawRect((platfromm as Platform).x - (platfromm as Platform).width / 2, (platfromm as Platform).y - (platfromm as Platform).height / 2, (platfromm as Platform).width, (platfromm as Platform).height);
			}
		}
		private function drawEnemiesToMiniMap():void{
			_debugSprite.graphics.lineStyle();
			_debugSprite.graphics.beginFill(0xff0000, 0.2);
			var enemies:Vector.<CitrusObject> = getObjectsByType(ExEnemy);
			var enemy:CitrusObject;
			for each (enemy in enemies) {
				_debugSprite.graphics.drawRect((enemy as ExEnemy).x - (enemy as ExEnemy).width / 2, (enemy as ExEnemy).y - (enemy as ExEnemy).height / 2, (enemy as ExEnemy).width, (enemy as ExEnemy).height);
			}
		}
		
		
		private function redrawLevel(type:String):void {
			
			var heroPos:Point = new Point(Math.floor(_hero.x/_tileSize), Math.floor(_hero.y/_tileSize));
			for each (var object:CitrusObject in objects) { // remove old platforms
				if (object is Platform) {
					object.kill = true; 
					remove(object);
				}
			}
			
			if(type == "cave"){
				//mapH = 40;
				//mapW = 70;
				_lvl = CaveGenerator.createlevel(_mapW, _mapH, heroPos, _hero);
			} else if (type == "mario") {
				//mapH = 40;
				//mapW = 200;
				_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, Functions.randomIntRange(1,10), 1, heroPos, _hero);
			}
			
//			_camera.bounds = new Rectangle(0, 0, mapW*tileSize, mapH*tileSize); 
			_lvl.drawMapPlaftormsToGameState(this, _tileSize, _gameData.levelColor, false, heroPos);
			
			var heroContactList : b2ContactEdge = _hero.body.GetContactList(); // Force begin contact, with new platform.. otherwise is doesn't and then.. you can't jump
			if (heroContactList) for (var contact: b2Contact = _hero.body.GetContactList().contact ; contact ; contact = contact.GetNext())  _hero.handleBeginContact(contact);
			
			// DO PLACE ENEMIES BACK IF THERE ARE ANY IN THE STATE
			if (getObjectsByType(EdgeDetectorEnemy).length > 0) {
				_lvl.placeEnemies(this, _gameData.enemyPercentage, heroPos);// replace enemies
				_gameData.totalEnemies = _lvl.getTotalEnemiesAmount; // save total enemies for the enemy kill counter
			}
			
			if (getObjectsByType(StaticTrap).length > 0) {
				_lvl.placeStaticTraps(this, _gameData.trapPercantage, heroPos);
			}
			
		}	
		
		
		private function changeObjectShape():void {
			
			if (_gameData.currentStyling == "hero") {
				var object : ExBox2DPhysicsObject = getObjectByName("hero") as ExBox2DPhysicsObject;
				object.currentShape = _gameData.currentShape;
				
				var body: b2Body = object.getBody() as b2Body;
				var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
				var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
				
				switch (object.currentShape){
					case Shapes.CIRCLE:
						object.view = StarlingShape.Circle(width, object.currentColor);
						break;
					case Shapes.HEXAGON:
						object.view = StarlingShape.polygon(width, 6, object.currentColor);
						break;
					case Shapes.RECTANGLE:
						object.view = StarlingShape.Rectangle(width, height, object.currentColor);
						break;
					case Shapes.TRIANGLE:
						object.view = StarlingShape.Triangle(width, height, object.currentColor);
						break;
				}	
			}
			else if (_gameData.currentStyling == "enemies") {
				for each (var test :CitrusObject in objects) {
					if (test is ExEnemy) {
						var enemy : ExEnemy = test as ExEnemy;
	
						enemy.currentShape = _gameData.currentShape;	
						var width = enemy.width;
						var height = enemy.height;
						
						switch (enemy.currentShape){
							case Shapes.CIRCLE:
								enemy.view = StarlingShape.Circle(width, enemy.currentColor);
								break;
							case Shapes.HEXAGON:
								enemy.view = StarlingShape.polygon(width, 6, enemy.currentColor);
								break;
							case Shapes.RECTANGLE:
								enemy.view = StarlingShape.Rectangle(width, height, enemy.currentColor);
								break;
							case Shapes.TRIANGLE:
								enemy.view = StarlingShape.Triangle(width, height, enemy.currentColor);
								break;
						}
					}
				}
			}
			
			
		}
		
		
		private function changeObjectColor(name : String , red : int, green : int, blue : int):void{
			var hex:uint = red << 16 | green << 8 | blue;
			
			if (name == "platform") {
				_gameData.levelColor = hex;
				_lvl.drawQuadMap(this, _tileSize, hex);
				return;
			} else if ( name == "bg") {
				stage.color = hex;
				return;
			}
			
			
			if (name == "hero") { 
				var object : ExBox2DPhysicsObject = getObjectByName(name) as ExBox2DPhysicsObject;
				object.currentColor = hex;
				var body: b2Body = object.getBody() as b2Body;
				var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
				var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
				
				switch (object.currentShape){
					case Shapes.CIRCLE:
						object.view = StarlingShape.Circle(width, object.currentColor);
						break;
					case Shapes.HEXAGON:
						object.view = StarlingShape.polygon(width, 6, object.currentColor);
						break;
					case Shapes.RECTANGLE:
						object.view = StarlingShape.Rectangle(width, height, object.currentColor);
						break;
					case Shapes.TRIANGLE:
						object.view = StarlingShape.Triangle(width, height, object.currentColor);
						break;
				}
			}
			
			if (name == "enemies") {
				for each (var enemyObj :CitrusObject in objects) {
					if (enemyObj is ExEnemy) {
						var enemy : ExEnemy = enemyObj as ExEnemy;
						enemy.currentColor = hex;
						
						var width = enemy.width;
						var height = enemy.height;
						
						switch (enemy.currentShape){
							case Shapes.CIRCLE:
								enemy.view = StarlingShape.Circle(width, enemy.currentColor);
								break;
							case Shapes.HEXAGON:
								enemy.view = StarlingShape.polygon(width, 6, enemy.currentColor);
								break;
							case Shapes.RECTANGLE:
								enemy.view = StarlingShape.Rectangle(width, height, enemy.currentColor);
								break;
							case Shapes.TRIANGLE:
								enemy.view = StarlingShape.Triangle(width, height, enemy.currentColor);
								break;
						}
					}
				}
			}
			
			
		}

		
		
		
			
			
	
	}
}