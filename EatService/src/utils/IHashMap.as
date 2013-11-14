package utils
{
	import flash.utils.Dictionary;

	public interface IHashMap
	{
		/**通过键取值*/
		function getValueByKey(key:*):*;
		/**通过索引取值*/
		function getValueByIndex(index:uint):*;
		
		/**通过键获取索引*/
		function getIndexByKey(key:*):int;
		/**通过值获取索引*/
		function getIndexByValue(value:*):int;
		/**通过键列表获取索引*/
		function getIndexByKeys(keys:Array):int;
		
		/**通过索引获得键列表*/
		function getKeysByIndex(index:uint):Array;
		
		/**通过索引设置值*/
		function setValueByIndex(index:uint, value:*):void;
		/**通过键设置值*/
		function setValueByKey(key:*, value:*):void;
		
		/**值列表*/
		function get values():Array;
		function set values(value:Array):void;
		
		/**键列表*/
		function get keys():Dictionary;
		function set keys(value:Dictionary):void;
		
		/**移除某个键与值的映射关系*/
		function removeKey(key:*):void;
		/**通过键移除对应的键与值*/
		function removeByKey(key:*):void;
		/**通过索引移除对应的键与值*/
		function removeByIndex(index:uint):void;
		
		/**添加一个值,以及对应的键列表，并返回该值的索引*/
		function add(value:*, ...keys):uint;
		
		/**通过索引为该值添加一个键，并返回该值的索引*/
		function addKeyByIndex(newKey:*, index:uint):uint;
		/**通过键为该值添加一个键，并返回该值的索引，如果没有源键将返回-1*/
		function addKeyByKey(newKey:*,key:*):int;
		
		/**清空*/
		function clear():void;
		
		/**克隆*/
		function clone():IHashMap;
		
		/**值的数量*/
		function get length():uint;
			
		
	}
}