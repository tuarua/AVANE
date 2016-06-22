package utils {
	import flash.globalization.DateTimeFormatter;

	public  class TimeUtils {
		public static function secsToTimeCode(n:Number):String {
			var finStr:String = "";
			var h:int = Math.floor((n/3600));
			var m:int = Math.floor((n-(h*3600))/60);
			var s:int = Math.floor(n-((h*3600)+(m*60)));
			var hStr:String = h.toString();
			var mStr:String = m.toString();
			var sStr:String = s.toString();
			if(h < 10) hStr = hStr;
			if(m < 10) mStr = "0"+mStr;
			if(s < 10) sStr = "0"+sStr;
			if(h > 0) finStr = finStr+hStr+":";
			finStr = finStr+mStr+":"+sStr;
			return finStr;
		}
		public static function secsToFriendly(n:int):String {
			var d:int = Math.floor((n/3600)/24);
			var h:int = Math.floor((n/3600));
			var m:int = Math.floor((n-(h*3600))/60);
			var ret:String;
			if(d > 0)
				ret = d+"d "+h+"h ";
			else if(h > 0)
				ret = h+"h "+m+"m ";
			else if(m > 0)
				ret = m+"m";
			else
				ret = "< 1m";
			return ret;
		}
		public static function timeCodeToSecs(s:String):Number{//00:00:05.53
			var arr:Array = s.split(":");
			var ret:Number = 0;
			if(arr.length == 1){
				ret = parseFloat(arr[0]);
			}else if(arr.length == 2){
				ret = (parseInt(arr[0])*60)+parseFloat(arr[1]);
			}else if(arr.length == 3){
				ret = (parseInt(arr[0])*60*60)+(parseInt(arr[1])*60)+parseFloat(arr[2]);
			}
			return ret;
		}
		public static function unixToDate(_val:uint):String {
			var d:Date = new Date(_val*1000);
			var dtf:DateTimeFormatter = new DateTimeFormatter("en-UK");
			dtf.setDateTimePattern("E d MMM y, HH:mm");
			return dtf.format(d)
		}
	}
}