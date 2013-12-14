package objects  {
	
	import citrus.core.CitrusObject;
	import citrus.core.State;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Platform;
	
	import data.GameData;
	import data.types.Tile;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Shape;
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
		
		private var _tileSize:int;
		
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


		public function get getTotalEnemiesAmount():int
		{
			return _currentEnemyTilesArray.length;
		}

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
			_tileSize = tileSize;
			
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
								x:(xt * _tileSize) + _tileSize/2, 
								y:(yt * _tileSize) + _tileSize/2 + yOffset, 
								width:_tileSize, 
								height:_tileSize
							}));
							
						}
						
						//CHECK FOR HORIZONTAL LINKED TILES AND COMBINE THEM TO ONE PLATFORM
						if (Functions.isLinkedRight(map, xt, yt, type)) linkedHorizontalTiles.push(new Point(xt, yt));
						
						else if (Functions.isLinkedLeft(map, xt, yt, type) ) {
							linkedHorizontalTiles.push(new Point(xt, yt));
							totalLinkedTilesWidth  = linkedHorizontalTiles.length * _tileSize;
							
							gameState.add(new Platform((xt +","+ yt +","+ type), {
								x:(linkedHorizontalTiles[0].x * _tileSize) + totalLinkedTilesWidth/2, 
								y:(linkedHorizontalTiles[0].y * _tileSize) + _tileSize/2 + yOffset,
								width:totalLinkedTilesWidth, 
								height:_tileSize
							}));
							
							linkedHorizontalTiles = [];
						}  
					}
					
				}
			}
			
			drawQuadMap(gameState, _tileSize, color);
			_possibleTileForEnemies = getTilePointsArrayAbovePlatformTiles().length as int;
			
			
			fixHeroPosIfStuck(heroPos, gameState.getObjectByName("hero") as ExHero);
		}
		
		private function fixHeroPosIfStuck(heroPos : Point, hero : ExHero):void {
			if (heroPos == null) return;
			if (getBlock(heroPos.x, heroPos.y) == Tile.LAND) {
				for (var y:uint = height; y > 0; y--) {
					if (map[y-1][heroPos.x] == 0) {
						var heroHeight : Number = (hero.body.GetFixtureList().GetAABB().upperBound.y - hero.body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
						hero.y = (y*_tileSize) -heroHeight/2;//hero.y = (y-1)*32;
						break;
					}
				}
			}
		}	

		
		public function placeEnemies(state: StarlingState, percentage : int):void {

			_newEnemiesAmount = _possibleTileForEnemies*(percentage/100);
			_freeTilesArray = getTilePointsArrayAbovePlatformTiles() as Array;
			_enemiesToPlaceAmount = _freeTilesArray.length*(percentage/100);			
			
			placeEnemiesInMap(); // EDIT MAP ARRAY SO ENEMIES ARE SHOWN IN THERE
			
			var currentEnemiesInState : Vector.<CitrusObject> = state.getObjectsByName("enemy") as Vector.<CitrusObject>;
			var currentEnemiesStatelength:int = currentEnemiesInState.length;
			
			// write this more epic, that some enemies can stay!!
			if (currentEnemiesStatelength != 0) { // REMOVE ALL ENEMiES IN STATE IF THERE ARE
				for each (var currentEnemy:ExBox2DPhysicsObject in currentEnemiesInState) state.remove(currentEnemy);
			}
			var boundDistance : int;
			for each (var currentEnemyPos:Point in _currentEnemyTilesArray) { // ADD ALL ENEMIES TO STATE
				boundDistance =  Functions.randomIntRange(32, 32*5);
				state.add(new EdgeDetectorEnemy('enemy', 0xAB1A1A, { 
					speed : 0.8,
					width : 20, 
					height : 20, 
					x: (currentEnemyPos.x*_tileSize) +10 + 5, // +5 for bug fixx that enemy fall of platform  //	x: currentEnemyPos.x*32 +10,
					y: (currentEnemyPos.y*_tileSize) +10,
					leftBound: (currentEnemyPos.x*_tileSize) - boundDistance, // TILESIZE INSTEAD
					rightBound: (currentEnemyPos.x*_tileSize) + boundDistance,
					view : StarlingShape.polygon(20,6, 0xAB1A1A)
				}, currentEnemyPos));
			}
			
		}
		
		
	
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
			
			if (!gameState.getObjectByName("citrusMapSprite"))  {
				gameState.add(new CitrusSprite("citrusMapSprite", {view:quadBatch}));	
			} else {
				var mapSprite:CitrusSprite = gameState.getObjectByName("citrusMapSprite") as CitrusSprite;
				mapSprite.view = quadBatch;
			}
			
		}
		
		
		
		
		
		public function drawDebugGrid(gameState : StarlingState):void {
			var grid : starling.display.Shape = new Shape();
		
			grid.graphics.clear();
			grid.graphics.lineStyle(1, 0x00ff00);
			
			// we drop in the " + 1 " so that it will cap the right and bottom sides.
			for (var col:Number = 0; col < width + 1; col++)
			{
				for (var row:Number = 0; row < height + 1; row++)
				{
					trace(col, row);
					grid.graphics.moveTo(col * _tileSize, 0);
					grid.graphics.lineTo(col * _tileSize, _tileSize * height);
					grid.graphics.moveTo(0, row * _tileSize);
					grid.graphics.lineTo(_tileSize * width, row * _tileSize);
				}
			}
			
			if (!gameState.getObjectByName("citrusMapDebugGrid"))  {
				gameState.add(new CitrusSprite("citrusMapDebugGrid", {view:grid}));	
			} else {
				var mapSprite:CitrusSprite = gameState.getObjectByName("citrusMapDebugGrid") as CitrusSprite;
				mapSprite.view = grid;
			}

		}
		
		
		
	}
}
