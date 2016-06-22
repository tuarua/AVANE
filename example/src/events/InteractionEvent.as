package events {
	import starling.events.Event;
	public class InteractionEvent extends Event {
		public static const ON_MENU_ITEM_MENU:String = "onMenuItemMenu";
		public static const ON_MENU_ITEM_RIGHT:String = "onMenuItemRight";
		public static const ON_CLOSE:String = "onClose";
		public static const ON_ENCODE:String = "onEncode";
		public var params:Object;
		
		public function InteractionEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}