package objects  {
	
	import citrus.core.CitrusObject;
	import citrus.core.State;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Platform;
	
	import data.consts.Tile;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	
	import utils.Functions;
	import utils.StarlingDraw;
	import utils.StarlingShape;
	
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
		private var _enemiesToPlaceAmount: int;
		private var _freeTilesArray:Array;
		private var _oldEnemyAmount:int;
		private var _possibleTileForEnemies:uint;
		private var _newEnemiesAmount:uint;
		private var _currentEnemyTilesArray:Array = [];
		
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
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			
			var yOffset : int = 0;

			var type: int;
			var totalLinkedTilesWidth : int;
			for (var yt:int = 0; yt < mH; yt++) { // Loop Left to right
				for (var xt:int = 0; xt < mW; xt++) {    
					type = map[yt][xt];
					
					if (type != 0) {
						if (!Functions.isLinkedRight(map, xt, yt, type) && !Functions.isLinkedLeft(map, xt, yt, type)) { // no left or right neighboor - DRAW THE SINGLE TILES
							gameState.add(new Platform((xt +","+ yt +","+ type) , {
								x:(xt * tileSize) + tileSize/2, 
								y:(yt * tileSize) + tileSize/2 + yOffset, 
								width:tileSize, 
								height:tileSize
							}));
							
						}
						
						//CHECK FOR HORIZONTAL LINKED TILES AND COMBINE THEM TO ONE PLATFORM
						if (Functions.isLinkedRight(map, xt, yt, type)) linkedHorizontalTiles.push(new Point(xt, yt));
						
						else if (Functions.isLinkedLeft(map, xt, yt, type) ) {
							linkedHorizontalTiles.push(new Point(xt, yt));
							totalLinkedTilesWidth  = linkedHorizontalTiles.length * tileSize;
							
							gameState.add(new Platform((xt +","+ yt +","+ type), {
								x:(linkedHorizontalTiles[0].x * tileSize) + totalLinkedTilesWidth/2, 
								y:(linkedHorizontalTiles[0].y * tileSize) + tileSize/2 + yOffset,
								width:totalLinkedTilesWidth, 
								height:tileSize
							}));
							
							linkedHorizontalTiles = [];
						}  
					}
					
				}
			}
			
			
			drawQuadMap(gameState, tileSize, color);
			
			_possibleTileForEnemies = getTilePointsArrayAbovePlatformTiles().length as int;
		}
		
		
		
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
			
			quadBatch.blendMode = BlendMode.NONE;
			
			if (!
				gameState.getObjectByName("citrusMapSprite"))  {
				gameState.add(new CitrusSprite("citrusMapSprite", {view:quadBatch}));	
			} else {
				var mapSprite:CitrusSprite = gameState.getObjectByName("citrusMapSprite") as CitrusSprite;
				mapSprite.view = quadBatch;
			}
			
		}
		
		
		
		
		
		/*
		public function placeEnemies(state: StarlingState, amount : int):void {
			var mW:int = map[0].length;
			var mH:int = map.length;

			var currentEnemiesInState : Vector.<CitrusObject> = state.getObjectsByName("enemy") as Vector.<CitrusObject>;
			
			_freeTilesArray = getTilePointsArrayAbovePlatformTiles() as Array;
			_enemiesAmount = _freeTilesArray.length*(amount/100);
			
			addEnemiesToMap();
			
			var currentEnemiesStatelength:uint = currentEnemiesInState.length;
			
			if (currentEnemiesStatelength - _enemiesAmount >= 1) {
				removeEmemiesFromMap(currentEnemiesStatelength - _enemiesAmount);
			}
			
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
				
					if (currentEnemiesStatelength != 0) {
						
						for ( var i:uint=0; i<currentEnemiesStatelength; i++ ) {
							var excistingEnemy : ExBox2DPhysicsObject = currentEnemiesInState[i] as ExBox2DPhysicsObject;
							if (map[y][x] == 0) {
								if (excistingEnemy.tile.x == x && excistingEnemy.tile.y == y) {
									state.remove(excistingEnemy);
								}
							}
						}
						
					} 
					
					if (map[y][x] == Tile.ENEMY) {
						for ( var i:uint=0; i<currentEnemiesStatelength; i++ ) {
							var excistingEnemy : ExBox2DPhysicsObject = currentEnemiesInState[i] as ExBox2DPhysicsObject;
							if (excistingEnemy.tile.x == x && excistingEnemy.tile.y == y) return;
						}
						
						state.add(new ExBox2DPhysicsObject('enemy', { width : 30, height : 30, x: x*32 + 15, y: y*32 }, new Point(x,y)));
						for ( i =0; i<_freeTilesArray.length; i++ ) {
							if (_freeTilesArray[i].x == x && _freeTilesArray[i].y == y) _freeTilesArray.splice(i,1);
						}							
					}
				
				}
			}
		}		
		*/
		
		
		
		public function placeEnemies(state: StarlingState, percentage : int):void {
	fatal(percentage);

			_newEnemiesAmount = _possibleTileForEnemies*(percentage/100);
			_freeTilesArray = getTilePointsArrayAbovePlatformTiles() as Array;
			_enemiesToPlaceAmount = _freeTilesArray.length*(percentage/100);			
			
			placeEnemiesInMap();
	Functions.trace2DArray(map);
			
			var currentEnemiesInState : Vector.<CitrusObject> = state.getObjectsByName("enemy") as Vector.<CitrusObject>;
		}
		
		
		
		
		
