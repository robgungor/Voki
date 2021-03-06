﻿package com.voki.events {
	import flash.events.Event;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class AssetIdEvent extends Event {
		public var id:int;
		
		public static var MODEL_PURCHASED:String="modelPurchased";
		
		public function AssetIdEvent(type:String,$id:int) {
			super(type);
			id = $id;
		}
					
		public override function clone():Event {
			return new AssetIdEvent(type, id);
		}
		
	}
	
}