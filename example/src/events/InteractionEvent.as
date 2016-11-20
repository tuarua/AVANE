package events {
	import starling.events.Event;
	public class InteractionEvent extends Event {
		public static const ON_MENU_ITEM_MENU:String = "onMenuItemMenu";
		public static const ON_MENU_ITEM_RIGHT:String = "onMenuItemRight";
		public static const ON_CLOSE:String = "onClose";
		public static const ON_ENCODE:String = "onEncode";
		
		public static const ON_CONTROLS_PLAY:String = "onControlsPlay";
		public static const ON_CONTROLS_PAUSE:String = "onControlsPause";
		public static const ON_CONTROLS_STATS:String = "onControlsStats";
		public static const ON_CONTROLS_FFWD:String = "onControlsFfwd";
		public static const ON_CONTROLS_REWIND:String = "onControlsRewind";
		public static const ON_CONTROLS_SEEK:String = "onControlsSeek";
		public static const ON_CONTROLS_MUTE:String = "onControlsMute";
		public static const ON_CONTROLS_SETVOLUME:String = "onControlsSetVolume";
		
		public static const ON_PLAYER_SHOW_CONTROLS:String = "onPlayerShowControls";
		public static const ON_PLAYER_HIDE_CONTROLS:String = "onPlayerHideControls";
		
		public var params:Object;
		
		public function InteractionEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}