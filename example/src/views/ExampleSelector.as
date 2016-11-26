package views {
	import flash.system.Capabilities;
	
	import starling.display.Sprite;
	
	public class ExampleSelector extends Sprite {
		public var universalButton:SimpleButton = new SimpleButton("Universal Player",160);
		public var basicButton:SimpleButton = new SimpleButton("Basic",160);
		public var advancedButton:SimpleButton = new SimpleButton("Advanced",160);
		public var captureButton:SimpleButton = new SimpleButton("Capture Desktop",160);
		public function ExampleSelector() {
			super();
			
			universalButton.y = 0;
			basicButton.y = 50;
			advancedButton.y = 100;
			captureButton.y = 150;
			
			addChild(universalButton);
			addChild(basicButton);
			addChild(advancedButton);
			//if(Capabilities.os.toLowerCase().lastIndexOf("windows") > -1)
				addChild(captureButton);
			
		}
	}
}