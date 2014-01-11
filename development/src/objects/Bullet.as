package objects
{
	import citrus.objects.platformer.box2d.Missile;
	import citrus.physics.PhysicsCollisionCategories;
	
	public class Bullet extends Missile
	{
		public function Bullet(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Traps");
		}
		
	}
}