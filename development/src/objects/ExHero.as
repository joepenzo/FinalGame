package objects {
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Fixture;
	
	import citrus.input.controllers.Keyboard;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Missile;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.utils.AGameData;
	
	import data.consts.Actions;
	
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Shape;
	
	import utils.StarlingShape;

	//import data.Sounds;
	
	/**
	 * @author joepsuijkerbuijk
	 */
	
	
	
	public class ExHero extends ExBox2DPhysicsObject
	{
		//properties
		/**
		 * This is the rate at which the hero speeds up when you move him left and right. 
		 */
		[Inspectable(defaultValue="1")]
		public var acceleration:Number = 1;
		
		/**
		 * This is the fastest speed that the hero can move left or right. 
		 */
		[Inspectable(defaultValue="8")]
		public var maxVelocity:Number = 8;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Inspectable(defaultValue="11")]
		public var jumpHeight:Number = 11;
		
		/**
		 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		 */
		[Inspectable(defaultValue="0.3")]
		public var jumpAcceleration:Number = 0.3;
		
		/**
		 * This is the y velocity that the hero must be travelling in order to kill an Enemy.
		 */
		[Inspectable(defaultValue="3")]
		public var killVelocity:Number = 3;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy. 
		 */
		[Inspectable(defaultValue="8")]
		public var enemySpringHeight:Number = 8;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
		 */
		[Inspectable(defaultValue="9")]
		public var enemySpringJumpHeight:Number = 9;
		
		/**
		 * How long the hero is in hurt mode for. 
		 */
		[Inspectable(defaultValue="1000")]
		public var hurtDuration:Number = 1000;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="6")]
		public var hurtVelocityX:Number = 6;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="10")]
		public var hurtVelocityY:Number = 10;
		
		/**
		 * Determines whether or not the hero's ducking ability is enabled.
		 */
		[Inspectable(defaultValue="true")]
		public var canDuck:Boolean = true;
		
		/**
		 * Defines which input Channel to listen to.
		 */
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;
		
		//events
		/**
		 * Dispatched whenever the hero jumps. 
		 */
		public var onJump:Signal;
		
		/**
		 * Dispatched whenever the hero gives damage to an enemy. 
		 */		
		public var onGiveDamage:Signal;
		
		/**
		 * Dispatched whenever the hero takes damage from an enemy. 
		 */		
		public var onTakeDamage:Signal;
		
		/**
		 * Dispatched whenever the hero's animation changes. 
		 */		
		public var onAnimationChange:Signal;

