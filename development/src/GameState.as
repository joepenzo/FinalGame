package
{
	import citrus.core.starling.StarlingState;
	import citrus.physics.box2d.Box2D;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import generators.CaveGenerator;
	import generators.MarioGenerator;
	
	import objects.ExHero;
	import citrus.core.CitrusObject;
	import citrus.objects.platformer.box2d.Platform;
	
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
		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			
			
			
			_box2D = new Box2D("box2D");
			_box2D.visible = true;
			add(_box2D);
			
			_mapW = 150;
			_mapH = 25;
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1);

//			_mapW = 100;
//			_mapH = 40;			
//			_lvl = CaveGenerator.createlevel(_mapW, _mapH);
			_lvl.drawMapPlaftormsToGameState(this, tileSize);
			
			var heroPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {x:heroPos.x * tileSize, y:heroPos.y* tileSize, width:tileSize/2, height: tileSize/2, doubleJumpEnabled: true});
			add(_hero);
			
			_bounds = new Rectangle(0, 0, _mapW*tileSize, _mapH*tileSize);
			
			_camera = view.camera as StarlingCamera;
			_camera.setUp(_hero, new Point(stage.stageWidth/2, stage.stageHeight/2), _bounds, new Point(.5, .5));
			_camera.allowRotation = true;
			_camera.allowZoom = true;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			_camera.setZoom(1.8);
			_camera.rotationEasing = .3;
			_camera.zoomEasing = .1;
			
			
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
			
				
		}

	}
}