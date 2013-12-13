package objects
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	
	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	
	import flash.geom.Point;

	public class EdgeDetectorEnemy extends ExEnemy
	{
		
		private var _tile:Point;

		protected var _leftEdgeSensorShape:b2PolygonShape;
		protected var _rightEdgeSensorShape:b2PolygonShape;
		
		protected var _leftEdgeSensorFixture:b2Fixture;
		protected var _rightEdgeSensorFixture:b2Fixture;
		
		public function EdgeDetectorEnemy(name:String, enemyColor : uint, params:Object=null, tile : Point = null)
		{
			super(name, params);
			_tile = tile;
			currentColor = enemyColor;
			_endContactCallEnabled = true;
			_preContactCallEnabled = true;
			hurtDuration = 0;
			
			if (Math.random() < .5) {
				startingDirection = "left";
				_inverted = true;
			} else {
				startingDirection = "right";
				_inverted = false;
			}
		

		}
		
		override protected function createShape():void {
			super.createShape();

			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = wallSensorHeight / _box2D.scale;
			var sensorOffset:b2Vec2 = new b2Vec2((sensorWidth / 2) - _width/2 + sensorWidth, _height - (wallSensorOffset / _box2D.scale));
			
			_leftEdgeSensorShape = new b2PolygonShape();
			_leftEdgeSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightEdgeSensorShape = new b2PolygonShape();
			_rightEdgeSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.restitution = 0;
			_fixtureDef.friction = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items","BadGuys");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			_sensorFixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_sensorFixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items","BadGuys");
			
		}
		
		override protected function createFixture():void {
			super.createFixture();

			_sensorFixtureDef.shape = _leftEdgeSensorShape;
			_leftEdgeSensorFixture = body.CreateFixture(_sensorFixtureDef);
			
			_sensorFixtureDef.shape = _rightEdgeSensorShape;
			_rightEdgeSensorFixture = body.CreateFixture(_sensorFixtureDef);
			
			
		}
		
		
		override public function handleEndContact(contact:b2Contact):void {
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			if (contact.GetFixtureA() == _leftEdgeSensorFixture ||  contact.GetFixtureA() == _rightEdgeSensorFixture) {
				if (contact.GetManifold().m_localPoint) {
					var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
					var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
					if ((collider is Platform && collisionAngle != 90) || collider is ExEnemy) turnAround();
				}
			}
			
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (contact.GetFixtureA() == _leftEdgeSensorFixture ||  contact.GetFixtureA() == _rightEdgeSensorFixture) return;
		
			if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();
			if (_body.GetLinearVelocity().x < 0 && (contact.GetFixtureA() == _rightSensorFixture || contact.GetFixtureB() == _rightSensorFixture))
				return;
			
			if (_body.GetLinearVelocity().x > 0 && (contact.GetFixtureA() == _leftSensorFixture || contact.GetFixtureB() == _leftSensorFixture))
				return;
			
			if (contact.GetManifold().m_localPoint) {
				
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				
				if ((collider is Platform && collisionAngle != 90) || collider is ExEnemy)
					turnAround();
			}
			
		}
		
	}
}