//		private function removeEmemiesFromMap(enemiesToRemove: int):void {
//			var i : int;
//			var mW:int = map[0].length;
//			var mH:int = map.length;
//			for (var y:int=0; y<mH; y++) {
//				for (var x:int=0; x<mW; x++) {
//					if (map[y][x] == Tile.ENEMY) {
//						if (enemiesToRemove == i) return;
//						i++;
//						map[y][x] = 0; // MOET RANDMOM MAN
//					}
//				}
//			}
//			
//		}
		
		private function placeEnemiesInMap():void {
			//fatal(_newEnemiesAmount + "  " + _oldEnemyAmount);
			
			if (_newEnemiesAmount > _oldEnemyAmount) { // ADD THE MOFO ENEMIES
				for (var i:int=0; i<_enemiesToPlaceAmount-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _freeTilesArray.length);
					var coord : Point = _freeTilesArray[randomIdx] as Point;
					_freeTilesArray.splice(randomIdx, 1);
					_currentEnemyTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.ENEMY;
				}
			} else if (_newEnemiesAmount < _oldEnemyAmount) { // REMOVE THE MOFO ENEMIES
				var enemiesToRemove = _oldEnemyAmount - _newEnemiesAmount;
				error('removeEnemies ' + enemiesToRemove);
				for (var i:int=0; i<enemiesToRemove-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _currentEnemyTilesArray.length);
					var coord : Point = _currentEnemyTilesArray[randomIdx] as Point;
					_currentEnemyTilesArray.splice(randomIdx, 1);
					_freeTilesArray.push(coord);
					map[coord.y][coord.x] = 0;
				}
			}
			
			_oldEnemyAmount = _newEnemiesAmount;
		}
		
		private function getFreeTilesAmountAbovePlatformTiles(): int{
			var tiles : int;
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] == 0 && Functions.isLinkedBottom(map,x,y,1) ) { // ALL TILES ABOVE A PLATFORM TILE
						tiles++;	
					}
				}
			}
			return tiles;
		}
		
		private function getTilePointsArrayAbovePlatformTiles(): Array{
			var tiles : Array = [];
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] == 0 && Functions.isLinkedBottom(map,x,y,1) ) { // ALL TILES ABOVE A PLATFORM TILE
						//map[y][x] = newIndex;
					//	debug(x + "  -  " + y);
						tiles.push(new Point(x,y));	
					}
				}
			}
			return tiles;
		}
		
		
		
	}
}
