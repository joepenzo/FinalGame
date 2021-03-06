package
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	
	import audio.Sounds;
	import audio.SynthSounds;
	
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingState;
	import citrus.input.InputAction;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.TimeShifter;
	import citrus.math.MathUtils;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.MovingPlatform;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2D;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.utils.AGameData;
	import citrus.view.ACitrusCamera;
	import citrus.view.starlingview.StarlingCamera;
	
	import com.greensock.TweenLite;
	
	import data.GameData;
	import data.consts.Actions;
	import data.consts.Goals;
	import data.consts.Shapes;
	import data.consts.Tile;
	import data.types.SoundRange;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import generators.CaveGenerator;
	import generators.MarioGenerator;
	
	import objects.Bullet;
	import objects.Coin;
	import objects.EdgeDetectorEnemy;
	import objects.ExBox2DPhysicsObject;
	import objects.ExEnemy;
	import objects.ExHero;
	import objects.ExMovingPlatform;
	import objects.ExPlatform;
	import objects.Finish;
	import objects.GameInterface;
	import objects.Level;
	import objects.Life;
	import objects.StaticTrap;
	import objects.Trampoline;
	
	import org.osmf.events.TimeEvent;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Shape;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.FlashShape;
	import utils.Functions;
	import utils.StarlingDraw;
	import utils.StarlingShape;
	
	public class GameState extends StarlingState
	{
		private var INTERVAL:Number = new Number();
		private const AUDIO_FEEDBACK_DELAYTIME:int = 50;
		private var audioInterval:Number =  0;

		
		private var _gameData:GameData;

		private var _tileSize:int = 32; // 32 
		private var _mapW:int = 100;
		private var _mapH:int = 40;
		
		private var _box2D:Box2D;
		private var _lvl:Level;
		private var _camera:StarlingCamera;
		private var _hero:ExHero;
		private var _bounds:Rectangle;
		private var _debugSprite:flash.display.Sprite;
		private var _gameInterface:GameInterface;
		
		private var _arduinoConnector:ArduinoSerialComAnalogAndDigital;
		private var _timeshifter:TimeShifter;
		private var _deadOverlay:CitrusSprite;
		private var _sounds:SynthSounds;
		private var _shake:Boolean;
		private var _deadTimer:Timer;

		
		public function GameState() {
			super();	
		}
		
		override public function initialize():void {
			super.initialize();
			_gameData = _ce.gameData as GameData;
			_gameData.dataChanged.add(onDataChanged);
			_sounds = _gameData.synthSounds;
			
			PhysicsCollisionCategories.Add("Traps");
			
			_box2D = new Box2D("box2D");
			_box2D.visible = false;
			add(_box2D);
			
			_mapW = 100;//_mapW = 150;
			_mapH = 25;
			_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, 0, 1);

			_lvl.drawMapPlaftormsToGameState(this, _tileSize, 0x000000);
//			_lvl.drawDebugGrid(this);
			
			var heroStartPos : Point = _lvl.randomPosition();
			_hero = new ExHero("hero", {
				group:3,
				x:heroStartPos.x * _tileSize, 
				y:heroStartPos.y* _tileSize, 
				width:_tileSize/2, 
				height: _tileSize/2
			});
			_hero.enemyClass = EdgeDetectorEnemy;
			_hero.hurtVelocityX = _tileSize*.07;
			_hero.hurtVelocityY = _tileSize*.09;
			_hero.currentColor = 0x000050;
			_hero.currentShape = Shapes.RECTANGLE;
			_hero.jumpHeight = _tileSize*.225;
			_hero.view = StarlingShape.Rectangle(_hero.width, _hero.height, _hero.currentColor);
			_hero.jumpType = "Double";
			add(_hero);

			
			_bounds = new Rectangle(0, 0, _mapW*_tileSize, _mapH*_tileSize);
			_camera = view.camera as StarlingCamera;
			_camera.setUp(_hero, new Point(stage.stageWidth/2, stage.stageHeight/2), _bounds, new Point(.5, .5));
			_camera.allowRotation = true;
			_camera.allowZoom = true;
			_camera.boundsMode = ACitrusCamera.BOUNDS_MODE_AABB;
			_camera.rotationEasing = .3;
			_camera.zoomEasing = .1;
			_camera.setZoom(2);
			
			// CREATE MINIMAP DEBUG SPRITE
//			_debugSprite = new flash.display.Sprite();
//			_debugSprite.scaleX = 0.2 * 0.6;
//			_debugSprite.scaleY = 0.2 * 0.6;
//			_debugSprite.graphics.lineStyle(20, 0xFFFFFF, 0.4);
//			// DETERMINE SIZE OF SPRITE
//			_camera.renderDebug(_debugSprite as flash.display.Sprite)
//			// ADD AND PLACE MINIMAP
//			_ce.stage.addChild(_debugSprite);
//			_debugSprite.x = stage.stageWidth - _debugSprite.width - 10;
//			_debugSprite.y = 10;
			
			
			_timeshifter = new TimeShifter(2,false, false);
			_timeshifter.addBufferSet( { object: _hero, continuous:["x","y"]}); 
			
			_timeshifter.onActivated.add(timeShiftStart);
			_timeshifter.onDeactivated.add(timeShiftEnd);
			
			_gameInterface = new GameInterface(this, 10, 10);
			
			//_arduinoConnector = new ArduinoSerialComAnalogAndDigital("arduinoConnector");
			
			_ce.input.keyboard.addKeyAction("debugAction",Keyboard.Q);
			
			setGameDataStartValues();
			
			//stage.addEventListener(TouchEvent.TOUCH, handleFullscreen);
		}	
		
		
		private function handleFullscreen(e:TouchEvent):void {
			var t:Touch = e.getTouch(stage);
			if (t !== null) {
				if (t.phase == TouchPhase.ENDED) {  
					_ce.stage.scaleMode = "noScale";
					_ce.stage.align = "TL";
					_ce.stage.displayState = StageDisplayState.FULL_SCREEN;
				}
			}
			
		}
		
		private function setGameDataStartValues():void {
			_gameData.lives = 5;
			_gameData.bulletShape = Shapes.RECTANGLE;
			
			_gameData.coinColor = 0xFFF700;
			_gameData.coinShape = Shapes.CIRCLE;

			_gameData.lifeColor = 0x1AFF00;
			_gameData.lifeShape = Shapes.TRIANGLE;
			
			_gameData.enemyColor = 0xAB1A1A;
			_gameData.enemyShape =	Shapes.HEXAGON;

			_gameData.trapColor = 0x3D3D3D;
			_gameData.trapShape = Shapes.TRIANGLE;
			
			_gameData.movingPlatColor = 0x333333;
			_gameData.trampolineColor = 0xc0ffee;
			
			_gameData.goal = Goals.NO_GOAL;
		}
		
		private function timeShiftStart():void {
			_shake = true;
			_sounds.play(Sounds.REWIND);
			_hero.body.SetActive(false);
			_deadOverlay = new CitrusSprite("overlay", {parallaxX:0,parallaxY:0, group:9});
			var overlayQuad:Quad = new Quad(stage.stageWidth*2, stage.stageHeight*2, _hero.currentColor);
			overlayQuad.blendMode = BlendMode.ADD;
			_deadOverlay.view = overlayQuad;
			add(_deadOverlay); 
		}
		
		private function timeShiftEnd():void {
//			for each (var citrusObject :CitrusObject in objects) {
//				if (citrusObject is ExEnemy) {
//					var enemy : ExEnemy = citrusObject as ExEnemy;
//					if ( MathUtils.DistanceBetweenTwoPoints(_hero.x, _hero.x, enemy.x ,enemy.y) <= 100 ) {
//						enemy.kill = true;
//					}
//				}
//				if ( citrusObject is StaticTrap) {
//					var trap : StaticTrap = citrusObject as StaticTrap;
//					if ( MathUtils.DistanceBetweenTwoPoints(_hero.x, _hero.x, trap.x, trap.y) <= 100 ) {
//						trap.kill = true;
//					}
//				}
//			}
			
			_shake = false;
			TweenLite.to(this, 0.2, {x:0, y:0});// tween state back to 0,0 after shaking it
			
			_sounds.stop(Sounds.REWIND);
			_hero.body.SetActive(true);
			remove(_deadOverlay);
			
			_gameData.lives = 1; // give back one live!
			
			
		}
		
		private function shakeState():void {
			x = Math.random() * 5 - 5;
			y = Math.random() * 5 - 5;
		}
		
		private function onDataChanged(data:String, value:Object):void {
			if (_gameData.goal == Goals.KILL_ENEMIES) {
				if (data == "totalEnemiesInState" || data == "totalEnemiesKilled") {
					_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );	
					if (_gameData.enemiesKilled == _gameData.totalEnemies) { // MADE YOUR GOAL, RESET THE MOTHERFUCKER
						_gameInterface.updateGoalStatus("DONE - RESETTING");
						setTimeout(function():void {
							_gameData.enemiesKilled = _gameData.totalEnemies = 0;
							_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );
						}, 2000);
					}
				}
			} else if (_gameData.goal == Goals.COLLECT_COINS && data == "score") {
				_gameInterface.updateGoalStatus( ("Coins / " + value.toString()) );
			}
			
			
			if (data == "lives") {
				_gameInterface.changesLives(int(value));
				
				if(value <= 0) { //  zero lives, hero's is dead by now!
					_timeshifter.startRewind(.1, 1.3);
				}
				
			}
			
		}
		
		private function removeFinishSensor():void{
			var finishes:Vector.<CitrusObject> = getObjectsByType(Finish);
			var finish:Finish;
			for each (finish in finishes) remove(finish);
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			//camera render debug 
//			_camera.renderDebug(_debugSprite as flash.display.Sprite)
//			drawPlatformsToMiniMap();
//			drawEnemiesToMiniMap();
			// ENDOFF MINIMAP DEBUG RENDERING
			
			if (_shake) shakeState();
			
//			if (_ce.input.justDid("debugAction")) {
//				_timeshifter.startRewind(.1, 1.3);
//			}

			
			// GAME GOAL
			if (_ce.input.justDid(Actions.GOAL_KILL)) {
				_gameData.goal = Goals.KILL_ENEMIES;
				_gameInterface.updateGoalType(_gameData);
				_gameInterface.updateGoalStatus( (_gameData.enemiesKilled.toString() + " / " + _gameData.totalEnemies.toString()) );
				
				removeFinishSensor();
			}
			if(_ce.input.justDid(Actions.GOAL_COLLECT)) {
				_gameData.goal = Goals.COLLECT_COINS;
				_gameInterface.updateGoalType(_gameData);
				
				removeFinishSensor();
			}
			if(_ce.input.justDid(Actions.GOAL_A_TO_B)) {
				_gameData.goal = Goals.A_TO_B;
				_gameInterface.updateGoalType(_gameData);
				
				placeFinish(new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize)));
			} 
			if(_ce.input.justDid(Actions.GOAL_NO_GOAL)) {
				_gameData.goal = Goals.NO_GOAL;
				_gameInterface.updateGoalType(_gameData);
				
				removeFinishSensor();
			}
			
			
			// PLATFORM LEVEL - CHANGE
			if(_ce.input.justDid(Actions.CHANGE_LVL_MARIO)) {
				var action:InputAction = _ce.input.getAction(Actions.CHANGE_LVL_MARIO) as InputAction;
				redrawLevel("mario");
			}
			// CAVE LEVEL - CHANGE
			else if(_ce.input.justDid(Actions.CHANGE_LVL_CAVE)) {
				var action:InputAction = _ce.input.getAction(Actions.CHANGE_LVL_CAVE) as InputAction;
				redrawLevel("cave");
			}

			// GRAVITY - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_GRAVITY)) {
				var action:InputAction = _ce.input.getAction(Actions.VALUE_GRAVITY) as InputAction;
				_box2D.gravity.Set(0, action.value); 
			}
			// ZOOM - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_ZOOM)) {
				action = _ce.input.getAction(Actions.VALUE_ZOOM) as InputAction;
				_camera.setZoom(action.value);
			}

			
			// HERO SIZE - CHANGE
			if(_ce.input.isDoing(Actions.HERO_SIZE)) {
				action = _ce.input.getAction(Actions.HERO_SIZE) as InputAction;
				Functions.ResizeObjectValue(this, action.value/30/2, action.value/30/2, _hero);
			}
			// HERO LIVES - CHANGE
			if(_ce.input.isDoing(Actions.HERO_LIVES)) {
				action = _ce.input.getAction(Actions.HERO_LIVES) as InputAction;
				_gameData.lives = action.value;
			}
			// HERO SPEED - CHANGE
			if(_ce.input.isDoing(Actions.HERO_SPEED)) {
				action = _ce.input.getAction(Actions.HERO_SPEED) as InputAction;
				_hero.maxVelocity = action.value;
				_hero.acceleration = action.value/8;
			}
	
			if(_ce.input.justDid(Actions.HERO_SHOOT_ON)) {
				action = _ce.input.getAction(Actions.HERO_SHOOT_ON) as InputAction;
				if (action.value == 1) _hero.shootingEnabled = true;
			}
			
			if(_ce.input.justDid(Actions.HERO_SHOOT_OFF)) {
				action = _ce.input.getAction(Actions.HERO_SHOOT_OFF) as InputAction;
				if (action.value == 1) _hero.shootingEnabled = false;
			}
							
			
			
			
			// HERO JUMPS
			if(_ce.input.justDid(Actions.CHANGE_JUMP_SINGLE)) {
				_hero.jumpType = "Single";
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_DOUBLE)) {
				_hero.jumpType = "Double";
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_UNLIMETID)) {
				_hero.jumpType = "Unlimited";
			} else if(_ce.input.justDid(Actions.CHANGE_JUMP_JETPACK)) {
				_hero.jumpType = "Jetpack";
			}

			
			
			
			// ENEMY AMOUNT - CHANGE
			if(_ce.input.hasDone(Actions.ENEMY_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.ENEMY_PERCANTAGE) as InputAction;
				_gameData.enemyPercentage = action.value;			
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(myDelayedFunction, 100, this, action);
				function myDelayedFunction(state : StarlingState, action : InputAction):void { 
					_lvl.placeEnemies(state, _gameData.enemyPercentage, (new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize))), _gameData.enemyColor, _gameData.enemyShape  );
					_gameData.totalEnemies = _lvl.getTotalEnemiesAmount; // save total enemies for the enemy kill counter
				}
			}
			
			// TRAP AMOUNT
			if(_ce.input.hasDone(Actions.TRAP_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.TRAP_PERCANTAGE) as InputAction;
				_gameData.trapPercantage = action.value;			
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(function (state : StarlingState):void { 
					_lvl.placeStaticTraps(state, 
						_gameData.trapPercantage, 
						(new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize))), _gameData.trapColor, _gameData.trapShape  );
				}, 100, this);
				
			}
			
			// MOVING PLATFORMS AMOUNT - CHANGE
			if(_ce.input.hasDone(Actions.MOVINGPLAT_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.MOVINGPLAT_PERCANTAGE) as InputAction;
				_gameData.movingPlatsPercantage = action.value;			
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(function (state : StarlingState):void {
					_lvl.placeMovingPlatforms(state, _gameData.movingPlatsPercantage, _gameData.movingPlatColor, _gameData.movingPlatformSpeed);
				}, 100, this);
			}
			
			// TRAMPOLINE AMOUNT - CHANGE
			if(_ce.input.hasDone(Actions.TRAMPOLINE_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.TRAMPOLINE_PERCANTAGE) as InputAction;
				_gameData.trampolinePercantage = action.value;
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(function (state : StarlingState):void {
					trace(action.value);
					_lvl.placeTrampolines(state,_gameData.trampolinePercantage, _gameData.trampolineColor);
				}, 100, this);
			}
		
			// LIVE AMOUNT
			if(_ce.input.hasDone(Actions.LIVES_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.LIVES_PERCANTAGE) as InputAction;
				_gameData.livesPercantage = action.value;			
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(function (state : StarlingState):void { 
					_lvl.placeLiveCollectables(state, _gameData.livesPercantage, _gameData.lifeColor, _gameData.lifeShape);
				}, 100, this);
				
			}
			
			// COIN AMOUNT
			if(_ce.input.hasDone(Actions.COINS_PERCANTAGE)) {
				action = _ce.input.getAction(Actions.COINS_PERCANTAGE) as InputAction;
				_gameData.coinsPercantage = action.value;			
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(function (state : StarlingState):void { 
					_lvl.placeCoinCollectables(state, _gameData.coinsPercantage, _gameData.coinColor, _gameData.coinShape);
				}, 100, this);
				
			}
			
			
			
			// TrapHeight - CHANGE
			if(_ce.input.hasDone(Actions.TRAP_HEIGHT)) {
				var action:InputAction = _ce.input.getAction(Actions.TRAP_HEIGHT) as InputAction;
				
				clearTimeout(INTERVAL);
				INTERVAL = setTimeout(
				function (state : StarlingState):void { 
						
					var traps:Vector.<CitrusObject> = getObjectsByType(StaticTrap);
					var trap:StaticTrap;
					for each (trap in traps) {
						if(!trap.body.GetContactList()) { // if colliding something (like hero) dont grow. otherwise shit DIES -- temp bugfix
							Functions.ResizeTrap(state, (_tileSize/30)*action.value, trap, _tileSize);
						}
					}
					
				}, 100, this);
			}
			
			
			// MovingPlatform SPEED - CHANGE
			if(_ce.input.isDoing(Actions.MOVINGPLATFORM_SPEED)) {
				var action:InputAction = _ce.input.getAction(Actions.MOVINGPLATFORM_SPEED) as InputAction;
				_gameData.movingPlatformSpeed = action.value as Number;
				var movingPlatforms:Vector.<CitrusObject> = getObjectsByType(ExMovingPlatform);
				var movingPlat:ExMovingPlatform;
				for each (movingPlat in movingPlatforms) {
					movingPlat.speed = _gameData.movingPlatformSpeed;
				}
			}
			
			// TRAMPOLINE BOOST
			if(_ce.input.isDoing(Actions.TRAMPOLINE_BOOST)) {
				var action:InputAction = _ce.input.getAction(Actions.TRAMPOLINE_BOOST) as InputAction;
				_gameData.trampolineBoost = action.value as Number;
			}
			
			// EnemySpeed - CHANGE
			if(_ce.input.isDoing(Actions.ENEMY_SPEED)) {
				var action:InputAction = _ce.input.getAction(Actions.ENEMY_SPEED) as InputAction;
				
				var enemies:Vector.<CitrusObject> = getObjectsByType(EdgeDetectorEnemy);
				var enemy:ExEnemy;
				for each (enemy in enemies) {
					enemy.speed =  action.value;
				}
			}
			
		
			
			//RED GREEN BLUE - CHANGE
			if(_ce.input.isDoing(Actions.VALUE_RED)) {
				action = _ce.input.getAction(Actions.VALUE_RED) as InputAction;
				_gameData.red = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}if(_ce.input.isDoing(Actions.VALUE_GREEN)) {
				action = _ce.input.getAction(Actions.VALUE_GREEN) as InputAction;
				_gameData.green = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}if(_ce.input.isDoing(Actions.VALUE_BLUE)) {
				action = _ce.input.getAction(Actions.VALUE_BLUE) as InputAction;
				_gameData.blue = action.value;
				changeObjectColor(_gameData.currentStyling, _gameData.red, _gameData.green, _gameData.blue);
			}
			
			// CHANGE CURRENT STYLING OBJECT
			if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_HERO)) {
				_gameData.currentStyling = "hero";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_BG)) {
				_gameData.currentStyling = "bg";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_PLAT)) {
				_gameData.currentStyling = "platform";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_ENEMIES)) {
				_gameData.currentStyling = "enemies";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_BULLETS)) {
				_gameData.currentStyling = "bullets";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_COINS)) {
				_gameData.currentStyling = "coins";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_LIVES)) {
				_gameData.currentStyling = "lifes";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_MOVINGPLATS)) {
				_gameData.currentStyling = "movingplatforms";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_TRAMPOLINE)) {
				_gameData.currentStyling = "trampolines";
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTSTYLING_TRAPS)) {
				_gameData.currentStyling = "traps";
			}
			
			
			// CHANGE SHAPE OF SELECTED ITEM
			if (_ce.input.justDid(Actions.CHANGE_SHAPE_RECT)) {
				_gameData.currentShape = Shapes.RECTANGLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_TRIANGLE)) {
				_gameData.currentShape = Shapes.TRIANGLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_CIRCLE)) {
				_gameData.currentShape = Shapes.CIRCLE;
				changeObjectShape();
			}if (_ce.input.justDid(Actions.CHANGE_SHAPE_HEXAGON)) {
				_gameData.currentShape = Shapes.HEXAGON;
				changeObjectShape();
			}
			
			
			// CHANGE CURRENT STYLING OBJECT
			if (_ce.input.justDid(Actions.SELECTED_CURRENTAUDIO_COINS)) {
				_gameData.currentAudio = Sounds.COIN;
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTAUDIO_HIT)) {
				_gameData.currentAudio = Sounds.HIT;
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTAUDIO_JUMP)) {
				_gameData.currentAudio = Sounds.JUMP;
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTAUDIO_LIFES)) {
				_gameData.currentAudio = Sounds.LIFE;
			} if (_ce.input.justDid(Actions.SELECTED_CURRENTAUDIO_SHOOT)) {
				_gameData.currentAudio = Sounds.SHOOT;
			} 
				
			handleAudioChanged();
		}
		
		private function handleAudioChanged():void {
			
			if(_ce.input.isDoing(Actions.AUDIO_STARTFREQUENCY)) {
				var action:InputAction = _ce.input.getAction(Actions.AUDIO_STARTFREQUENCY) as InputAction;
				var newMappedValue : Number = getStartFreqRangeByType(action.value);

				_sounds.SetStartFrequency(_gameData.currentAudio, newMappedValue);
				clearTimeout(audioInterval);
				audioInterval = setTimeout(_sounds.playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, _gameData.currentAudio);
			}
			
			if(_ce.input.isDoing(Actions.AUDIO_ENDFREQUENCY)) {
				action = _ce.input.getAction(Actions.AUDIO_ENDFREQUENCY) as InputAction;
				newMappedValue = getEndFreqRangeByType(action.value);
				
				_sounds.SetEndFrequency(_gameData.currentAudio, newMappedValue);
				clearTimeout(audioInterval);
				audioInterval = setTimeout(_sounds.playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, _gameData.currentAudio);
			}
			
			if(_ce.input.isDoing(Actions.AUDIO_SLIDE)) {
				action = _ce.input.getAction(Actions.AUDIO_SLIDE) as InputAction;
				newMappedValue = getSlideRangeByType(action.value);
				
				_sounds.SetSlide(_gameData.currentAudio, newMappedValue);
				clearTimeout(audioInterval);
				audioInterval = setTimeout(_sounds.playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, _gameData.currentAudio);
			}
			
			if(_ce.input.isDoing(Actions.AUDIO_DURATION)) {
				action = _ce.input.getAction(Actions.AUDIO_DURATION) as InputAction;
				newMappedValue = getDurationRangeByType(action.value);
				
				_sounds.SetDuration(_gameData.currentAudio, newMappedValue);
				clearTimeout(audioInterval);
				audioInterval = setTimeout(_sounds.playAudioFeedBack, AUDIO_FEEDBACK_DELAYTIME, _gameData.currentAudio);
			}
			
		}
		
		private function getStartFreqRangeByType(originalValue: int): Number {
			var startFreq : Number = 0;
			switch (_gameData.currentAudio){
				case Sounds.COIN:
					startFreq = Functions.map(originalValue, 0, 1023, SoundRange.COIN_STARTFREQUENCY.x, SoundRange.COIN_STARTFREQUENCY.y);
					break;
				case Sounds.HIT:
					startFreq = Functions.map(originalValue, 0, 1023, SoundRange.HIT_STARTFREQUENCY.x, SoundRange.HIT_STARTFREQUENCY.y);
					break;
				case Sounds.JUMP:
					startFreq = Functions.map(originalValue, 0, 1023, SoundRange.JUMP_STARTFREQUENCY.x, SoundRange.JUMP_STARTFREQUENCY.y);
					break;
				case Sounds.LIFE:
					startFreq = Functions.map(originalValue, 0, 1023, SoundRange.LIFE_STARTFREQUENCY.x, SoundRange.LIFE_STARTFREQUENCY.y);
					break;
				case Sounds.SHOOT:
					startFreq = Functions.map(originalValue, 0, 1023, SoundRange.SHOOT_STARTFREQUENCY.x, SoundRange.SHOOT_STARTFREQUENCY.y); 
					break;
			}
			return startFreq;
		}		
		
		private function getEndFreqRangeByType(value:Number):Number {
			var endFreq : Number = 0;
			switch (_gameData.currentAudio){
				case Sounds.COIN:
					endFreq = Functions.map(value, 0, 1023, SoundRange.COIN_ENDFREQUENCY.x, SoundRange.COIN_ENDFREQUENCY.y);
					break;
				case Sounds.HIT:
					endFreq = Functions.map(value, 0, 1023, SoundRange.HIT_ENDFREQUENCY.x, SoundRange.HIT_ENDFREQUENCY.y);
					break;
				case Sounds.JUMP:
					endFreq = Functions.map(value, 0, 1023, SoundRange.JUMP_ENDFREQUENCY.x, SoundRange.JUMP_ENDFREQUENCY.y);
					break;
				case Sounds.LIFE:
					endFreq = Functions.map(value, 0, 1023, SoundRange.LIFE_ENDFREQUENCY.x, SoundRange.LIFE_ENDFREQUENCY.y);
					break;
				case Sounds.SHOOT:
					endFreq = Functions.map(value, 0, 1023, SoundRange.SHOOT_ENDFREQUENCY.x, SoundRange.SHOOT_ENDFREQUENCY.y); 
					break;
			}
			return endFreq;
		}
		
		private function getSlideRangeByType(value:Number):Number {
			var slide : Number = 0;
			switch (_gameData.currentAudio){
				case Sounds.COIN:
					slide = Functions.map(value, 0, 1023, SoundRange.COIN_SLIDE.x, SoundRange.COIN_SLIDE.y);
					break;
				case Sounds.HIT:
					slide = Functions.map(value, 0, 1023, SoundRange.HIT_SLIDE.x, SoundRange.HIT_SLIDE.y);
					break;
				case Sounds.JUMP:
					slide = Functions.map(value, 0, 1023, SoundRange.JUMP_SLIDE.x, SoundRange.JUMP_SLIDE.y);
					break;
				case Sounds.LIFE:
					slide = Functions.map(value, 0, 1023, SoundRange.LIFE_SLIDE.x, SoundRange.LIFE_SLIDE.y);
					break;
				case Sounds.SHOOT:
					slide = Functions.map(value, 0, 1023, SoundRange.SHOOT_SLIDE.x, SoundRange.SHOOT_SLIDE.y); 
					break;
			}
			return slide;
		}
		
		private function getDurationRangeByType(value:Number):Number {
			var duration : Number = 0;
			switch (_gameData.currentAudio){
				case Sounds.COIN:
					duration = Functions.map(value, 0, 1023, SoundRange.COIN_DURATION.x, SoundRange.COIN_DURATION.y);
					break;
				case Sounds.HIT:
					duration = Functions.map(value, 0, 1023, SoundRange.HIT_DURATION.x, SoundRange.HIT_DURATION.y);
					break;
				case Sounds.JUMP:
					duration = Functions.map(value, 0, 1023, SoundRange.JUMP_DURATION.x, SoundRange.JUMP_DURATION.y);
					break;
				case Sounds.LIFE:
					duration = Functions.map(value, 0, 1023, SoundRange.LIFE_DURATION.x, SoundRange.LIFE_DURATION.y);
					break;
				case Sounds.SHOOT:
					duration = Functions.map(value, 0, 1023, SoundRange.SHOOT_DURATION.x, SoundRange.SHOOT_DURATION.y); 
					break;
			}
			return duration;
		}
		
		
		
		
		
		public function placeFinish(heroPos:Point):void {
			var finishes:Vector.<CitrusObject> = getObjectsByType(Finish);
			var finish:Finish;
			for each (finish in finishes) remove(finish);
			
			var longestDistance : Number = 0;
			var fartestTile : Point = new Point(0,0);
			var mW:int = _lvl.map[0].length;
			var mH:int = _lvl.map.length;
			
			for (var y:int=0; y<mH; y++) {
				for (var x:int=0; x<mW; x++) {
					if (_lvl.map[y][x] != Tile.LAND && Functions.isLinkedBottom(_lvl.map, x, y, Tile.LAND) ) {
						if (longestDistance < MathUtils.DistanceBetweenTwoPoints(heroPos.x, x, heroPos.y, y)) {
							longestDistance = MathUtils.DistanceBetweenTwoPoints(heroPos.x, x, heroPos.y, y);
							fartestTile = new Point(x,y);
						}
					}
				}
			}
			
			var finish = new Finish("finish", {x : fartestTile.x * _tileSize + _tileSize/2, y: fartestTile.y * _tileSize + _tileSize/2, width: _tileSize, height: _tileSize});
			finish.onBeginContact.add(handleFinishTouched);
			add(finish);
			
		}
		
		private function handleFinishTouched(contact:b2Contact):void {
			var other:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(getObjectByName("getObjectByName") as Finish, contact);
			if (other is ExHero) {
			
				var finishes:Vector.<CitrusObject> = getObjectsByType(Finish);
				var finish:Finish;
				for each (finish in finishes) remove(finish);
				
				setTimeout(function() : void{
					placeFinish(new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize)));
				}, 500);

				
			}
		}

		
		private function drawPlatformsToMiniMap():void{
			_debugSprite.graphics.lineStyle();
			_debugSprite.graphics.beginFill(0x000000, 0.2);
			var platforms:Vector.<CitrusObject> = getObjectsByType(Platform);
			var platfromm:CitrusObject;
			for each (platfromm in platforms) {
				_debugSprite.graphics.drawRect((platfromm as Platform).x - (platfromm as Platform).width / 2, (platfromm as Platform).y - (platfromm as Platform).height / 2, (platfromm as Platform).width, (platfromm as Platform).height);
			}
		}
		private function drawEnemiesToMiniMap():void{
			_debugSprite.graphics.lineStyle();
			_debugSprite.graphics.beginFill(0xff0000, 0.2);
			var enemies:Vector.<CitrusObject> = getObjectsByType(ExEnemy);
			var enemy:CitrusObject;
			for each (enemy in enemies) {
				_debugSprite.graphics.drawRect((enemy as ExEnemy).x - (enemy as ExEnemy).width / 2, (enemy as ExEnemy).y - (enemy as ExEnemy).height / 2, (enemy as ExEnemy).width, (enemy as ExEnemy).height);
			}
		}
		
		
		private function redrawLevel(type:String):void {
			
			var heroPos:Point = new Point(Math.floor(_hero.x/_tileSize), Math.floor(_hero.y/_tileSize));
			for each (var object:CitrusObject in objects) { // remove old platforms
				if (object is Platform) { // this removes also the moving platforms
					object.kill = true; 
					remove(object);
				}
			}
			
			if(type == "cave"){
				_mapW = 90;
				_mapH = 40;	
				_lvl = CaveGenerator.createlevel(_mapW, _mapH, heroPos, _hero);
			} else if (type == "mario") {
				_mapW = 100;
				_mapH = 25;
				_lvl = MarioGenerator.createlevel(_mapW, _mapH, 533, Functions.randomIntRange(1,10), 1, heroPos, _hero);
			}
			
			
			_bounds = new Rectangle(0, 0, _mapW*_tileSize, _mapH*_tileSize);
			_camera.bounds = _bounds; 
			
//			_camera.bounds = new Rectangle(0, 0, mapW*tileSize, mapH*tileSize); 
			_lvl.drawMapPlaftormsToGameState(this, _tileSize, _gameData.levelColor, false, heroPos);
			
			var heroContactList : b2ContactEdge = _hero.body.GetContactList(); // Force begin contact, with new platform.. otherwise is doesn't and then.. you can't jump
			if (heroContactList) for (var contact: b2Contact = _hero.body.GetContactList().contact ; contact ; contact = contact.GetNext())  _hero.handleBeginContact(contact);
			
			// DO PLACE ENEMIES BACK IF THERE ARE ANY IN THE STATE
			if (getObjectsByType(EdgeDetectorEnemy).length > 0) {
				_lvl.placeEnemies(this, _gameData.enemyPercentage, heroPos, _gameData.enemyColor, _gameData.enemyShape);// replace enemies
				_gameData.totalEnemies = _lvl.getTotalEnemiesAmount; // save total enemies for the enemy kill counter
			}
			
			if (getObjectsByType(StaticTrap).length > 0) {
				_lvl.placeStaticTraps(this, _gameData.trapPercantage, heroPos, _gameData.trapColor, _gameData.trapShape);
			}
			
			if (getObjectsByType(Trampoline).length > 0) {
				_lvl.placeTrampolines(this, _gameData.trampolinePercantage, _gameData.trampolineColor, _gameData.trampolineBoost);
			}
			
			if (getObjectsByType(ExMovingPlatform).length > 0) {
				_lvl.placeMovingPlatforms(this, _gameData.movingPlatsPercantage, _gameData.movingPlatColor, _gameData.movingPlatformSpeed);
			}
			
			if (getObjectsByType(Coin).length > 0) {
				_lvl.placeCoinCollectables(this, _gameData.coinsPercantage, _gameData.coinColor, _gameData.coinShape);
			}
			
			if (getObjectsByType(Life).length > 0) {
				_lvl.placeLiveCollectables(this, _gameData.livesPercantage, _gameData.lifeColor, _gameData.lifeShape);
			}
			
			removeFinishSensor();
			if(_gameData.goal == Goals.A_TO_B)  placeFinish(new Point(Math.floor(_hero.x/_tileSize),Math.floor(_hero.y/_tileSize)));
		}	
		
		
		private function changeObjectShape():void {
			
			if (_gameData.currentStyling == "hero") {
				var object : ExBox2DPhysicsObject = getObjectByName("hero") as ExBox2DPhysicsObject;
				object.currentShape = _gameData.currentShape;
		
				var height : Number = object.currentHeight;
				var width : Number =  object.currentWidth;
				
				object.view = drawObjectView(object.currentColor, object.currentShape, width, height);
			}
			else if (_gameData.currentStyling == "enemies") {
				for each (var citrusObject :CitrusObject in objects) {
					if (citrusObject is ExEnemy) {
						var enemy : ExEnemy = citrusObject as ExEnemy;
						enemy.currentShape = _gameData.currentShape;
						_gameData.enemyShape = enemy.currentShape; 
						
						var width = enemy.width;
						var height = enemy.height;
						
						enemy.view = drawObjectView(enemy.currentColor, enemy.currentShape, width, height);
					}
				}
			} 
			else if (_gameData.currentStyling == "coins") {
				var coin : Coin;
				for each (citrusObject in objects) {
					if (citrusObject is Coin) {
						coin = citrusObject as Coin;
						coin.currentShape = _gameData.currentShape;	
						_gameData.coinShape = coin.currentShape;

						coin.view = drawObjectView(coin.currentColor, coin.currentShape, coin.width, coin.height);
					}
				}
			} 
			else if (_gameData.currentStyling == "lifes") {
				var life : Life;
				for each (citrusObject in objects) {
					if (citrusObject is Life) {
						life = citrusObject as Life;
						life.currentShape = _gameData.currentShape;	
						_gameData.lifeShape = _gameData.currentShape;
						
						life.view = drawObjectView(life.currentColor, life.currentShape, life.width, life.height);
					}
				}
			} 
			else if (_gameData.currentStyling == "bullets") {
				_gameData.bulletShape = _gameData.currentShape;
			}
			
			else if (_gameData.currentStyling == "traps") {
				var trap : StaticTrap;
				for each (citrusObject in objects) {
					if (citrusObject is StaticTrap) {
						trap = citrusObject as StaticTrap;
						trap.currentShape = _gameData.currentShape;	
						_gameData.trapShape = _gameData.currentShape;
						
						trap.view = StarlingShape.CombinedShape(trap.currentShape, trap.width, trap.currentHeight, trap.currentColor);
					}
				}
			} 
		}
		
		
		private function changeObjectColor(name : String , red : int, green : int, blue : int):void{
			var hex:uint = red << 16 | green << 8 | blue;
			var width : int;
			var height : int;
			
			if (name == "platform") {
				_gameData.levelColor = hex;
				_lvl.drawQuadMap(this, _tileSize, hex);
				return;
			} else if ( name == "bg") {
				stage.color = hex;
				return;
			} else if (name == "hero") { 
				var object : ExBox2DPhysicsObject = getObjectByName(name) as ExBox2DPhysicsObject;
				object.currentColor = hex;
				height = object.currentHeight;
				width =  object.currentWidth;
				
				object.view = drawObjectView(object.currentColor, object.currentShape, width, height);
			} 
			else if (name == "enemies") {
				var enemy : EdgeDetectorEnemy;
				for each (var citrusObject :CitrusObject in objects) {
					if (citrusObject is EdgeDetectorEnemy) {
						enemy = citrusObject as EdgeDetectorEnemy;
						enemy.currentColor = hex;
						_gameData.enemyColor = hex;
						width = enemy.width;
						height = enemy.height;
						
						enemy.view = drawObjectView(enemy.currentColor, enemy.currentShape, width, height);
					}
				}
			} else if (name == "bullets") {
				_gameData.bulletColor = hex;
			}
			else if (name == "movingplatforms") {
				var movingPlatform : ExMovingPlatform;
				for each (citrusObject  in objects) {
					if (citrusObject is ExMovingPlatform) {
						movingPlatform = citrusObject as ExMovingPlatform;
						movingPlatform.currentColor = hex;
						_gameData.movingPlatColor = hex;
						movingPlatform.view = StarlingShape.Rectangle(movingPlatform.width, movingPlatform.height, movingPlatform.currentColor);
					}
				}
			}
			else if (name == "trampolines") {
				var trampoline : Trampoline;
				for each (citrusObject in objects) {
					if (citrusObject is Trampoline) {
						trampoline = citrusObject as Trampoline;
						trampoline.currentColor = hex;
						_gameData.trampolineColor = hex;
						trampoline.view = StarlingShape.Rectangle(trampoline.width, trampoline.height, trampoline.currentColor);
					}
				}
			}
			else if (_gameData.currentStyling == "coins") {
				var coin : Coin;
				for each (citrusObject in objects) {
					if (citrusObject is Coin) {
						coin = citrusObject as Coin;
						coin.currentColor = hex;	
						_gameData.coinColor = hex;
						
						coin.view = drawObjectView(coin.currentColor, coin.currentShape, coin.width, coin.height);
					}
				}
			} 
			else if (_gameData.currentStyling == "lifes") {
				var life : Life;
				for each (citrusObject in objects) {
					if (citrusObject is Life) {
						life = citrusObject as Life;
						life.currentColor = hex;	
						_gameData.lifeColor = hex;
						
						life.view = drawObjectView(life.currentColor, life.currentShape, life.width, life.height);
					}
				}
			} 
			
			else if (_gameData.currentStyling == "traps") {
				var trap : StaticTrap;
				for each (citrusObject in objects) {
					if (citrusObject is StaticTrap) {
						trap = citrusObject as StaticTrap;
						trap.currentColor = hex;	
						_gameData.trapColor = hex;
						trap.view = StarlingShape.CombinedShape(trap.currentShape, trap.width, trap.currentHeight, trap.currentColor);
					}
				}
			} 
			
			
			
		}

		
		
		private function drawObjectView(color:uint, shape:String, width:int, height : int):Shape {
			var view : starling.display.Shape = new Shape();
			switch (shape){
				case Shapes.CIRCLE:
					view = StarlingShape.Circle(width, color);
					break;
				case Shapes.HEXAGON:
					view = StarlingShape.polygon(width, 6, color);
					break;
				case Shapes.RECTANGLE:
					view = StarlingShape.Rectangle(width, height, color);
					break;
				case Shapes.TRIANGLE:
					view = StarlingShape.Triangle(width, height, color);
					break;
			}	
			
			return view;
		}		
		
		
			
			
	
	}
}