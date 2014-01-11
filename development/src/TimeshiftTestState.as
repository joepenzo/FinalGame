package
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingState;
	import citrus.input.InputAction;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.MovingPlatform;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.utils.AGameData;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import objects.ExBox2DPhysicsObject;
	import objects.ExHero;
	import starling.display.Shape;
	

	public class TimeshiftTestState extends StarlingState
	{
		private var INTERVAL:Number = new Number();

		private var _tileSize:int = 32; // 32 
		
		private var _box2D:Box2D;
		private var _camera:StarlingCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		
		private var _timeshifter:TimeShifter;

		
		public function TimeshiftTestState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			
			_box2D = new Box2D("box2D");
			_box2D.visible = true;
			add(_box2D);
			
			add(new Platform("", {x:500, y:400, width:1000,height:20, view : StarlingDrawRectangle(1000,20, 0xc0ffee) }));
		
			_hero = new ExHero("hero", { group:3, x:100,  y:100,  width:_tileSize/2,  height: _tileSize/2 });
			_hero.currentColor = 0x000050;
			_hero.currentShape = "RECT"; // normaly this comes from a static const class. like Shapes.RECTANGLE or Shapec.HEXAGON
			_hero.jumpHeight = _tileSize*.225;
			_hero.view = StarlingDrawRectangle(_hero.width, _hero.height, _hero.currentColor);
			add(_hero);

			
//			_bounds = new Rectangle(0, 0, _mapW*_tileSize, _mapH*_tileSize);
//			_camera = view.camera as StarlingCamera;
//			_camera.setUp(_hero, new Point(stage.stageWidth/2, stage.stageHeight/2), _bounds, new Point(.5, .5));
//			_camera.allowRotation = true;
//			_camera.allowZoom = true;
//			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
//			_camera.rotationEasing = .3;
//			_camera.zoomEasing = .1;
//			_camera.setZoom(2);
		
			_timeshifter = new TimeShifter(5);
			_timeshifter.addBufferSet( { object: _hero, continuous:["x","y"]});//			_timeshifter.addBufferSet( { object: _hero, continuous:["x","y"], discrete: ["rotation", "currentColor"]}); 
			
			_timeshifter.onActivated.add(function():void {
				_hero.body.SetActive(false);
			});
			_timeshifter.onDeactivated.add(function():void {
				_hero.body.SetActive(true);
			});
			
			
	
			_ce.input.keyboard.addKeyAction("heroDie",Keyboard.Q); // DO TIMESHIFT
			
			_ce.input.keyboard.addKeyAction("grow",Keyboard.NUMBER_1);
			_ce.input.keyboard.addKeyAction("shrink",Keyboard.NUMBER_2);
			
			_ce.input.keyboard.addKeyAction("changeColor",Keyboard.NUMBER_3);
		}
		
	
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
		
			if (_ce.input.justDid("heroDie")) {
				_timeshifter.startRewind(0,.8);
			}
						
			
			if (_ce.input.isDoing("grow")) {
				var hero : ExHero = getObjectByName("hero") as ExHero;
				var width : Number = (hero.body.GetFixtureList().GetAABB().upperBound.x - hero.body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
				if (width <= 100) ResizeObject(this, true, "hero"); 
			} else if (_ce.input.isDoing("shrink")) {
				hero = getObjectByName("hero") as ExHero;
				width = (hero.body.GetFixtureList().GetAABB().upperBound.x - hero.body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
				if (width >= 10) ResizeObject(this, false, "hero");
			}  
			
			if (_ce.input.isDoing("changeColor")) {
				changeHeroObjectColor("hero", randomRange(0,255),randomRange(0,255),randomRange(0,255));
			}
			
			
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number  {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		private  function ResizeObject(state : StarlingState, scaleUp : Boolean, objectName : String, reDrawView : Boolean = true) : void { // Works for rectangle shape now
			// TODO :: if  hero is standing on top of the object, shit get's fucked up!
			var mult : Number;
			if (scaleUp) {
				mult = 1.05;
			} else {
				mult = .95;
			}
			var object : Box2DPhysicsObject = state.getObjectByName(objectName) as Box2DPhysicsObject;
			var body : b2Body = object.getBody() as b2Body;
			
			var oldPolygon : b2PolygonShape = body.GetFixtureList().GetShape() as b2PolygonShape;
			var vertexArray : Vector.<b2Vec2> = oldPolygon.GetVertices() as Vector.<b2Vec2>;
			for each (var vert:b2Vec2 in vertexArray) {
				vert.Multiply(mult);
			}
			
			var newShape : b2PolygonShape = new b2PolygonShape();
			newShape.SetAsVector(vertexArray);
			
			body.DestroyFixture(body.GetFixtureList());
			body.CreateFixture2(newShape); // TODO: Add density?
			
			if (reDrawView) {
				var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
				var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
				object.view = StarlingDrawRectangle(width,height, 0x2E2E2E);
			}
			
		}
		
		private function StarlingDrawRectangle(width : int, height : int, color : uint, stroked : Boolean = false, strokeW : int = 2, strokeC : uint = 0xC0FFEE) : Shape {
			var shape: Shape = new Shape();
			
			if(stroked) shape.graphics.lineStyle(strokeW, strokeC);
			
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0,width, height);
			shape.graphics.endFill();
			return shape;
		}
		
	
		
		private function changeHeroObjectColor(name : String , red : int, green : int, blue : int):void{
			
			var hex:uint = red << 16 | green << 8 | blue;
			
			var object : ExBox2DPhysicsObject = getObjectByName(name) as ExBox2DPhysicsObject;
			object.currentColor = hex;
			var body: b2Body = object.getBody() as b2Body;
			var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
			var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
//				var height : Number = _tileSize/2;
//				var width : Number = _tileSize/2;
			
			object.view = StarlingDrawRectangle(width, height, object.currentColor);
		}

		
		
		
			
			
	
	}
}