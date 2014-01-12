package objects
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.objects.platformer.box2d.Hero;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	
	import data.GameData;

	public class Trampoline extends ExSensor
	{
		private var _gameData:GameData;

		public function Trampoline(name:String, params:Object=null){
			super(name, params);
			currentColor = params.currentColor;
			_gameData = _ce.gameData as GameData;

		}
		
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is ExHero) {
				collider.body.ApplyImpulse(new b2Vec2(0,-_gameData.trampolineBoost), new b2Vec2(0,0));
			}
			
		
		}
		
	}
}