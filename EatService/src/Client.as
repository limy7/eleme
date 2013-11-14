package
{
	import com.adobe.serialization.json.AdobeJSON;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;

	public class Client
	{
		public var name:String;
		
		public var socket:Socket;
		
		/**正在读取的数据的总长度*/
		public var dataLength:uint;
		
		
		public function Client(socket:Socket, name:String)
		{
			this.socket = socket;
			this.name = name;
		}
		
		
		
		/**
		 * 给该客户端发送数据
		 * @param data
		 */
		public function sendData(command:String, data:*, state:int = 1):void
		{
			if(!(data is String)) {
				data = AdobeJSON.encode(data);
			}
			
			var cmd:ByteArray = new ByteArray();
			cmd.writeUTFBytes(command);
			cmd.length = 32;
			
			var content:ByteArray = new ByteArray();
			content.writeUTFBytes(data);
			
			//方法1
			socket.writeInt(cmd.length + content.length);
	
			socket.writeBytes(cmd);
			socket.writeBytes(content);
			
			socket.flush();
		}
		//
	}
}