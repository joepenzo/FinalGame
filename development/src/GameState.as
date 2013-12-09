package
{
	import citrus.core.starling.StarlingState;
	import citrus.physics.box2d.Box2D;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import flash.geom.Point;
	
	import generators.MarioGenerator;
	
	import objects.ExHero;
	import flash.geom.Rectangle;
	
	public class GameState extends StarlingState
	{
		private var tileSize:int = 32;
		private var _mapW:int = 100;
		private var _mapH:int = 40;
		
		
		private var _box2D:Box2D;
		private var _lvl:Level;
		private var _camera:ACitrusCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			
			
			_box2D = new Box2D("box2D");
			_box2D.visible = true;
			add(_box2D);
			
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 1234, 0, 0);
//			lvl = CaveGenerator.createlevel(mapW, mapH);
			_lvl.drawMapPlaftormsToGameState(this, tileSize);
			
			var heroPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {x:heroPos.x * tileSize, y:heroPos.y* tileSize, width:tileSize/2, height: tileSize/2, doubleJumpEnabled: true});
			add(_hero);
			
			_bounds = new Rectangle(0, 0, _mapW*tileSize, _mapH*tileSize);

			_camera = view.camera as StarlingCamera;
			_camera.setUp(_hero, new Point(stage.stageWidth/2-200, stage.stageHeight/2-70), _bounds, new Point(.5, .5));
			_camera.allowRotation = true;
			_camera.allowZoom = true;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
//			_camera.setZoom(2);
			_camera.rotationEasing = .3;
			_camera.zoomEasing = .1;
			
//			_camera.setZoom(10);
			
			
		}

	}
}