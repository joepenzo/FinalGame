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
	
		private var _possibleTileForEnemies:uint;
		private var _newEnemiesAmount:uint;
		private var _oldEnemyAmount:int;
		private var _enemiesToPlaceAmount: int;
		private var _freeEnemiesTilesArray:Array;
		private var _currentEnemyTilesArray:Array = [];
		
		private var _newStaticTrapAmount:uint;
		private var _oldStaticTrapAmount:uint;
		private var _staticTrapsToPlaceAmount:uint;
		private var _freeStaticTrapTilesArray:Array;
		private var _currentStaticTrapTilesArray:Array = [];
		private var _possibleTileForTraps:uint;
	
		private var _possibleTilesForLives:int;
		private var _newLivesAmount:int;
		private var _freeLivesTilesArray:Array;
		private var _livesToPlaceAmount:uint;
		private var _oldLivesAmount:int;
		private var _currentLivesArray:Array = [];
	
		
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
		
			_possibleTileForEnemies = getTilePointsArrayAbovePlatformTiles(Tile.TRAP).length as int;
			_possibleTileForTraps = getTilePointsArrayAbovePlatformTiles(Tile.ENEMY).length as int;
			_possibleTilesForLives = getTilePointsArrayForCollectables().length as int;
			
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
		
		
		
		
		public function placeLiveCollectables(state: StarlingState, percentage : int, heroPos : Point) :void {
			_newLivesAmount = _possibleTilesForLives*(percentage/100);
			_freeLivesTilesArray = getTilePointsArrayForCollectables() as Array;
			_livesToPlaceAmount = _freeLivesTilesArray.length*(percentage/100);		
			
			if (_newLivesAmount > _oldLivesAmount) { 
				for (var i:int=0; i < _livesToPlaceAmount-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _freeLivesTilesArray.length);
					var coord : Point = _freeLivesTilesArray[randomIdx] as Point;
					_freeLivesTilesArray.splice(randomIdx, 1);
					_currentLivesArray.push(coord);
					map[coord.y][coord.x] = Tile.LIVE;// do not place in map gives bug together with traps en shit
				}
			} else if (_newLivesAmount < _oldLivesAmount) { 
				var livesToRemove : int = _oldLivesAmount - _newLivesAmount;
				for (i = 0; i < livesToRemove-1; i++) {
					randomIdx = Math.floor(Math.random() * _currentLivesArray.length);
					coord = _currentLivesArray[randomIdx] as Point;
					_currentLivesArray.splice(randomIdx, 1);
					_freeLivesTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.AIR; // ERROR WHY?// do not place in map gives bug together with traps en shit
				}
			}
			_oldLivesAmount = _newLivesAmount;
		
			// CODE TO PLACE AND DELETE THE TRAPS IN THE GAMESTATE// write this more epic, that some TRAPS can stay!!
			var currentLivesInState : Vector.<CitrusObject> = state.getObjectsByName("liveCollectable") as Vector.<CitrusObject>;
			var currentLivesInStatelength:int = currentLivesInState.length;
			if (currentLivesInStatelength != 0) { // REMOVE ALL TRAP IN STATE IF THERE ARE 
				for each (var currentLive:Life in currentLivesInState) state.remove(currentLive);
			}
			for each (var currentLivePos:Point in _currentLivesArray) { // ADD ALL TO STATE
				//state.add(new ExSensor('liveCollectable', 0xFFDD03, { 
				state.add(new Life('liveCollectable', { 
					group:1,
					width : _tileSize/2, 
					height : _tileSize/2, 
					x: (currentLivePos.x*_tileSize) + _tileSize/2,
					y: (currentLivePos.y*_tileSize) + _tileSize/2,
					view : StarlingShape.Triangle(_tileSize/2, _tileSize/2,0x1AFF00)
				}));
			}
			
		}
		
		
		
		
		
		
		public function placeStaticTraps(state: StarlingState, percentage : int, heroPos : Point):void {
			_newStaticTrapAmount = _possibleTileForTraps*(percentage/100);
			_freeStaticTrapTilesArray = getTilePointsArrayAbovePlatformTiles(Tile.ENEMY) as Array;
			
			// removes coord if hero is if on or above it!
			for each( var coord : Point in _freeStaticTrapTilesArray ) {
				if( coord.x == heroPos.x ){
					if (coord.y == heroPos.y || heroPos.y <= coord.y ) { // also for block under the hero
						_freeStaticTrapTilesArray.splice(_freeStaticTrapTilesArray.indexOf(coord),1);
						if (_newStaticTrapAmount > 0) _newStaticTrapAmount--;
						break;//stops the loop;
					}
				}
			}
			
			_staticTrapsToPlaceAmount = _freeStaticTrapTilesArray.length*(percentage/100);		

			placeStaticTrapsInMap(heroPos);
			
			// CODE TO PLACE AND DELETE THE TRAPS IN THE GAMESTATE// write this more epic, that some TRAPS can stay!!
			var currentTrapsInState : Vector.<CitrusObject> = state.getObjectsByName("staticTrap") as Vector.<CitrusObject>;
			var currentTrapsInStatelength:int = currentTrapsInState.length;
			if (currentTrapsInStatelength != 0) { // REMOVE ALL TRAP IN STATE IF THERE ARE 
				for each (var currentTrap:StaticTrap in currentTrapsInState) state.remove(currentTrap);
			}
			for each (var currentTrapPos:Point in _currentStaticTrapTilesArray) { // ADD ALL TO STATE
				state.add(new StaticTrap('staticTrap', 0x3D3D3D, { 
					group:1,
					width : _tileSize, 
					height : _tileSize/2, 
					x: (currentTrapPos.x*_tileSize) + _tileSize/2,
					y: (currentTrapPos.y*_tileSize) + _tileSize*.75,
					view : StarlingShape.CombinedShape("Triangle", _tileSize, _tileSize/2, 0x3D3D3D)
				}));
			}
			
		}
			
		private function placeStaticTrapsInMap(heroPos:Point):void {
			if (_newStaticTrapAmount > _oldStaticTrapAmount) { 
				for (var i:int=0; i < _staticTrapsToPlaceAmount-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _freeStaticTrapTilesArray.length);
					var coord : Point = _freeStaticTrapTilesArray[randomIdx] as Point;
					_freeStaticTrapTilesArray.splice(randomIdx, 1);
					_currentStaticTrapTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.TRAP;// do not place in map gives bug together with traps en shit
				}
			} else if (_newStaticTrapAmount < _oldStaticTrapAmount) { 
				var trapsToRemove : int = _oldStaticTrapAmount - _newStaticTrapAmount;
				for (i = 0; i < trapsToRemove-1; i++) {
					randomIdx = Math.floor(Math.random() * _currentStaticTrapTilesArray.length);
					coord = _currentStaticTrapTilesArray[randomIdx] as Point;
					_currentStaticTrapTilesArray.splice(randomIdx, 1);
					_freeStaticTrapTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.AIR; // ERROR WHY?// do not place in map gives bug together with traps en shit
				}
			}
			_oldStaticTrapAmount = _newStaticTrapAmount;
		}
		
		
		
		
		
		public function placeEnemies(state: StarlingState, percentage : int, heroPos : Point):void {
			_newEnemiesAmount = _possibleTileForEnemies*(percentage/100);
			_freeEnemiesTilesArray = getTilePointsArrayAbovePlatformTiles(Tile.TRAP) as Array;
			
			// removes coord if hero is if on or above it! // not that clean, but this will do for now
			for each( var coord : Point in _freeEnemiesTilesArray ) {
				if( coord.x == heroPos.x ){
					if (coord.y == heroPos.y || heroPos.y <= coord.y ) { // also for block under the hero
						_freeEnemiesTilesArray.splice(_freeEnemiesTilesArray.indexOf(coord),1);
						if (_newEnemiesAmount > 0) _newEnemiesAmount--;
						break;//stops the loop;
					}
				}
			}
			
			_enemiesToPlaceAmount = _freeEnemiesTilesArray.length*(percentage/100);			
			
			placeEnemiesInMap(); // EDIT MAP ARRAY SO ENEMIES ARE SHOWN IN THERE
			
			// CODE TO PLACE AND DELETE THE ENEMIES IN THE GAMESTATE
			var currentEnemiesInState : Vector.<CitrusObject> = state.getObjectsByName("enemy") as Vector.<CitrusObject>;
			var currentEnemiesStatelength:int = currentEnemiesInState.length;
			// write this more epic, that some enemies can stay!!
			if (currentEnemiesStatelength != 0) { // REMOVE ALL ENEMiES IN STATE IF THERE ARE
				for each (var currentEnemy:ExBox2DPhysicsObject in currentEnemiesInState) state.remove(currentEnemy);
			}
			var boundDistance : int;
			var enemyW : int = 20;
			var enemyH : int = 20;
			for each (var currentEnemyPos:Point in _currentEnemyTilesArray) { // ADD ALL ENEMIES TO STATE
				//boundDistance =  Functions.randomIntRange(32, 32*5);
				boundDistance = 2000;
				state.add(new EdgeDetectorEnemy('enemy', 0xAB1A1A, { 
					speed : 0.5,
					group:2,
					width : enemyW, 
					height : enemyH, 
					x: (currentEnemyPos.x*_tileSize) + (enemyW*.75), // +5 for bug fixx that enemy fall of platform  //	x: currentEnemyPos.x*32 +10,
					y: (currentEnemyPos.y*_tileSize) + enemyH,
					leftBound: (currentEnemyPos.x*_tileSize) - boundDistance, // TILESIZE INSTEAD
					rightBound: (currentEnemyPos.x*_tileSize) + boundDistance,
					view : StarlingShape.polygon(20,6, 0xAB1A1A)
				}, currentEnemyPos));
			}
			
		}
		
		
	
		private function placeEnemiesInMap():void {
			if (_newEnemiesAmount > _oldEnemyAmount) { // ADD THE MOFO ENEMIES
				for (var i:int=0; i<_enemiesToPlaceAmount-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _freeEnemiesTilesArray.length);
					var coord : Point = _freeEnemiesTilesArray[randomIdx] as Point;
					_freeEnemiesTilesArray.splice(randomIdx, 1);
					_currentEnemyTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.ENEMY; // do not place in map, it gives bug together with traps en shit
				}
			} else if (_newEnemiesAmount < _oldEnemyAmount) { // REMOVE THE MOFO ENEMIES
				var enemiesToRemove = _oldEnemyAmount - _newEnemiesAmount;
				for (var i:int=0; i<enemiesToRemove-1; i++) {
					var randomIdx:int = Math.floor(Math.random() * _currentEnemyTilesArray.length);
					var coord : Point = _currentEnemyTilesArray[randomIdx] as Point;
					_currentEnemyTilesArray.splice(randomIdx, 1);
					_freeEnemiesTilesArray.push(coord);
					map[coord.y][coord.x] = Tile.AIR;// do not place in map, it gives bug together with traps en shit
				}
			}
			
			_oldEnemyAmount = _newEnemiesAmount;
		}
		
