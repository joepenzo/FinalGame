package generators {

import generators.java.util.Random;
import flash.geom.Point;

	public class CaveGenerator
	{
	    public static const TYPE_OVERGROUND:int = 0;
	    public static const TYPE_UNDERGROUND:int = 1;
	    public static const TYPE_CASTLE:int = 2;
	
	    public static function createlevel(width:int, height:int, heroPos : Point = null):Level
	    {
	        var levelGenerator:CaveGenerator = new CaveGenerator(width, height, heroPos);
	        return levelGenerator.createlevel();
	    }
	
	    private var width:int;
	    private var height:int;
	    internal var lvl:Level = new Level(width, height);
	    internal var random:Random;
	
		
		private var MIN_TILES:int=750;
		private var turnRatio:Number=.25;
		private var BORDER_THICKNESS:int = 1; // in tiles
		
		private var tilesPlaced:int;
		private var tilesToProcess:int;
		private var adjacentCells:int;
		private var startX:int;
		private var startY:int;
		private var randomDirections:Array;
		private var _heroPos:Point;
	
	
	    public function CaveGenerator(width:int, height:int, heroPos : Point) {
	        this.width = width;
	        this.height = height;
			_heroPos = heroPos;
			MIN_TILES = (width * height) * .3;
	    }
	
	    private function createlevel():Level {
			lvl = new Level(width, height);
			generateCave();
			swapTiles();
			if (_heroPos != null) createHeroPlatform();
	        return lvl;
	    }
		
		private function createHeroPlatform():void {
			lvl.setBlock(_heroPos.x , _heroPos.y, 0); // clear the tile where the player is standing
			var floorTiles : int = Math.random()*5;
			for (var x : int = -floorTiles/2; x <= floorTiles/2; x++) {
					lvl.setBlock(_heroPos.x + x, _heroPos.y+1 , 1); // place block under the poor guy, so he wont fall down
			}
			
		}
		
		private function swapTiles():void {
			for (var y:int=0; y<height; y++) {
				for (var x:int=0; x<width; x++) {
					if (lvl.getBlock(x,y) == 1) {
						lvl.setBlock(x,y,0);
					} else if (lvl.getBlock(x,y) == 0) {
						lvl.setBlock(x,y,1);
					}
				}
			}
			
		}	
	
		private function generateCave():void {
			randomDirections=shuffle([0,1,2,3]);
			tilesPlaced=1;
			if (_heroPos == null) {
				startX=Math.round(width/2);
				startY=Math.round(height/2);
			} else {
				startX = _heroPos.x;
				startY = _heroPos.y;
			}
			while (tilesPlaced<MIN_TILES) {
				tilesToProcess=1;
				drawCave();
				do {
					startX=Math.floor(Math.random()*width);
					startY=Math.floor(Math.random()*height);
				} while (!hasFreeAdjacents());
			}
		}
		
		private function hasFreeAdjacents():Boolean {
			if (lvl.map[startY][startX]==0) return false;
			if (lvl.map[startY][startX+1]==0) return true;
			if (lvl.map[startY][startX-1]==0) return true;
			if (lvl.map[startY+1]!=undefined&&lvl.map[startY+1][startX]==0) return true;
			if (lvl.map[startY-1]!=undefined&&lvl.map[startY-1][startX]==0) return true;
			return false;
		}
		
		private function drawCave():void {
			var xCoordsArray:Array=[startX];
			var yCoordsArray:Array=[startY];
			var xOffset:Array=[-1,0,1,0];
			var yOffset:Array=[0,-1,0,1];
			while (tilesToProcess>0) {
				var currentX : int = xCoordsArray.pop();
				var currentY : int = yCoordsArray.pop();
				adjacentCells=getAdjacentCells(tilesToProcess);
				if (adjacentCells>0) {
					if (Math.random()<turnRatio) {
						randomDirections=shuffle(randomDirections);
					}
					for (var j:int=0; j<4; j++) {
						var adjacentX:int=currentX+xOffset[randomDirections[j]];
						var adjacentY:int=currentY+yOffset[randomDirections[j]];
						if (adjacentX>=BORDER_THICKNESS&&adjacentX<width - BORDER_THICKNESS&&adjacentY>=BORDER_THICKNESS&&adjacentY<height-BORDER_THICKNESS&&lvl.getBlock(adjacentX,adjacentY)==0) {
							xCoordsArray.push(adjacentX);
							yCoordsArray.push(adjacentY);
							tilesPlaced++;
							lvl.setBlock(adjacentX,adjacentY,1);
							tilesToProcess++;
							adjacentCells--;
							if (adjacentCells==0) {
								break;
							}
						}
					}
				}
				tilesToProcess--;
			}
		}
	
		private function getAdjacentCells(num:int):int {
			var wayOuts:int=Math.round(Math.floor(Math.random()*4)/2+0.1);
			if (num==1&&wayOuts==0) {
				wayOuts=1;
			}
			return (wayOuts);
		}
		
		private function shuffle(startArray:Array):Array {
			var suffledArray:Array=new Array();
			while (startArray.length>0) {
				suffledArray.push(startArray.splice(Math.floor(Math.random()*startArray.length),1));
			}
			return suffledArray;
		}
		
		
	
	
	
	
	}
}
