package utils
{
	class ObjSize
	{
		
		private var _width;
		private var _height;
		
		function ObjSize (x:Number, y:Number)
		{
			this._width = x || 0;
			this._height = y || 0;
		}
		
		
		public function get width():Number
		{
			return this._width;
		}
		
		
		public function get height():Number
		{
			return this._height;
		}
		
		
		public function get length ():Number
		{
			return Math.sqrt(this._width * this._width + this._height * this._height);
		}
		
		
		public static function interpolate(pt1:ObjSize, pt2:ObjSize, f:Number):ObjSize
		{
			return new ObjSize(f * pt1._width + (1 - f) * pt2._width, f * pt1._height + (1 - f) * pt2._height);
		}
		
		
		public static function distance(a:ObjSize, b:ObjSize):Number
		{
			var dw:Number = b._width - a._width;
			var dh:Number = b._height - a._height;
			
			return Math.sqrt(dw * dw + dh * dh);
		}
		
		
		public static function polar(len:Number, angle:Number):ObjSize
		{
			return new ObjSize(len * Math.cos(angle), len * Math.sin(angle));
		}
		
		
		public function clone():ObjSize
		{
			return new ObjSize(this._width, this._height);
		}
		
		
		public function offset(dw:Number, dh:Number):void
		{
			this._width += dw;
			this._height += dh;
		}
		
		
		public function equals(toCompare:Object):Boolean
		{
			//	slower!
			//	return ((toCompare instanceof Size) && (toCompare._width == this._width) && (toCompare._height == this._height));
			
			//	faster!
			if (!(toCompare instanceof ObjSize))
			{
				return false;
			}
			if  (toCompare._width != this._width)
			{
				return false;
			}
			if (toCompare._height != this._height)
			{
				return false;
			}
			return true;
		}
		
		
		public function subtract(other:ObjSize)
		{
			var p = new ObjSize(this._width, this._height);
			p._width -= other._width;
			p._height -= other._height;
			return p;
		}
		
		
		public function add(other:ObjSize)
		{
			var p = new ObjSize(this._width, this._height);
			p._width += other._width;
			p._height += other._height;
			return p;
		}
		
		
		public function normalize(length:Number):void
		{
			var l = this.length;
			if (l > 0)
			{
				var factor = length/l;
				this._width *= factor;
				this._height *= factor;
			}
		}
		
		
		public function toString():String
		{
			return ("(x=" + this._width + ", y=" + this._height + ")");
		}
		
		
	}
}