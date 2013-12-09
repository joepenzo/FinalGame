package  {
	
	import citrus.core.CitrusObject;
	import citrus.core.State;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Platform;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	
	import utils.Functions;
	import utils.StarlingDraw;
	
	public class Level
	{
		// String[] 
		public static const BIT_DESCRIPTIONS:Array = [
			"BLOCK UPPER", //
			"BLOCK ALL", //
			"BLOCK LOWER", //
			"SPECIAL", //
			"BUMPABLE", //
			"BREAKABLE", //
			"PICKUPABLE", //
			"ANIMATED",//
		];
		
		// uint[]
		public static var TILE_BEHAVIORS:ByteArray;// = new ByteArray(); // 256
		
		public static const BIT_BLOCK_UPPER:int = 1 << 0;
		public static const BIT_BLOCK_ALL:int = 1 << 1;
		public static const BIT_BLOCK_LOWER:int = 1 << 2;
		public static const BIT_SPECIAL:int = 1 << 3;
		public static const BIT_BUMPABLE:int = 1 << 4;
		public static const BIT_BREAKABLE:int = 1 << 5;
		public static const BIT_PICKUPABLE:int = 1 << 6;
		public static const BIT_ANIMATED:int = 1 << 7;
		private static const FILE_HEADER:int = 0x271c4178;
		
		public var width:int;
		public var height:int;
		public var map:Array;                // ByteArray[]
		public var data:Array;               // ByteArray[]
		public var xExit:int;
		public var yExit:int;
		
		private var _mapView: flash.display.Sprite;
		
		public function Level(width:int, height:int, defaultTile : int = 0) {        
			this.width = width;
			this.height = height;
			xExit = 10;
			yExit = 10;
			map = new Array(height); //uint[width][height];
			data = new Array(height); //uint[width][height];
			for (var j:int = 0; j < height; ++j) {
				map[j] = new Array(height);
				data[j] = new Array(height);
				for (var i:int = 0; i < width; ++i) {
					map[j][i] = defaultTile;
					data[j][i] = defaultTile;
				}
			}
		}
		
		// @throws IOException


		public static function loadBehaviors(behaviors:ByteArray):void {
			//dis.readFully(Level.TILE_BEHAVIORS);
			TILE_BEHAVIORS = behaviors;
		}
		
		
		public function tick():void {
			for (var y:int = 0; y < height; y++) {
				for (var x:int = 0; x < width; x++) {	
					if (uint(data[y][x]) > 0) data[y][x]--;
				}
			}
		}
		
		public function getBlockCapped(x:int, y:int):uint {
			if (x < 0) x = 0;
			if (y < 0) y = 0;
			if (x >= width) x = width - 1;
			if (y >= height) y = height - 1;
			return uint(map[y][x]);
		}
		
		public function getBlock(x:int, y:int):uint
		{
			
			if (x < 0) x = 0;
			if (y < 0) return 0;
			if (x >= width) x = width - 1;
			if (y >= height) y = height - 1;
			return uint(map[y][x]);
		}
		
		public function setBlock(x:int, y:int, b:uint):void
		{
			
			if (x < 0) return;
			if (y < 0) return;
			if (x >= width) return;
			if (y >= height) return;
			map[y][x] = b;
		}
		
		public function setBlockData(x:int, y:int, b:uint):void
		{
			
			if (x < 0) return;
			if (y < 0) return;
			if (x >= width) return;
			if (y >= height) return;
			data[y][x] = b;
		}
		
		public function isBlocking(x:int, y:int, xa:Number, ya:Number):Boolean
		{
			
			var block:uint = getBlock(x, y);
			var blocking:Boolean = ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_ALL) > 0;
			blocking ||= (ya > 0) && ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_UPPER) > 0;
			blocking ||= (ya < 0) && ((TILE_BEHAVIORS[block & 0xff]) & BIT_BLOCK_LOWER) > 0;
			return blocking;
		}
		
		
		public function randomPosition() : Point {
			do {
				var randomYpos:Number = randomRange(1, map.length-1);
				var randomXpos:Number = randomRange(1, map[0].length-1);
			} while (map[randomYpos][randomXpos] != 0)
			
			return new Point(randomXpos, randomYpos);	
		}
	
		private function randomRange(minNum:Number, maxNum:Number):Number {  
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);  
		}  
		

		
		public function drawMapPlaftormsToGameState(gameState :StarlingState, tileSize : int, color :uint = 0x000000, heroYoffset : Boolean = false, heroPos : Point = null) : void{
			var linkedHorizontalTiles : Array = [];
			var linkedVerticalTiles : Array = [];
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			
			var yOffset : int = 0;
//			if (heroYoffset && heroPos != null) {
//				for (var xt:int = 0; xt < mW; xt++) {    
//					for (var yt:int = 0; yt < mH; yt++) {
//						if (heroPos.x == xt) {
//							//trace(getBlock(xt, yt)); // tile where player is stuck
//							if (getBlock(xt,yt) == 141 || getBlock(xt,yt) == 136 || getBlock(xt,yt) == 137 || getBlock(xt,yt) == 129 || getBlock(xt,yt) == 16 || getBlock(xt,yt) == 21 || getBlock(xt,yt) == 129) {
//								yOffset = yt * tileSize - heroPos.y * tileSize;
//							}
//						}
//					}
//				}
//				
//				trace(yOffset);
//			}
			
			
			for (var yt:int = 0; yt < mH; yt++) { // Loop Left to right
				for (var xt:int = 0; xt < mW; xt++) {    
					var type:int = map[yt][xt];
					
					if (type != 0) {
						if (!Functions.isLinkedRight(map, xt, yt, type) && !Functions.isLinkedLeft(map, xt, yt, type)) { // no left or right neighboor - DRAW THE SINGLE TILES
							gameState.add(new Platform((xt +","+ yt +","+ type) , {
								x:(xt * tileSize) + tileSize/2, 
								y:(yt * tileSize) + tileSize/2 + yOffset, 
								width:tileSize, 
								height:tileSize
//								,view : StarlingDraw.ColorImage(tileSize,tileSize, 0x000000)
//								,view : StarlingDraw.RectangleShape(tileSize,tileSize, 0x000000)
							}));
							
						}
						
						//CHECK FOR HORIZONTAL LINKED TILES AND COMBINE THEM TO ONE PLATFORM
						if (Functions.isLinkedRight(map, xt, yt, type)) {
							var pt : Point = new Point(xt, yt); 
							linkedHorizontalTiles.push(pt);
						} 
						
						else if (Functions.isLinkedLeft(map, xt, yt, type) ) {
							pt = new Point(xt, yt); 
							linkedHorizontalTiles.push(pt);
							var totalLinkedTilesWidth : int = linkedHorizontalTiles.length * tileSize;
							
							gameState.add(new Platform((xt +","+ yt +","+ type), {
								x:(linkedHorizontalTiles[0].x * tileSize) + totalLinkedTilesWidth/2, 
								y:(linkedHorizontalTiles[0].y * tileSize) + tileSize/2 + yOffset,
								width:totalLinkedTilesWidth, 
								height:tileSize
//								,view : StarlingDraw.ColorImage(totalLinkedTilesWidth,tileSize, 0x000000)
//								,view : StarlingDraw.RectangleShape(totalLinkedTilesWidth,tileSize, 0x000000)
							}));
							
							linkedHorizontalTiles = [];
						}  
						
						/*else if (Functions.isLinkedLeft(map, xt, yt, type) ) {
							pt = new Point(xt, yt); 
							linkedHorizontalTiles.push(pt);
							var totalLinkedTilesWidth : int = linkedHorizontalTiles.length * tileSize;
							if (totalLinkedTilesWidth > 2048) {
								gameState.add(new Platform((xt +","+ yt +","+ type), {
									x:(linkedHorizontalTiles[0].x * tileSize) + totalLinkedTilesWidth/2, 
									y:(linkedHorizontalTiles[0].y * tileSize) + tileSize/2 + yOffset,
									width:totalLinkedTilesWidth, 
									height:tileSize
//									,view : StarlingDraw.RectangleShape(totalLinkedTilesWidth,tileSize, 0x000000)}));
							} else {
								gameState.add(new Platform((xt +","+ yt +","+ type), {
									x:(linkedHorizontalTiles[0].x * tileSize) + totalLinkedTilesWidth/2, 
									y:(linkedHorizontalTiles[0].y * tileSize) + tileSize/2 + yOffset,
									width:totalLinkedTilesWidth, 
									height:tileSize
//									,view : StarlingDraw.ColorImage(totalLinkedTilesWidth,tileSize, 0x000000)}));
							}
							
							linkedHorizontalTiles = [];
						}  */
						
						//END OF HORIZONTAL CHECK
					}
					
				}
			}
			
			drawQuadMap(gameState, tileSize, color);
			
		}
		
		
		/*
		//No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles.
		public static const NONE:String      = "none";
		//Bilinear filtering. Creates smooth transitions between pixels.
		public static const BILINEAR:String  = "bilinear";
		// Trilinear filtering. Highest quality by taking the next mip map level into account.
		public static const TRILINEAR:String = "trilinear";
		*/
		
		
		// DRAW ALL THE TILES TO ONE IMAGE!
		private function drawBitmapMap(gameState : StarlingState, tileSize : int, color : uint = 0x000000):void {
			_mapView = new flash.display.Sprite();
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] != 0) {
						var tile : flash.display.Shape = new flash.display.Shape();
						tile.graphics.beginFill(color);
						tile.graphics.drawRect(0,0,tileSize,tileSize);
						tile.graphics.endFill();
						
						tile.x = x*tileSize;
						tile.y = y*tileSize;
						
						_mapView.addChild(tile);
					}
				}
			}
			var bmd:BitmapData = new BitmapData(2048, 2048, true);// var bmd:BitmapData = new BitmapData(mW*tileSize, mH*tileSize, false);
			bmd.draw(_mapView);
			
			var img:Image = new Image(Texture.fromBitmapData(bmd));
			img.smoothing = "none"; 
			
			gameState.add(new CitrusSprite("citrusMapSprite", {view:img}));
		}		
		
		public function drawQuadMap(gameState : StarlingState, tileSize : int, color : uint):void {
			var quadBatch:QuadBatch = new QuadBatch();
			
			var tex:Texture = Texture.fromBitmapData(new BitmapData(tileSize, tileSize, true));
			var image:Image = new Image(tex);
			image.color = color;
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] != 0) {
						image.x = x*tileSize;
						image.y = y*tileSize;
						quadBatch.addImage(image);
					}
				}
			}
			
			if (!
				gameState.getObjectByName("citrusMapSprite"))  {
				gameState.add(new CitrusSprite("citrusMapSprite", {view:quadBatch}));	
			} else {
				var mapSprite:CitrusSprite = gameState.getObjectByName("citrusMapSprite") as CitrusSprite;
				mapSprite.view = quadBatch;
			}
			
		}
		
		
		

	}
}
