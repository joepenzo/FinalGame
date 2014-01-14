package data.types
{
	import flash.geom.Point;

	public class SoundRange	{
		
		// best values for Jump
		public static const JUMP_STARTFREQUENCY : Point = new Point(.3, .6);
		public static const JUMP_ENDFREQUENCY : Point = new Point(.3, .6);
		public static const JUMP_SLIDE : Point = new Point(.1, .3);
		public static const JUMP_DURATION : Point = new Point(.1, .3);
		
		
		public static const SHOOT_STARTFREQUENCY : Point = new Point(.4, 1);
		public static const SHOOT_ENDFREQUENCY : Point = new Point(0, .9);
		public static const SHOOT_SLIDE : Point = new Point(-.7, 0);
		public static const SHOOT_DURATION : Point = new Point(0, 1);
		
	}
}