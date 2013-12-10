package
{
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
	
	import generators.CaveGenerator;
	import generators.MarioGenerator;
	
	import objects.ExBox2DPhysicsObject;
	import objects.ExHero;
	import objects.Level;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Shape;
	
	import utils.FlashShape;
	import utils.Functions;
	import utils.StarlingDraw;
	import utils.StarlingShape;
	import Box2D.Dynamics.b2Body;
	
	public class GameState extends StarlingState
	{
		private var tileSize:int = 32;
		private var _mapW:int = 100;
		private var _mapH:int = 40;
		
		
		private var _box2D:Box2D;
		private var _lvl:Level;
		private var _camera:StarlingCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		private var _debugSprite:flash.display.Sprite;
		private var _gameData:GameData;
		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			_gameData = _ce.gameData as GameData;

			
			_box2D = new Box2D("box2D");
			_box2D.visible = false;
			add(_box2D);
			
			_mapW = 150;
			_mapH = 25;
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1);

//			_mapW = 100;
//			_mapH = 50;			
//			_lvl = CaveGenerator.createlevel(_mapW, _mapH);
		
			_lvl.drawMapPlaftormsToGameState(this, tileSize);
			
			
			var heroPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {x:heroPos.x * tileSize, y:heroPos.y* tileSize, width:tileSize/2, height: tileSize/2, doubleJumpEnabled: true});
			_hero.currentColor = 0x000050;
			_hero.currentShape = Shapes.HEXAGON
			_hero.view = StarlingShape.polygon(_hero.width, 6, _hero.currentColor);
			add(_hero);
			
			_bounds = new Rectangle(0, 0, _mapW*tileSize, _mapH*tileSize);
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
			
		
			// GRAVITY - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_GRAVITY)) {
				var action:InputAction = _ce.input.getAction(Actions.VALUE_GRAVITY) as InputAction;
				_box2D.gravity.Set(0, action.value); 
			}
			// ZOOM - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_ZOOM)) {
				action = _ce.input.getAction(Actions.VALUE_ZOOM) as InputAction;
				debug(action.value);
				_camera.setZoom(action.value);
			}
			// HERO SIZE - CHANGE
			if(_ce.input.isDoing(Actions.HERO_SIZE)) {
				action = _ce.input.getAction(Actions.HERO_SIZE) as InputAction;
				Functions.ResizeObjectValue(this, action.value/30/2, action.value/30/2, "hero");
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
				_lvl.drawQuadMap(this, tileSize, hex);
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