package utils
{
	import flash.utils.Dictionary;
	
	public class HashMap implements IHashMap
	{
		/**值列表*/
		private var _values:Array;
		/**与值列表对应的键列表*/
		private var _keys:Dictionary;
		
		public function HashMap(values:Array=null, keys:Dictionary=null)
		{
			_values = (values == null) ? [] : values;
			_keys = (keys == null) ? new Dictionary() : keys;
		}
		
		/**通过键取值*/
		public function getValueByKey(key:*):*
		{
			if(_keys[key] == undefined)return null;
			return getValueByIndex(_keys[key]);
		}
		/**通过索引取值*/
		public function getValueByIndex(index:uint):*
		{
			return _values[index];
		}
		/**通过键获取索引, 没有则返回 -1*/
		public function getIndexByKey(key:*):int
		{
			return (_keys[key] == undefined ? -1 : _keys[key]);
		}
		/**通过值获取索引*/
		public function getIndexByValue(value:*):int
		{
			for(var i:int=0; i < _values.length; i++)
			{
				if( _values[i] == value) return i;
			}
			
			return -1;
		}
		/**通过键列表获取索引。如果没有keys对应的index，则返回-1*/
		public function getIndexByKeys(keys:Array):int
		{
			if(keys == null || keys.length == 0) return -1;
			
			var index:int = -1;
			var key:*;
			for(var i:int=0; i < keys.length; i++)
			{
				key = keys[i];
				
				if(_keys[key] == undefined) return -1;//没有这个key
				
				if(index != -1){
					if(_keys[key] != index) return -1; //列表中key不一致
				}else{
					index = _keys[key];
				}
			}
			return index;
		}
		/**通过索引获得键列表*/
		public function getKeysByIndex(index:uint):Array
		{
			var keys:Array=[];
			for(var key:* in _keys)
			{
				if(_keys[key] == index) keys.push(key);
			}
			return keys;
		}
		/**通过索引设置值*/
		public function setValueByIndex(index:uint, value:*):void
		{
			_values[index] = value;
		}
		/**通过键设置值*/
		public function setValueByKey(key:*, value:*):void
		{
			if(_keys[key] != undefined) setValueByIndex(_keys[key], value);
		}
		
		public function get values():Array
		{
			return _values;
		}
		
		public function set values(value:Array):void
		{
			_values = value;
		}
		
		public function get keys():Dictionary
		{
			return _keys;
		}
		
		public function set keys(value:Dictionary):void
		{
			_keys = value;
		}
		/**移除某个键与值的映射关系*/
		public function removeKey(key:*):void
		{
			delete _keys[key];
		}
		
		/**通过键移除对应的键与值*/
		public function removeByKey(key:*):void
		{
			if(_keys[key] != undefined) removeByIndex(_keys[key]);		
		}
		
		/**通过索引移除对应的键与值*/
		public function removeByIndex(index:uint):void
		{
			_values.splice(index, 1);
			
			//克隆一份_keys进行for...in操作，直接对_keys操作将会导致for...in无序
			var key:*;
			var keys:Dictionary = new Dictionary();
			for(key in _keys) keys[key] = _keys[key];
			
			//检查key
			for(key in keys)
			{
				//移除相关的key
				if(_keys[key] == index)
				{
					delete _keys[key];
				}
				//后面的索引递减一次
				else if(_keys[key] > index){
					_keys[key] --;
				}				
			}						
		}
		/**添加一个值,以及对应的键列表，并返回该值的索引*/
		public function add(value:*, ...keys):uint
		{
			var index:int = _values.length;
			_values.push(value);
			for(var i:int=0; i < keys.length; i++)
			{
				_keys[keys[i]] = index;
			}
				
			return 0;
		}
		/**通过索引为该值添加一个键，并返回该值的索引*/
		public function addKeyByIndex(newKey:*, index:uint):uint
		{
			_keys[newKey] = index;
			
			return index;
		}
		/**通过键为该值添加一个键，并返回该值的索引，如果没有源键将返回-1*/
		public function addKeyByKey(newKey:*, key:*):int
		{
			if(_keys[key] == null) return -1;
			return addKeyByIndex(newKey, _keys[key]);
		}
		/**清空*/
		public function clear():void
		{
			_values = [];
			_keys = new Dictionary();
		}
		/**克隆*/
		public function clone():IHashMap
		{
			var keys:Dictionary = new Dictionary();
			for(var key:* in _keys) keys[key] = _keys[key];
			return new HashMap(_values.concat(), keys);
		}
		
		public function get length():uint
		{
			return _values.length;
		}
	}
}