//		private function getFreeTilesAmountAbovePlatformTiles(): int{
//			var tiles : int;
//			
//			var mW:int = map[0].length;
//			var mH:int = map.length;
//			for (var y:int=0; y<mH; y++) {
//				for (var x:int=0; x<mW; x++) {
//					if (map[y][x] == 0 && Functions.isLinkedBottom(map,x,y,1) ) { // ALL TILES ABOVE A PLATFORM TILE
//						tiles++;	
//					}
//				}
//			}
//			return tiles;
//		}
		

		
		private function getTilePointsArrayForCollectables(): Array{
			var tiles : Array = [];
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] == 0 && map[y+1][x] == 0 && Functions.isLinkedBottom(map,x,y+1,1) ) {
						tiles.push(new Point(x,y));
					}
				}
			}
			return tiles;
		}
		
		
		private function getTilePointsArrayAbovePlatformTiles(extraTile : int): Array{
			var tiles : Array = [];
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (Functions.isLinkedBottom(map,x,y,1) ){ 
						if (map[y][x] == 0 || map[y][x] == extraTile) { // ALL TILES ABOVE A PLATFORM TILE
							tiles.push(new Point(x,y));
						}
					}
				}
			}
			return tiles;
		}
		
		public function drawQuadMap(gameState : StarlingState, tileSize : int, color : uint):void {
			var quadBatch:QuadBatch = new QuadBatch();
			
			var tex:Texture = Texture.fromBitmapData(new BitmapData(tileSize, tileSize, false, color));
			var image:Image = new Image(tex);
			image.color = color;
			
			var mW:int = map[0].length;
			var mH:int = map.length;
			
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (map[y][x] == Tile.LAND) {
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
