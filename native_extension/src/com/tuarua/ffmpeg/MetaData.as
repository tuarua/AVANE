package com.tuarua.ffmpeg {
	import flash.utils.Dictionary;

	public class MetaData extends Object{
		private var _album:String;
		private var _albumArtist:String;
		private var _artist:String;
		private var _author:String;
		private var _comment:String;
		private var _composer:String;
		private var _copyright:String;
		private var _date:String;
		private var _description:String;
		private var _encodedBy:String;
		private var _episodeId:String;
		private var _genre:String;
		private var _grouping:String;
		private var _language:String; 
		private var _lyrics:String;
		private var _network:String;
		private var _rating:String;
		private var _show:String
		private var _title:String;
		private var _track:String;
		private var _year:String;
		
		private var customKeys:Dictionary = new Dictionary();

		public function addCustom(key:String,value:String):void {
			customKeys[key] = value;
		}
		public function getAsVector():Vector.<String> {
			var vec:Vector.<String> = new Vector.<String>;
			if(_album)
				vec.push("album="+_album);
			if(_albumArtist)
				vec.push("album_artist="+_albumArtist);
			if(_artist)
				vec.push("artist="+_artist);
			if(_author)
				vec.push("author="+_author);
			if(_comment)
				vec.push("comment="+_comment);
			if(_composer)
				vec.push("composer="+_composer);
			if(_copyright)
				vec.push("copyright="+_copyright);
			if(_date)
				vec.push("date="+_date);
			if(_description)
				vec.push("description="+_description);
			if(_encodedBy)
				vec.push("encoded_by="+_encodedBy);
			if(_episodeId)
				vec.push("episode_id="+_episodeId);
			if(_genre)
				vec.push("genre"+_genre);
			if(_grouping)
				vec.push("grouping="+_grouping);
			if(_language)
				vec.push("language="+_language);
			if(_lyrics)
				vec.push("lyrics="+_lyrics);
			if(_network)
				vec.push("network="+_network);
			if(_rating)
				vec.push("rating="+_rating);
			if(_show)
				vec.push("show="+_show);
			if(_title)
				vec.push("title="+_title);
			if(_track)
				vec.push("track="+_track);
			if(_year)
				vec.push("year="+_year);
			
			for (var key:Object in customKeys)
				vec.push(key.toString()+"="+customKeys[key].toString());
			return vec;
		}
		public function set album(value:String):void {
			_album = value;
		}

		public function set albumArtist(value:String):void {
			_albumArtist = value;
		}
		public function set artist(value:String):void {
			_artist = value;
		}
		public function set author(value:String):void {
			_author = value;
		}
		public function set comment(value:String):void {
			_comment = value;
		}
		public function set composer(value:String):void {
			_composer = value;
		}
		public function set copyright(value:String):void {
			_copyright = value;
		}
		public function set date(value:String):void {
			_date = value;
		}
		public function set description(value:String):void {
			_description = value;
		}
		public function set encoded_by(value:String):void {
			_encodedBy = value;
		}

		public function set episode_id(value:String):void {
			_episodeId = value;
		}
		public function set genre(value:String):void {
			_genre = value;
		}
		public function set grouping(value:String):void {
			_grouping = value;
		}
		public function set language(value:String):void {
			_language = value;
		}
		public function set lyrics(value:String):void {
			_lyrics = value;
		}
		public function set network(value:String):void {
			_network = value;
		}
		public function set rating(value:String):void {
			_rating = value;
		}
		public function set show(value:String):void {
			_show = value;
		}
		public function set title(value:String):void {
			_title = value;
		}
		public function set track(value:String):void {
			_track = value;
		}
		public function set year(value:String):void {
			_year = value;
		}
	}
}