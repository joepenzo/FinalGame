package objects
{
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	
	import flash.display.BitmapData;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;

	public class Finish extends ExSensor
	{
		public function Finish(name:String, params:Object=null)
		{
			super(name, params);
			
			this.view = drawFlag();
			
		}
		
		private function drawFlag():QuadBatch {
			var quadBatch:QuadBatch = new QuadBatch();
		
			var texBl:Texture = Texture.fromBitmapData(new BitmapData(width/3, height/3, true));
			var black:Image = new Image(texBl);
			black.color = 0x000000;
			
			var texWh:Texture = Texture.fromBitmapData(new BitmapData(width/3, height/3, true));
			var white:Image = new Image(texWh);
			white.color = 0xffffff;
			
			
			black.x = 0; black.y = 0;
			quadBatch.addImage(black);
			
			white.x = width/3*1; white.y = 0;
			quadBatch.addImage(white);
			
			black.x = width/3*2; black.y = 0;
			quadBatch.addImage(black);
			
			
			
			white.x = 0; white.y =  height/3*1;
			quadBatch.addImage(white);
			
			black.x = width/3*1; black.y = height/3*1;
			quadBatch.addImage(black);
			
			white.x = width/3*2; white.y = height/3*1;
			quadBatch.addImage(white);
			
			
			black.x = 0; black.y = height/3*2;
			quadBatch.addImage(black);
			
			white.x = width/3*1; white.y = height/3*2;
			quadBatch.addImage(white);
			
			black.x = width/3*2; black.y = height/3*2;
			quadBatch.addImage(black);
			
			return quadBatch;
		}
		
		
	}
}