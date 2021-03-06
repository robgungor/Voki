﻿package com.voki.data {
	import com.oddcast.utils.XMLLoader;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SPSkinList {
		public static var typeTitles:Object;
		private var _arrTypesId:Array;
		private var availableTypes:Array;		//an array of SPCategory objects representing types
		
		//an assoc array of arrays of SPCategory objects indexed by type  arr[typeName]=[cat1,cat2]
		private var catByTypeArr:Object  
		
		//an assoc 3d array of SPSkinStruct objects indexed by typeId and catId   e.g. arr[typeName][catId]=[skin1,skin2,skin3]
		private var skinsByTypeCatArr:Object;
		
		public function SPSkinList() {
			typeTitles = new Object();
			typeTitles[SPSkinStruct.STANDARD_TYPE] = "Standard";
			typeTitles[SPSkinStruct.LEAD_TYPE] = "Lead";
			typeTitles[SPSkinStruct.FAQ_TYPE] = "FAQ";
			typeTitles[SPSkinStruct.AI_TYPE] = "AI";
			_arrTypesId = new Array();
			_arrTypesId[1] = SPSkinStruct.STANDARD_TYPE;
			_arrTypesId[2] = SPSkinStruct.FAQ_TYPE;
			_arrTypesId[3] = SPSkinStruct.AI_TYPE;
			_arrTypesId[4] = SPSkinStruct.LEAD_TYPE;
			
			
			
			skinsByTypeCatArr = new Object();
		}
		
//--------------------------------------------------------------
		
		public function getTypeArr(callback:Function) {
			if (availableTypes != null) {
				callback(availableTypes.sort());
				return;
			}
			var url:String=SessionVars.baseURL+"getSkinCategories/partnerId="+SessionVars.partnerId+"/doorId="+SessionVars.doorId+"&showType=1&as=3";
			XMLLoader.loadXML(url,gotCategories,callback);
		}
		
		private function gotCategories(_xml:XML, callback:Function) {
			parseCategories(_xml);
			callback(availableTypes.sort());
		}
		
		public function getCategoriesByType(type:String):Array {
			if (catByTypeArr == null) throw(new Error("SPSkinList::getCategoriesByType - you must call getTypeArr first"));
			
			return(catByTypeArr[type])
		}
		
		private function parseCategories(_xml:XML) {
			var i:int;
			var j:int;
			
			var xmlTypeArr:XMLList=_xml.CATEGORY.SKINTYPE;
			var xmlCatArr:XMLList;
			var typeName:String;
			var catId:int;
			var catName:String;
			
			availableTypes = new Array();
			catByTypeArr = new Object();
			
			for (i=0;i<xmlTypeArr.length();i++) {
				typeName = _arrTypesId[xmlTypeArr[i].@TYPE];
				availableTypes.push(typeName);
				
				xmlCatArr = xmlTypeArr[i].SUBCAT;
				catByTypeArr[typeName] = new Array();
				for (j = 0; j < xmlCatArr.length(); j++) {
					catId = parseInt(xmlCatArr[j].@ID.toString());
					catName = unescape(xmlCatArr[j].@NAME.toString());
					catByTypeArr[typeName].push(new SPCategory(catId, catName));
					trace("SPSkinList::catId=" + catId + ", catName=" + catName + ", typeName=" + typeName);
				}
				catByTypeArr[typeName].sortOn("name",Array.CASEINSENSITIVE);
			}
			
			
		}
//--------------------------------------------------------------

		public function getSkinsByType(callback:Function,typeName:String, catId:int = -1) {
			if (availableTypes == null) throw(new Error("SPSkinList::getSkinsByType - you must call getTypeArr first"));
			if (availableTypes.indexOf(typeName) == -1) throw(new Error("SPSkinList::getSkinsByType - invalid type " + typeName));
			
			//if no category specified, use the first category for that type
			if (catId==-1) catId = catByTypeArr[typeName][0].id;
			
			if (skinsByTypeCatArr != null && skinsByTypeCatArr[typeName] != null && skinsByTypeCatArr[typeName][catId] != null) {
				callback(skinsByTypeCatArr[typeName][catId]);
				return;
			}
			
			var url:String=SessionVars.baseURL+"getSkins/partnerId="+SessionVars.partnerId+"/doorId="+SessionVars.doorId+"&catId="+catId+"&type="+typeName+"&as=3";
			XMLLoader.loadXML(url, gotSkins, callback, typeName, catId);
		}
		
		private function gotSkins(_xml:XML, callback:Function,typeName:String,catId:int) {						
			var skinArr:Array = parseSkins(_xml,typeName,catId);
			if (skinsByTypeCatArr[typeName] == null) skinsByTypeCatArr[typeName] = new Array();
			skinsByTypeCatArr[typeName][catId] = skinArr;
			callback(skinArr);
		}

		
		private function parseSkins(_xml:XML,typeName:String,catId:int):Array {
			var skinArr:XMLList=_xml.SKIN;
			var baseUrl:String = _xml.@URL;
			//baseUrl = "http://content.dev.oddcast.com/vhss_dev/content/STAGING/vhss/skins_f9/"; //hack
			
			var i:int;
			var j:int;
			var skinXml:XML;
			var id:int;
			var w:int;
			var h:int;
			var level:int;
			
			var name:String;
			var thumbUrl:String;
			var url:String;
			var skin:SPSkinStruct;
			
			var skinDataArr:Array=new Array();
			
			for (i = 0; i < _xml.SKIN.length(); i++) {
				skinXml = _xml.SKIN[i];
				
				id=parseInt(skinXml.@ID.toString());
				name=unescape(skinXml.@NAME.toString()).replace(/\+/g, " ");;
				thumbUrl=baseUrl+skinXml.@THUMB;
				url = baseUrl + skinXml.@URL;
				
				w=parseInt(skinXml.SKINCONF.@WIDTH.toString());
				h=parseInt(skinXml.SKINCONF.@HEIGHT.toString());
				level = parseInt(skinXml.SKINCONF.@LEVEL.toString());
				
				skin = new SPSkinStruct(url, id, thumbUrl, name, catId, level, typeName, w, h);
				var defaultConfig:SkinConfiguration = new SkinConfiguration();
				defaultConfig.setFromXML(skinXml.SKINCONF[0]);
				skin.defaultColorArr = defaultConfig.colorArr;
				skinDataArr.push(skin);
			}
			return(skinDataArr);
		}
		
	}	
}