//		private var _gameData: GameData;
		
		protected var _groundContacts:Array = [];//Used to determine if he is on ground or not.
		protected var _enemyClass:Class = Enemy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:Number;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _ducking:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		private var _mayDoubleJump:Boolean;
		private var _bulletcounter:int=0;
		private var _bulletGraphic:Shape;
		

		
		public var shootingEnabled : Boolean = true;
		public var jumpType : String = "Single"; // Single, Double, Unlimited, Jetpack
		
		public var round : Boolean  = false;
		public var invertMovement : Boolean = false;

		

		/**
		 * Creates a new hero object.
		 */		
		
		public function ExHero(name : String, params : Object = null) {
			updateCallEnabled = true;
			_preContactCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
			
			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();

			//_gameData = _ce.gameData as GameData;
			//_sounds = _gameData.synthSounds;
			_ce.input.keyboard.addKeyAction(Actions.JUMP,Keyboard.UP);
		
			_ce.input.keyboard.addKeyAction(Actions.SHOOT,Keyboard.COMMAND);
			_ce.input.keyboard.addKeyAction(Actions.SHOOT,Keyboard.CTRL);
		}

		override public function destroy():void
		{
			clearTimeout(_hurtTimeoutID);
			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			
			super.destroy();
		}
		
		/**
		 * Whether or not the player can move and jump with the hero. 
		 */	
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				_fixture.SetFriction(_friction);
		}
		
		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */		
		public function get onGround():Boolean
		{
			return _onGround;
		}
		
		/**
		 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the hero's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Enemy" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.Enemy", or Enemy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="com.citrusengine.objects.platformer.box2d.Enemy",type="String")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the hero will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get friction():Number
		{
			return _friction;
		}
		
		[Inspectable(defaultValue="0.75")]
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_fixture)
			{
				_fixture.SetFriction(_friction);
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDoing("duck",inputChannel) && _onGround && canDuck);
				
				if (_ce.input.isDoing(Actions.RIGHT,inputChannel) && !_ducking)
				{
					if (!invertMovement) {
						velocity.Add(getSlopeBasedMoveAngle());
					} else {
						velocity.Subtract(getSlopeBasedMoveAngle());
					}
					
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing(Actions.LEFT,inputChannel) && !_ducking)
				{
					if (!invertMovement) {
						velocity.Subtract(getSlopeBasedMoveAngle());
					} else {
						velocity.Add(getSlopeBasedMoveAngle());
					}
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
					//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				switch (jumpType){
					case "Single":
						if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking) {
							velocity.y = -jumpHeight;
							onJump.dispatch();
							_onGround = false; // also removed in the handleEndContact. Useful here if permanent contact e.g. box on hero.
						}
						
						if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0) velocity.y -= jumpAcceleration;
						break;
					case "Double":
						if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking) {
							velocity.y = -jumpHeight;
							onJump.dispatch();
							_onGround = false; // also removed in the handleEndContact. Useful here if permanent contact e.g. box on hero.
							_mayDoubleJump = true;
						} else if (!_onGround && _mayDoubleJump && _ce.input.justDid("jump", inputChannel)) {
							velocity.y = -jumpHeight;
							onJump.dispatch();
							_mayDoubleJump = false;
						}
						if (_onGround) _mayDoubleJump = false;
						
						break;
					case "Unlimited":
						if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking) {
							velocity.y = -jumpHeight;
							onJump.dispatch();
							_onGround = false; // also removed in the handleEndContact. Useful here if permanent contact e.g. box on hero.
						}
						// INAIR AND HOLDING JUMP
						if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0) velocity.y -= jumpAcceleration;
						if ( !_onGround && _ce.input.justDid("jump", inputChannel)) {
							velocity.y = -jumpHeight;
							onJump.dispatch();
						}
						break;
					case "Jetpack":
						if (_ce.input.isDoing("jump", inputChannel)) {
							velocity.y -= 1;
						}
						break;
				}
				
				// JUMPOFF ENEMY
				if (_springOffEnemy != -1) {
					if (_ce.input.isDoing("jump", inputChannel))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
			
				
				//The Shooting ability - IF SHOOTING IS ENABLED
 				if (shootingEnabled && _ce.input.justDid(Actions.SHOOT)) {
					var bullet:Missile;
					if (_inverted) {
						bullet = new Missile("bullet"+_bulletcounter, {x:x -width, y:y, width:3, height:3, speed:30, explodeDuration:200, fuseDuration: 5000, angle:180});
					} else {
						bullet = new Missile("bullet"+_bulletcounter, {x:x + width, y:y, width:3, height:3, speed:30, explodeDuration:200, fuseDuration: 5000, angle:0});
					}
					bullet.onExplode.add(handleBulletExplode);
					bullet.view = StarlingShape.Rectangle(3,3,0x000000);
					_bulletcounter++
					_ce.state.add(bullet);
				}
				// END SHOOTING
				
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.SetLinearVelocity(velocity);
			}
			
			updateAnimation();
		}
		
		private function handleBulletExplode(bullet:Missile,collidedObject:Box2DPhysicsObject):void {
			if (collidedObject.name == "enemy") {
				var enemy :ExEnemy = collidedObject as ExEnemy;
				enemy.hurt();
			}
			
		}		
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _body.GetLinearVelocity().x - groundVelocityX;
		}

		/**
		 * Hurts the hero, disables his controls for a little bit, and dispatches the onTakeDamage signal. 
		 */		
		public function hurt():void
		{
			_hurt = true;
			controlsEnabled = false;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			onTakeDamage.dispatch();
			
			//Makes sure that the hero is not frictionless while his control is disabled
			if (_playerMovingHero)
			{
				_playerMovingHero = false;
				_fixture.SetFriction(_friction);
			}
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function createShape():void {
			if (round == true) {
				_shape = Box2DShapeMaker.Circle(width * 0.0325, height * 0.03);
				body.SetFixedRotation(false);
			} else {
				_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
			}
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			if (!_ducking)
				return;
			
			var other:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				contact.SetEnabled(false);
		}

		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (_enemyClass && collider is _enemyClass)
			{
				if (_body.GetLinearVelocity().y < killVelocity && !_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.SetLinearVelocity(hurtVelocity);
				}
				else
				{
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}
			}
			
			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor) ) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{	
				if(contact.normal == null) return; // BUG FIX? // ON LEVEL RELOAD WHEN TOUCHED OR TOUCHING ENEMY
				var collisionAngle:Number = Math.atan2(contact.normal.y, contact.normal.x);
				
				if (collisionAngle >= Math.PI*.25 && collisionAngle <= 3*Math.PI*.25 ) // normal angle between pi/4 and 3pi/4
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		override public function handleEndContact(contact:b2Contact):void {
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function getSlopeBasedMoveAngle():b2Vec2
		{
			return Box2DUtils.Rotateb2Vec2(new b2Vec2(acceleration, 0), _combinedGroundAngle);
		}
		
		protected function updateCombinedGroundAngle():void
		{
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _groundContacts) {
				
				var angle:Number = contact.GetBody().GetAngle();
				var turn:Number = 45 * Math.PI / 180;
				angle = angle % turn;
				_combinedGroundAngle += angle;
			}
			
			_combinedGroundAngle /= _groundContacts.length;
		}
		
		protected function endHurtState():void {
			
			_hurt = false;
			controlsEnabled = true;
		}
		
		protected function updateAnimation():void {
			
			var prevAnimation:String = _animation;
			
			var walkingSpeed:Number = getWalkingSpeed();
			
			if (_hurt)
				_animation = "hurt";
				
			else if (!_onGround) {
				
				_animation = "jump";

				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
				
			} else if (_ducking)
				_animation = "duck";
			
				
			else {
				
				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";
					
				} else if (walkingSpeed > acceleration) {
					
					_inverted = false;
					_animation = "walk";
					
				} else
					_animation = "idle";
			}
			
			if (prevAnimation != _animation)
				onAnimationChange.dispatch();
		}
		
		public function get _invertMovement() : Boolean {
			return invertMovement;
		}
		
		public function set _invertMovement(invertMovement : Boolean) : void {
			this.invertMovement = invertMovement;
		}
	}

}