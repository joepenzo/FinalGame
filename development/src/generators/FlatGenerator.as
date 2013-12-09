package generators {

import generators.java.util.Random;
import flash.geom.Point;

	public class FlatGenerator
	{
	    public static var platformHeight : int = 35;
	
	    public static function createlevel(width:int, height:int):Level
	    {
	        var levelGenerator:FlatGenerator = new FlatGenerator(width, height);
	        return levelGenerator.createlevel();
	    }
	
	    private var width:int;
	    private var height:int;
	    internal var lvl:Level = new Level(width, height);
		
		private var _heroPos:Point;
	
	
	    public function FlatGenerator(width:int, height:int) {
	        this.width = width;
	        this.height = height;
	    }
	
	    private function createlevel():Level {
			lvl = new Level(width, height);
			generateFlatLevel();
	        return lvl;
	    }
		
		
	
		private function generateFlatLevel():void {
			for (var y:int=0; y<height; y++) {
				for (var x:int=0; x<width; x++) {
					if (y >= platformHeight) {
						lvl.setBlock(x,y,1);
					}
				}
			}
				
		}
	
		
	
	}
}
