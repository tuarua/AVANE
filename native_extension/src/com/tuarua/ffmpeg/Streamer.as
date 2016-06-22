package com.tuarua.ffmpeg {
	import com.tuarua.ffmpeg.events.StreamProviderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Streamer extends EventDispatcher{
		private var serverSocket:ServerSocket;
		private var videoStream:ByteArray;
		private var doSuspend:Boolean = false;
		private var _connected:Boolean;
		private var clientSocket:Socket;
		public function Streamer(ip:String,port:int) {
			super();
			serverSocket = new ServerSocket();
			serverSocket.addEventListener(Event.CLOSE,onClose); 
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT,connectHandler);
			serverSocket.addEventListener(Event.ACTIVATE,onSocketActivated);
			serverSocket.bind(port,ip);
			serverSocket.listen(); 
		}
		public function get connected():Boolean {
			return _connected;
		}
		
		public function init():void {
			doSuspend = false;
		}
		public function close():void {
			if(clientSocket && clientSocket.connected)
				clientSocket.close();
			if(serverSocket && serverSocket.bound)
				serverSocket.close();
		}
		private function connectHandler(event:ServerSocketConnectEvent):void  { 
			_connected = true;
			clientSocket = event.socket as Socket;
			clientSocket.endian = Endian.LITTLE_ENDIAN;
			clientSocket.timeout = 600000;
			clientSocket.addEventListener(ProgressEvent.SOCKET_DATA,socketDataHandler); 
			clientSocket.addEventListener(Event.CLOSE,onClientClose); 
			clientSocket.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			clientSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
		}
		protected function onClientClose(event:Event):void {
			clientSocket.removeEventListener(ProgressEvent.SOCKET_DATA,socketDataHandler); 
			clientSocket.removeEventListener(Event.CLOSE,onClientClose); 
			clientSocket.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
			clientSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
			clientSocket.flush();
			if(videoStream)
				videoStream.clear();
			_connected = false;
			this.dispatchEvent(new StreamProviderEvent(StreamProviderEvent.ON_STREAM_CLOSE));
		}
		public function suspend():void {
			doSuspend = true;
		}
		protected function socketDataHandler(event:Event):void {
			if(!doSuspend){
				videoStream = new ByteArray();
				clientSocket.readBytes(videoStream,0,event.target.bytesAvailable);
				this.dispatchEvent(new StreamProviderEvent(StreamProviderEvent.ON_STREAM_DATA,videoStream));
			}
		}
		protected function onSocketActivated(event:Event):void {
			trace("socket activated",event);
			trace(clientSocket);
			if(clientSocket)
				trace(clientSocket.connected);
		}
		protected function onSocketDeactivated(event:Event):void {
			trace("socket DEactivated",event);
			trace(clientSocket);
			if(clientSocket)
				trace(clientSocket.connected);
			
		}
		protected function onIOError(event:IOErrorEvent):void {
			trace("STREAMER IOError: " + event.text ); 
		}
		protected function onClose(event:Event):void  { 
			trace("STREAMER Server socket closed by OS." ); 
		}
		protected function onSecurityError(event:SecurityErrorEvent):void {
			trace(event);
			trace(event.errorID);
			trace("STREAMER Security error." );
		}
	}
}