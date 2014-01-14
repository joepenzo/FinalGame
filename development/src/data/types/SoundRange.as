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
		public static const SHOOT_SLIDE : Point = new Point(-.6, 0);
		public static const SHOOT_DURATION : Point = new Point(0, 1);
		
		public static const COIN_STARTFREQUENCY : Point = new Point(.2, 1);
		public static const COIN_ENDFREQUENCY : Point = new Point(0, .15);
		public static const COIN_SLIDE : Point = new Point(-.1, .1);
		public static const COIN_DURATION : Point = new Point(0.35, .65);
		
		public static const LIFE_STARTFREQUENCY : Point = new Point(.1, .3);
		public static const LIFE_ENDFREQUENCY : Point = new Point(0, .95);
		public static const LIFE_SLIDE : Point = new Point(.25, .5);
		public static const LIFE_DURATION : Point = new Point(0.3, .6);
		
		public static const HIT_STARTFREQUENCY : Point = new Point(.2, .7);
		public static const HIT_ENDFREQUENCY : Point = new Point(0, .1);
		public static const HIT_SLIDE : Point = new Point(-.7, -.33);
		public static const HIT_DURATION : Point = new Point(0, .4);
		
	}
}