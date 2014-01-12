package objects
{
	import citrus.physics.PhysicsCollisionCategories;
	
	import flash.geom.Point;
	
	public class StaticTrap extends ExPlatform
	{
		public function StaticTrap(name:String, trapColor : uint, params:Object=null, tile : Point = null) {
			super(name, params);
			currentColor = trapColor;
			
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("Traps");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("BadGuys");
		}
		
	}
	
}