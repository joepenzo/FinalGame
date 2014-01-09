package data.types
{
	import flash.geom.Point;

	public class ValueRange	{
		public static const PERCENTAGE : Point = new Point(0, 100);

		public static const GRAVITY : Point = new Point(20, -8);
		public static const ZOOM : Point = new Point(1, 8);

		public static const RED : Point = new Point(0, 255);
		public static const GREEN : Point = new Point(0, 255);
		public static const BLUE : Point = new Point(0, 255);
		
		public static const HERO_SIZE : Point = new Point(15, 110);
		public static const HERO_LIVES : Point = new Point(1, 10);
		public static const HERO_SPEED : Point = new Point(1, 20);
		
		public static const ENEMYSPEED : Point = new Point(0.1, 5);
		
		public static const TRAP_HEIGHT : Point = new Point(0.5, 3); //% of tileheight
	}
}