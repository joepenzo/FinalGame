package objects
{
	import flash.geom.Point;
	
	public class StaticTrap extends ExSensor
	{
		public function StaticTrap(name:String, trapColor : uint, params:Object=null, tile : Point = null) {
			super(name, params);
			currentColor = trapColor;
			
		}
	}
}