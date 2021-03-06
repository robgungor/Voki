﻿package com.voki.data {
	import com.oddcast.assets.structures.LoadedAssetStruct;
	import flash.geom.Matrix;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPCharStruct extends LoadedAssetStruct {
		public var model:SPHostStruct;
		public var hostPos:Matrix;
		public var expression:String;
		public var visible:Boolean;
		
		public function SPCharStruct($id:int = 0) {
			super(null, $id);
		}
	}
	
}