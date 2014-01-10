package objects
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Missile;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.utils.AGameData;
	
	import data.GameData;
	import data.types.Goals;
	
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import starling.display.Shape;

	
	public class EdgeDetectorEnemy extends ExEnemy
	{
		
		
//		[Inspectable(defaultValue="1.3")]
//		public var speed:Number = 1.3;
//		
//		[Inspectable(defaultValue="3")]
//		public var enemyKillVelocity:Number = 3;
//		
//		[Inspectable(defaultValue="left",enumeration="left,right")]
//		public var startingDirection:String = "left";
//		
//		[Inspectable(defaultValue="0")]
//		public var hurtDuration:Number = 0;
//		
//		[Inspectable(defaultValue="-100000")]
//		public var leftBound:Number = -100000;
//		
//		[Inspectable(defaultValue="100000")]
//		public var rightBound:Number = 100000;
//		
//		[Inspectable(defaultValue="10")]
//		public var wallSensorOffset:Number = 10;
//		
//		[Inspectable(defaultValue="2")]
//		public var wallSensorWidth:Number = 2;
//		
//		[Inspectable(defaultValue="2")]
//		public var wallSensorHeight:Number = 2;
//		
//		protected var _hurtTimeoutID:uint = 0;
//		protected var _hurt:Boolean = false;
//		protected var _enemyClass:* = ExHero;
		
		private var _gameData:GameData;
		
		private var _tile:Point;	
		private var _updatedBounds : Boolean = false;
		
		public function EdgeDetectorEnemy(name:String, enemyColor : uint, params:Object=null, tile : Point = null)
		{
			super(name, params);
			_gameData = _ce.gameData as GameData;
			
			hurtDuration = 0;
			_tile = tile;
			currentColor = enemyColor;

			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			
			
			startingDirection = (Math.random() > .5) ? "left" : "right";
			if (startingDirection == "left") _inverted = true;
			
			
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			var position:b2Vec2 = _body.GetPosition();
		
			//Turn around when they pass their left/right bounds
			if ((_inverted && position.x * _box2D.scale < leftBound) || (!_inverted && position.x * _box2D.scale > rightBound)) turnAround();
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
 			if (!_hurt) {
				velocity.x = _inverted ? -speed : speed;
			} else {
				velocity.x = 0;
			}
			
			//updateAnimation();
		}
		
		
		override protected function createBody():void
		{
			super.createBody();
			_body.SetFixedRotation(true);
		}
		
		override protected function createShape():void {
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.density = 10;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items","BadGuys");
		}
		
		
		override protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
			
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();
			
			if (contact.GetManifold().m_localPoint) {
				
				if ((collider is Platform)) {
					var platform:Platform = Platform(collider);
					var angle:Number = platform.body.GetAngle();
					if (angle == 0) turnAround();
				}
				
				/* 
				do this only once
				calculates size and position off the platform to set the bounds for the enemy
				*/
				if ((collider is Platform) && !_updatedBounds) { 
					_updatedBounds = true;
					var platform : Platform = collider as Platform;
					leftBound = (platform.x - platform.width/2) + width/2;
					rightBound = (platform.x + platform.width/2) - width/2;
				}
				
			}
			
		}
		
		
		
		
		
	}
}