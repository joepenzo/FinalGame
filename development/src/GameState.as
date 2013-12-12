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
	import data.consts.Actions;
	import data.consts.Shapes;
	
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
	import objects.Level;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Shape;
	
	import utils.FlashShape;
	import utils.Functions;
	import utils.StarlingDraw;
	import utils.StarlingShape;
	
	public class GameState extends StarlingState
	{
		private var _gameData:GameData;

		private var _tileSize:int = 32;
		private var _mapW:int = 100;
		private var _mapH:int = 40;
		
		
		private var _box2D:Box2D;
		private var _lvl:Level;
		private var _camera:StarlingCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		private var _debugSprite:flash.display.Sprite;
		private var ENEMY_AMOUNT_INTERVAL:Number = new Number();
		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			_gameData = _ce.gameData as GameData;

			
			_box2D = new Box2D("box2D");
			_box2D.visible = false;
			add(_box2D);
			
			_mapW = 50;//_mapW = 150;
			_mapH = 25;
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1);

//			_mapW = 100;
//			_mapH = 50;			
//			_lvl = CaveGenerator.createlevel(_mapW, _mapH);
			
			_lvl.drawMapPlaftormsToGameState(this, _tileSize);
			
			
			var heroStartPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {x:heroStartPos.x * _tileSize, y:heroStartPos.y* _tileSize, width:_tileSize/2, height: _tileSize/2, doubleJumpEnabled: true});
			_hero.currentColor = 0x000050;
			_hero.currentShape = Shapes.RECTANGLE;
			_hero.view = StarlingShape.Rectangle(_hero.width, _hero.height, _hero.currentColor);
			add(_hero);
		
			
//			var enemyX : int = _hero.x + 50;
//			var enemyY : int = _hero.y;
//			add(new EdgeDetectorEnemy("enemy-test", {speed: .8, x : enemyX , y : enemyY, width: 15, height: 20,
//				//view : StarlingShape.Rectangle(20,20, 0x00ff00),
//				leftBound: enemyX - 5, // TILESIZE INSTEAD 
//				rightBound: enemyX + 5 
//			}));
			
			_bounds = new Rectangle(0, 0, _mapW*_tileSize, _mapH*_tileSize);
			_camera = view.camera as StarlingCamera;
			_camera.setUp(_hero, new Point(stage.stageWidth/2, stage.stageHeight/2), _bounds, new Point(.5, .5));
			_camera.allowRotation = true;
			_camera.allowZoom = true;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			_camera.rotationEasing = .3;
			_camera.zoomEasing = .1;
			_camera.setZoom(3);
			
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
			
			
		}
		
		private function drawPlatformsToMiniMap():void{
			_debugSprite.graphics.lineStyle();
			_debugSprite.graphics.beginFill(0x000000, 0.2);
			var platforms:Vector.<CitrusObject> = getObjectsByType(Platform);
			var platfrm:CitrusObject;
			for each (platfrm in platforms) {
				_debugSprite.graphics.drawRect((platfrm as Platform).x - (platfrm as Platform).width / 2, (platfrm as Platform).y - (platfrm as Platform).height / 2, (platfrm as Platform).width, (platfrm as Platform).height);
			}
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			//camera render debug 
			_camera.renderDebug(_debugSprite as flash.display.Sprite)
			drawPlatformsToMiniMap();

			
			
			// PLATFORM LEVEL - CHANGE
			if(_ce.input.justDid(Actions.CHANGE_LVL_MARIO)) {
				var action:InputAction = _ce.input.getAction(Actions.CHANGE_LVL_MARIO) as InputAction;
				redrawLevel("mario");
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

			
			// ENEMY AMOUND - CHANGE
			if(_ce.input.hasDone(Actions.ENEMY_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.ENEMY_PERCANTAGE) as InputAction;
				_gameData.enemyPercentage = action.value;			
				
				clearTimeout(ENEMY_AMOUNT_INTERVAL);
				ENEMY_AMOUNT_INTERVAL = setTimeout(myDelayedFunction, 100, this, action);
				function myDelayedFunction(state : StarlingState, action : InputAction):void { // Kills the input after no change
					_lvl.placeEnemies(state, _gameData.enemyPercentage);
				}
				
			
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
			
			if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_HERO)) {
				_gameData.currentStyling = "hero";
			} if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_BG)) {
				_gameData.currentStyling = "bg";
			} if (_ce.input.justDid(Actions.SELECTED_COLOROBJ_PLAT)) {
				_gameData.currentStyling = "platform";
			} 
			
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
				_lvl = CaveGenerator.createlevel(_mapW, _mapH, heroPos);
			} else if (type == "mario") {
				//mapH = 40;
				//mapW = 200;
				_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1, heroPos, _hero);
			}
			
//			_camera.bounds = new Rectangle(0, 0, mapW*tileSize, mapH*tileSize); 
			_lvl.drawMapPlaftormsToGameState(this, _tileSize, _gameData.levelColor);
			
			var heroContactList : b2ContactEdge = _hero.body.GetContactList(); // Force begin contact, with new platform.. otherwise is doesn't and then.. you can't jump
			if (heroContactList) for (var contact: b2Contact = _hero.body.GetContactList().contact ; contact ; contact = contact.GetNext())  _hero.handleBeginContact(contact);
			
			// DO PLACE ENEMIES FUNCTIES IF THERE ARE ANY IN THE STATE
			if (getObjectsByType(EdgeDetectorEnemy).length > 0) _lvl.placeEnemies(this, _gameData.enemyPercentage);
			
			
		}	
		
		
		private function changeObjectShape():void {
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
			
			
			
			if (getObjectByName(name)) { 
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

				
				//var view : QuadBatch = object.view as QuadBatch;
				//view.setQuadColor(0,hex);
			}
		}

		
		
		
			
			
	
	}
}