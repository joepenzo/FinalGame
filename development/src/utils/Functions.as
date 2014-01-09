package utils
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DShapeMaker;
	
	import data.types.Shapes;
	import data.types.Tile;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import objects.ExBox2DPhysicsObject;
	import objects.StaticTrap;
	
	import starling.display.Image;
	import starling.display.Shape;
	import starling.textures.Texture;

	public class Functions
	{
		
		
		public static function shapeToImage(shape : flash.display.Shape) : Image {
			var bmd:BitmapData = new BitmapData(shape.width, shape.height, true, 0x000000);
			bmd.draw(shape);
			var img:Image = new Image(Texture.fromBitmapData(bmd));
			img.smoothing = "none"; 
			return img;
			
			/*
			//No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles.
			public static const NONE:String      = "none";
			//Bilinear filtering. Creates smooth transitions between pixels.
			public static const BILINEAR:String  = "bilinear";
			// Trilinear filtering. Highest quality by taking the next mip map level into account.
			public static const TRILINEAR:String = "trilinear";
			*/
		}
		
		
		public static function ResizeObject(state : StarlingState, scaleUp : Boolean, objectName : String, reDrawView : Boolean = true) : void { // Works for rectangle shape now
			// TODO :: if  hero is standing on top of the object, shit get's fucked up!
			var mult : Number;
			if (scaleUp) {
				mult = 1.05;
			} else {
				mult = .95;
			}
			var object : Box2DPhysicsObject = state.getObjectByName(objectName) as Box2DPhysicsObject;
			var body : b2Body = object.getBody() as b2Body;
			
			var oldPolygon : b2PolygonShape = body.GetFixtureList().GetShape() as b2PolygonShape;
			var vertexArray : Vector.<b2Vec2> = oldPolygon.GetVertices() as Vector.<b2Vec2>;
			for each (var vert:b2Vec2 in vertexArray) {
				vert.Multiply(mult);
			}
			
			var newShape : b2PolygonShape = new b2PolygonShape();
			newShape.SetAsVector(vertexArray);
			
			body.DestroyFixture(body.GetFixtureList());
			body.CreateFixture2(newShape); // TODO: Add density?
			
			if (reDrawView) {
				var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
				var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
//				object.view = StarlingDraw.RectangleShape(width,height, 0x2E2E2E);
				object.view = StarlingDraw.RectangleImage(width,height, 0x2E2E2E);
			}
			
		}
		
		
		public static function ResizeObjectValue(state : StarlingState, newW:Number, newH: Number, object : ExBox2DPhysicsObject, reDrawView : Boolean = true) : void { // Works for rectangle shape now
			var object : ExBox2DPhysicsObject = object as ExBox2DPhysicsObject;
			var body : b2Body = object.getBody() as b2Body;
			var newShape:b2PolygonShape = Box2DShapeMaker.BeveledRect(newW, newH, 0.1);
			
			body.DestroyFixture(body.GetFixtureList());
			body.CreateFixture2(newShape); // TODO: Add density?
			
			if (reDrawView) {
				var height : Number = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30; // standard box2d scale 30
				var width : Number = (body.GetFixtureList().GetAABB().upperBound.x - body.GetFixtureList().GetAABB().lowerBound.x) * 30; // standard box2d scale 30
//				object.view = StarlingDraw.RectangleShape(width,height, 0x2E2E2E);
//				object.view = StarlingDraw.RectangleImage(width,height, object.currentColor);
				
				switch (object.currentShape){
					case Shapes.CIRCLE:
						object.view = StarlingShape.Circle(width, object.currentColor);
						break;
					case Shapes.HEXAGON:
						object.view = StarlingShape.polygon(width, 6, object.currentColor);
						break;
					case Shapes.RECTANGLE:
						object.view = StarlingShape.Rectangle(width, height, object.currentColor);
						break;
					case Shapes.TRIANGLE:
						object.view = StarlingShape.Triangle(width, height, object.currentColor);
						break;
				}
			}
			
		}
		
		
		public static function ResizeTrap(state : StarlingState, newH: Number, object : StaticTrap, tileSize : int) : void { // Works for rectangle shape now
			var trap : StaticTrap = object as StaticTrap;
			var body : b2Body = trap.getBody() as b2Body;
			var oldhHeight : int = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30;			
		
			var newShape:b2PolygonShape = Box2DShapeMaker.Rect(tileSize/30, newH);
			body.DestroyFixture(body.GetFixtureList());
			body.CreateFixture2(newShape); // TODO: Add density?
			var newHeight : int = (body.GetFixtureList().GetAABB().upperBound.y - body.GetFixtureList().GetAABB().lowerBound.y) * 30;
			trap.y += (oldhHeight - newHeight)/2;
			
			var shape :Shape = trap.view as starling.display.Shape;
			shape.height = newHeight;
			shape.y = -newHeight/2;

		}
		
		
		public static function findClosetObjectToPoint(position : Point, objectsArray : *):* {
			var elementPoint:Point = new Point();
			var element:*;
			var closestIndex:uint = 0;
			var closestDist:Number;
			
			// Loop through elements
			for (var i:int = 0; i < objectsArray.length; i++) 
			{
				element = objectsArray[i];
				
				// Set the elementPoint's x and y rather than creating a new Point object.
				elementPoint.x = element.x;
				elementPoint.y = element.y;
				
				// Find distance from mouse to element.
				var dist:Number = Point.distance(position, elementPoint);
				
				// Update closestIndex and closestDist if it's the closest.
				if (i == 0 || dist < closestDist) 
				{
					closestDist = dist;
					closestIndex = i;
				}
			}
			//trace('The closest element is at index', closestIndex, ', with a distance of', closestDist);			
			return objectsArray[closestIndex]; 
		}
		
		public static  function resizeDisplayObject(mc:DisplayObject, maxW:Number, maxH:Number=0, constrainProportions:Boolean=true):void{
			maxH = maxH == 0 ? maxW : maxH;
			mc.width = maxW;
			mc.height = maxH;
			if (constrainProportions) {
				mc.scaleX < mc.scaleY ? mc.scaleY = mc.scaleX : mc.scaleX = mc.scaleY;
			}
		}
		
		
		
		public static function randomIntRange(start:Number, end:Number):int {
			return int(randomNumberRange(start, end));
		}
		
		public static function randomNumberRange(start:Number, end:Number):Number {
			end++;
			return start + (Math.random() * (end - start));
		}
		
		
		public static function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number {
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
			
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}
		
		public static function trace2DArray(array : Array) : void {
			notice("\nArray:");
			//for (var i:int = 0; i < array[0].length; i++) {
			for (var i:int = 0; i < array.length; i++) {
				debug(array[i]);
			}
		}

		public static function swapIn2DArray(array : Array, oldI : int, newI : int) : void {
			for ( var row:int = 0; row < array.length; row++ ) {
				for ( var column:int = 0; column < array[row].length; column++ ) {
					if (array[row][column] == oldI) array[row][column] = newI; 
				} 
			}
		}
		
		
		
		
		
		
		public static function isLinkedRight(mapArr: Array, x:int,y:int,match:int):Boolean {
			if (mapArr[y][x+1] == match) { // right
				return true;
			}
			return false;
		}
		
		public static function isLinkedLeft(mapArr: Array, x:int,y:int,match:int):Boolean {
			if (mapArr[y][x-1] == match) { // left
				return true;
			}
			return false;
		}	
		
		public static function isLinkedBottom(mapArr: Array, x:int,y:int,match:int):Boolean {
			if ( y >= mapArr.length-1) return false;
			if (mapArr[y+1][x] == match) { // bottom
				return true;
			}
			return false;
		}
		
		public static function isLinkedTop(mapArr: Array, x:int,y:int,match:int):Boolean {
			if (y <= 0) return false;
			if (mapArr[y-1][x] == match) { // top
				return true;
			}
			return false;
		}
		
		
	}
}