﻿package com.voki.data {
	import com.oddcast.assets.structures.EngineStruct;
	import com.oddcast.audio.AudioData;
	import com.oddcast.audio.TTSAudioData;
	import com.oddcast.audio.TTSVoice;
	import com.oddcast.utils.Cloner;
	import com.oddcast.utils.MoveZoomUtil;
	import flash.geom.Matrix;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class ShowStruct {
		public var sceneArr:Array;
		public var mouseFollow:Boolean = false;
		public var trackingUrl:String;
		public var isEdited:Boolean = false;
		public var contentUrl:String;
		
		public function get scene():SceneStruct {
			if (sceneArr == null || sceneArr.length == 0) return(null);
			else return(sceneArr[0]);
		}
		
		public function set scene(s:SceneStruct):void
		{
			if (sceneArr == null)
			{
				sceneArr = new Array();
			}
			sceneArr[0] = s;
		}
		
		private function addBaseUrl(baseUrl:String,url:String):String {
			if (url.indexOf("://") == -1) return(baseUrl + url);
			else return(url);
		}
		
		public function parseXML(_xml:XML):void {
			var audioAssets:Array=new Array();
			var skinAssets:Array=new Array();
			var modelAssets:Array=new Array();
			var bgAssets:Array = new Array();
			var videoAssets:Array = new Array();
			var engineAssets:Array = new Array();
			
			var xasset:XML;
			var assetId:int;
			var assetUrl:String;
			var assetList:XMLList;
			var i:int;
			var j:int;
			var engine:EngineStruct;
			
			var showName:String = _xml.params.showname.toString();
			var ohBaseUrl:String = _xml.params.oh_base_url.toString();
			var contentBaseUrl:String = _xml.params.content_base_url.toString();
			contentUrl = contentBaseUrl;
			trackingUrl = _xml.params.track_url.toString();
			isEdited = (_xml.params.edited.toString() == "1");
			
			assetList=_xml.assets.elements("engine");
			for (i=0;i<assetList.length();i++) {
				xasset = assetList[i];
				assetId = parseInt(xasset.@id.toString());
				assetUrl = addBaseUrl(ohBaseUrl,xasset.@url.toString());
				engine = new EngineStruct(assetUrl, assetId);
				engine.ctlUrl = addBaseUrl(ohBaseUrl,xasset.@ctl.toString());
				engine.type = xasset.@type.toString();
				engineAssets[assetId] = engine;
			}
			
			assetList = _xml.assets.elements("avatar");
			var modelObj:SPHostStruct;
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetId = parseInt(xasset.@id.toString());
				var engineId:int=parseInt(xasset.@engine.toString());
				var modelType:String = xasset.@type.toString();
				var modelId:int=parseInt(xasset.@modelId.toString());
				assetUrl = addBaseUrl((modelType.toLowerCase()=="3d" || modelType.toLowerCase()=="host_3d")? contentBaseUrl:ohBaseUrl, xasset.toString());
				
				modelObj=new SPHostStruct(assetUrl,modelId,"","");
				//model.is3d=(modelType == "3D");
				modelObj.engine = engineAssets[engineId];
				if (modelObj.engine == null) throw new Error("ERROR in playScene.php - there is no engine for avatar with id " + assetId);
				modelObj.type = modelType;
				modelObj.level = parseInt(xasset.@level.toString());
				modelObj.isOwned = true;
				modelObj.charId = assetId;
				modelAssets[assetId]=modelObj;
			}
			
			assetList=_xml.assets.elements("audio");
			var audioObj:AudioData;
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				
				var audioType:String = xasset.@type.toString();
				trace("----- parse audio type=" + audioType);
				var isTTS:Boolean = xasset.hasOwnProperty("text");
				if (isTTS) {
					assetId = parseInt(xasset.@id.toString());
					
					var ttsText:String;
					try 
					{
						ttsText = unescape(decodeURI(xasset.text.toString())).replace(/\+/g, " ");
					}
					catch (e:Error)
					{
						ttsText = unescape(unescape(xasset.text.toString()));
					}
					
					var ttsVoice:TTSVoice=new TTSVoice();
					ttsVoice.setFromWorkshopCode(xasset.voice.toString());
					audioObj=new TTSAudioData(ttsText,ttsVoice);
					//ttsAudioAssets[assetId]=audioObj;
					audioAssets[assetId]=audioObj;
				}
				else {
					assetId=parseInt(xasset.@id.toString());
					assetUrl = addBaseUrl(contentBaseUrl,xasset.toString());
					//if extension is missing, add "mp3"
					if (assetUrl.lastIndexOf(".")<=assetUrl.lastIndexOf("/")) assetUrl+=".mp3";
					audioObj = new AudioData(assetUrl, assetId, audioType, "");
					if (xasset.@catid != null)
					{
						audioObj.catId = int(xasset.@catid);
					}
					audioAssets[assetId]=audioObj;
				}				
			}
			
			assetList = _xml.assets.elements("bg");
			var bgObj:SPBackgroundStruct;
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetId = parseInt(xasset.@id.toString());
				assetUrl = addBaseUrl(contentBaseUrl, xasset.toString());
				bgObj = new SPBackgroundStruct(assetUrl, assetId);
				bgObj.catId = parseInt(xasset.@catid.toString());
				bgObj.level = parseInt(xasset.@level.toString());
				bgObj.type = xasset.@type;
				bgAssets[assetId] = bgObj;
			}
			
			assetList = _xml.assets.elements("skin");
			var skinObj:SPSkinStruct;
			for (i = 0; i < assetList.length(); i++) {
				xasset = assetList[i];
				assetId = parseInt(xasset.@id.toString());
				assetUrl = addBaseUrl(contentBaseUrl, xasset.toString());
				skinObj = new SPSkinStruct(assetUrl, assetId);
				skinObj.level = parseInt(xasset.@level.toString());
				skinObj.width = parseInt(xasset.@width.toString());
				skinObj.height = parseInt(xasset.@height.toString());
				skinObj.type = xasset.@type.toString();
				skinAssets[assetId] = skinObj;
			}
			
			/* no videos for now ...
			assetList = _xml.assets.elements("video");
			var vid:WSVideoStruct;
			for (i=0;i<assetList.length();i++) {
				xasset=assetList[i];
				assetUrl = addBaseUrl(contentBaseUrl, xasset.toString());
				var vidId:int = parseInt(xasset.@vidId.toString());
				vid = new WSVideoStruct(assetUrl, vidId);
				vid.duration = parseFloat(xasset.@length.toString()) / 1000;
				vid.spliceTime = parseFloat(xasset.@endEditDuration.toString()) / 1000;
				videoAssets[xasset.@id.toString()] = vid;
			}
			*/
			
			// put the scene together with the assets...
			
			var xscene:XML;

			var sceneObj:SceneStruct;
			sceneArr = new Array();
			var char:SPCharStruct;
			var hostPos:Matrix;
			
			for (i = 0; i < _xml.scenes.scene.length();i++) {
				xscene = _xml.scenes.scene[i];
				sceneObj = new SceneStruct();				
				sceneObj.id = parseInt(xscene.id.toString());
				sceneObj.order = parseInt(xscene.order.toString());
				sceneObj.title = xscene.title.toString();
				
				if (xscene.elements("avatar").length() > 0) {
					xasset=xscene.elements("avatar")[0];
					assetId=parseInt(xasset.id.toString())
					char = new SPCharStruct(assetId);
					char.model = modelAssets[assetId];
					sceneObj.char = char;
					
					var hostScale:Number = parseFloat(xasset.scale.toString()) / 100;
					var hostX:Number = parseFloat(xasset.x.toString());
					var hostY:Number = parseFloat(xasset.y.toString());
					var isVisible:Boolean = String(xasset.visible).toLowerCase() == "true";
					hostPos = new Matrix();
					hostPos.scale(hostScale, hostScale);
					hostPos.translate(hostX, hostY);
					sceneObj.char.hostPos = hostPos;
					sceneObj.char.expression = xasset.expression.toString();
					sceneObj.char.visible = isVisible;
					sceneObj.expression = xasset.expression.toString();
				}
				
				assetList = xscene.audio.elements("id");
				sceneObj.audioArr = new Array();
				for (j = 0; j < assetList.length(); j++) {
					xasset = assetList[j];
					assetId=parseInt(xasset.toString())
					sceneObj.audioArr.push(audioAssets[assetId]);
				}
				
				if (xscene.elements("bg").length()>0) {
					xasset=xscene.elements("bg")[0];
					assetId=parseInt(xasset.id.toString())
					sceneObj.bg=bgAssets[assetId];
				}
				
				if (xscene.elements("skin").length() > 0) {
					xasset=xscene.elements("skin")[0];
					assetId = parseInt(xasset.id.toString())
					var baseSkinObj:SPSkinStruct = skinAssets[assetId];
					var tmpSkinObj:SPSkinStruct = new SPSkinStruct(baseSkinObj.url, baseSkinObj.id);								
					tmpSkinObj.level = baseSkinObj.level;
					tmpSkinObj.width = baseSkinObj.width;
					tmpSkinObj.height = baseSkinObj.height; 
					tmpSkinObj.type = baseSkinObj.type;
					sceneObj.skin = tmpSkinObj;
					if (xasset.hasOwnProperty("SKINCONF")) {
						sceneObj.skinConfig = new SkinConfiguration(sceneObj.skin.type);
						sceneObj.skinConfig.setFromXML(xasset.SKINCONF[0], contentBaseUrl);
						sceneObj.skin.defaultColorArr = sceneObj.skinConfig.colorArr.slice();
					}
				}
				else
				{					
					sceneObj.skinConfig.title = sceneObj.title != null? sceneObj.title : showName;
					sceneObj.title = showName;
				}
				/*no video à présent
				if (xscene.elements("video").length()>0) {
					var xvideo:XML=xscene.elements("video")[0];
					scene.video=videoAssets[xvideo.id.toString()];
				}
				*/
				
				//scene.isNewScene=(_xml.VHSS.@EDITED=="0");
				sceneArr.push(sceneObj);
			}
			if (SessionVars.editorMode == "SceneEditor")
			{
				sceneArr.sortOn("order", Array.NUMERIC);
			}
			else
			{
				sceneArr.sortOn("id", Array.NUMERIC);
			}
		}
		
		public function getSaveXML():XML {
			var showXML:XML = new XML("<player />");
			
			var scene:SceneStruct;
			var modelArr:Array = new Array();
			var bgArr:Array = new Array();
			var audioArr:Array = new Array();
			var videoArr:Array = new Array();
			var skinArr:Array = new Array();
			var i:int;
			var j:int;
			
			var sceneXML:XML;
			showXML.scenes = new XML();
			for (i = 0; i < sceneArr.length; i++) {
				scene = sceneArr[i];
				
				//for (j = 0; j < scene.modelArr.length; j++) pushUnique(modelArr, scene.modelArr[j]);
				//for (j = 0; j < scene.bgArr.length;j++) pushUnique(bgArr, scene.bgArr[j]);
				//for (j = 0; j < scene.videoArr.length;j++) pushUnique(videoArr, scene.videoArr[j]);
				pushUnique(modelArr, scene.char);
				pushUnique(bgArr, scene.bg);
				pushUnique(skinArr, scene.skin);
				for (j = 0; j < scene.audioArr.length;j++) pushUnique(audioArr, scene.audioArr[j]);
				
				sceneXML = getSceneXML(scene);
				sceneXML.id = scene.id.toString();
				showXML.scenes.appendChild(sceneXML);
			}
			
			showXML.assets = new XML();
			for (i = 0; i < modelArr.length; i++) showXML.assets.appendChild(getModelXML(modelArr[i]));
			for (i = 0; i < bgArr.length; i++) showXML.assets.appendChild(getBGXML(bgArr[i]));
			for (i = 0; i < audioArr.length; i++) showXML.assets.appendChild(getAudioXML(audioArr[i]));
			//for (i = 0; i < videoArr.length; i++) showXML.assets.appendChild(getVideoXML(videoArr[i]));
			for (i = 0; i < skinArr.length; i++) showXML.assets.appendChild(getSkinXML(skinArr[i]));
			
			return(showXML);
		}
		
		private function pushUnique(arr:Array, obj:Object):void { //don't allow null or duplicate items in array
			if (obj != null && arr.indexOf(obj) < 0) arr.push(obj);
		}
		
		
		private function getSceneXML(scene:SceneStruct):XML {
			var node:XML=new XML("<scene />")
			var i:int;
			
			var char:SPCharStruct;
			if (scene.model != null) {
				char = scene.char;
				var modelNode:XML = new XML("<avatar />");

				modelNode.id = char.id.toString();
				if (char.hostPos!=null) {
					var hostPos:Object = MoveZoomUtil.matrixToObject(char.hostPos);
					modelNode.x=hostPos.x.toFixed(2);
					modelNode.y=hostPos.y.toFixed(2);
					modelNode.scale = (hostPos.scaleX * 100).toFixed(2);
				}
				node.appendChild(modelNode);
			}
			
			var audio:AudioData;
			if (scene.audioArr != null)	
			{
				if (scene.audioArr.length > 1)
				{
					var audioXML:XML = new XML("<audio/>");
					for (i = 0; i < scene.audioArr.length; i++) 
					{		
						if (scene.audioArr[i]==undefined)
							continue;
						audioXML.appendChild(new XML("<id>"+scene.audioArr[i].id+"</id>"));					
					}
					node.appendChild(audioXML);					
				}
				else
				{
					for (i = 0; i < scene.audioArr.length; i++) {
					//workaround for probelm with a undefined value for the first node
					if (scene.audioArr[i]==undefined)
						continue;
						audio = scene.audioArr[i];
						var audioNode:XML=new XML("<audio />");
						audioNode.id=audio.id.toString();
						node.appendChild(audioNode);
					}
				}				
			}
			
			var bg:SPBackgroundStruct;
			if (scene.bg!=null) {
				bg = scene.bg;
				node.bg=new XML();
				node.bg.id=bg.id.toString();
			}
			
			if (scene.skin != null) {
				node.skin = new XML();
				node.skin.id = scene.skin.id.toString();
				if (scene.skinConfig!=null) node.skin.appendChild(scene.skinConfig.getXML());
			}
			
/*			no video yet
 			var video:WSVideoStruct;
			if (scene.video != null) {
				video = scene.video;
				node.video=new XML();
				node.video.id=video.id.toString();
			}*/
			
			return(node);
		}

		private function getModelXML(char:SPCharStruct):XML {
			var node:XML = new XML("<avatar />");
			node.@modelId=char.model.id; //modelId
			node.@id = char.id;
			node.@type = char.model.is3d?"3D":"2D";
			//node.@is3d = char.model.is3d?"1":"0"; - deprecated
			node.appendChild(char.url);
			return(node);
		}
		
		private function getBGXML(bg:SPBackgroundStruct):XML {
			var node:XML=new XML("<bg />");	
			node.@id=bg.id;
			if (bg.name!=null) node.@name = escape(bg.name);
			node.appendChild(bg.url);
			return(node);			
		}
/*		
		private function getVideoXML(vid:WSVideoStruct):XML {
			var node:XML=new XML("<video />");	
			if (vid.hasId) node.@id=vid.id;
			else node.@tempid = vid.tempId;
			if (vid.name != null) node.@name = escape(vid.name);
			trace("WorkshopSaver::getVideoXML - vid.isVideoStar : " + vid.isVideostar);
			if (vid.isVideostar) {
				node.@vidId = vid.videostarSource.id.toString();
				node.@length = vid.videostarSource.duration.toString();
			}
			node.appendChild(vid.url);
			return(node);			
		}*/
		
		private function getAudioXML(audio:AudioData):XML {
			var node:XML = new XML("<audio />");
			
			//if (audio.type == null || audio.type.length == 0) throw(new Error("Audio must have a valid type in order to save it."));
			if (audio.type == null || audio.type.length == 0) node.@type=AudioData.PRERECORDED;
			else if (audio.type == AudioData.UPLOADED||audio.type==AudioData.USER_GENERIC) node.@type = AudioData.PHONE;
			else node.@type=audio.type;
			
			node.@id=audio.id;
			if (audio.name != null) node.@name = escape(audio.name);
			
			if (audio is TTSAudioData) {				
				var ttsAudio:TTSAudioData = audio as TTSAudioData;
				if (ttsAudio.voice != null)
				{
					trace("audioName="+audio.name);
					node.voice=ttsAudio.voice.getWorkshopCode();
					node.text=encodeURI(ttsAudio.textWithProsody.replace(/\\/g, "\\\\"));	
					if (ttsAudio.fx!=null) {
						node.fx_type=ttsAudio.fx.type;
						node.fx_level=ttsAudio.fx.level;
					}
				}
				else
				{
					node.appendChild(audio.url);
				}
			}
			else {
				node.appendChild(audio.url);
			}
			return(node);
		}
		
		private function getSkinXML(skin:SPSkinStruct):XML {
			var node:XML =<skin />
			node.@id = skin.id;
			node.@width = skin.width.toString();
			node.@height = skin.height.toString();
			node.@level = skin.level.toString();
			node.@type = skin.type.toString();
			node.appendChild(skin.url);
			return(node);
		}
		
	}
	
}





/*
V4:

<HOST EMAIL="0" V="4" CONFIG="eyesR%253D14%2526eyesG%253D%252D64%2526eyesB%253D%252D64%2526hairR%253D0%2526hairG%253D0%2526hairB%253D0%2526mouthR%253D6%2526mouthG%253D%252D48%2526mouthB%253D%252D50%2526skinR%253D28%2526skinG%253D%252D18%2526skinB%253D%252D44%2526make%252DupR%253D0%2526make%252DupG%253D0%2526make%252DupB%253D0%2526hyscale%253D101%2526hxscale%253D101%2526mscale%253D101%2526nscale%253D92%2526bscale%253D101%2526age%253D1%2526blush%253D50%2526make%252Dup%253D10%2526ac%255Fcostume%253D404%2526ac%255Fmouth%253D980%2526ac%255Fhair%253D3431%2526ac%255Ffhair%253D0%2526ac%255Fhat%253D860%2526ac%255Fnecklace%253D313%2526ac%255Fglasses%253D302%2526ac%255Fbottom%253D0%2526ac%255Fshoes%253D0%2526ac%255Fprops%253D0%2526ok%253D1" GENCONF="template%253Dundefined" HOST="40157" PUPPET="135" AUDIO="-1" BGID="43291" MOUSE="0" SCALE="42" Y="89" X="115" USERID="2445" SHOWID="21361" ACCID="3836"><SKIN SLIDE="29631" ID="144" TYPE="STANDARD" DEFAULT="0"><SKINCONF C4="0x0" C3="0x0" C2="0x0" C1="0x0" NEXT="0" PREV="0" MUTE="1" PLAY="1" VOL="1" VTITLE="1" TITLE="mr%2E%20jim" ALIGN="center" /></SKIN></HOST>



V5:

<player>
 <params>
   <email>0</email>
   <version>5</version>
   <mouse>0</mouse>
   <userid>2445</userid>
   <showid>21361</showid>
   <showname>mr%2E%20jim</showname>
   <account>3836</account>
 </params>
 <assets>
   <avatar modelId="135" id="40157" type="2D">oh/108/403/1525/1366/0/0/314/0/0/0/0/ohv2.swf?cs=ce76b23:5008ac4:862627:51e326:0:100:100:100:100:100.01373291015598:1:0:0:0</avatar>
   <bg id="43291">http://host.staging.oddcast.com/ccs1/customhost/302/bg/BUG_2006_report_old.jpg</bg>
   <skin id="144" type="STANDARD">http://skin.url/goes/here.swf</skin>
 </assets>
 <scenes>
   <scene>
     <id>26931</id>
     <avatar>
       <id>40157</id>
       <x>89.00</x>
       <y>115.00</y>
       <scale>42.00</scale>
     </avatar>
     <bg>
       <id>43291</id>
     </bg>
     <skin id="144">
         <SKINCONF C4="0x0" C3="0x0" C2="0x0" C1="0x0" NEXT="0" PREV="0" MUTE="1" PLAY="1" VOL="1" VTITLE="1" TITLE="mr%2E%20jim" ALIGN="center" />
     </skin>
   </scene>
 </scenes>
</player>

 * */















/*
		public function parseXML(_xml:XML) {
			scene = new SceneStruct();
			
			var baseUrl:String = _xml.VHSS.@URL.toString();
			scene.id = parseInt(_xml.VHSS.BODY.SLIDE.ID);
			
			var hostId:int = parseInt(_xml.VHSS.HEAD.PUPPET.@ID.toString());
			var hostUrl:String=_xml.VHSS.@OH.toString()+_xml.VHSS.HEAD.PUPPET.@URL.toString();
			var modelId:int=parseInt(_xml.VHSS.BODY.SLIDE.HOST.@PUPID.toString());
			
			if (modelId>0) {
				scene.model = new SPHostStruct(hostUrl, modelId);
				scene.model.id=hostId;
				if (!(SessionVars.mode=="partner")) scene.model.level=0; //model is always owned
				else scene.model.level = parseInt(_xml.VHSS.HEAD.PUPPET.@LEVEL.toString());
				
				/*var modelCatId:int=parseInt(_xml.VHSS.BODY.SLIDE.HOST.@CATID.toString());
				if (modelCatId==0) {
					model.isPrivate=true;
					model.catId=SPHostStruct.PRIVATE_CATEGORY;
				}
				else if (modelCatId>0) model.catId=modelCatId;*/
/*				
				
				//they want to bring up the popular category initially
				//instead of the actual model category
				scene.model.catId=-1; 
				
			}
			else scene.model=null;
			
			
			//modelId=hostModule.getActiveHostId();
			var pos:Object = new Object();
			pos.x=parseFloat(_xml.VHSS.BODY.SLIDE.HOST.@XPOS);
			pos.y=parseFloat(_xml.VHSS.BODY.SLIDE.HOST.@YPOS);
			var scale:Number=parseFloat(_xml.VHSS.BODY.SLIDE.HOST.SCALE)/100;
			//mouseFollow=_xml.VHSS.BODY.SLIDE.HOST.MOUSE;
			if (isNaN(scale)||scale<0) scale=1;
			if (scale<0.1) scale=0.1;
			if (scale>2.5) scale=2.5;
			pos.scaleX = pos.scaleY = scale;
			pos.rotation = 0;
			scene.hostPos = MoveZoomUtil.objectToMatrix(pos);
			
			var audioId:int=parseInt(_xml.VHSS.BODY.SLIDE.HOST.@AID);
			var audioIds:Array;
			if (audioId > 0) {
				var audioUrl:String = baseUrl + _xml.VHSS.BODY.SLIDE.HOST.@SAY;
				scene.audio = new AudioData(audioUrl, audioId);
				scene.audio.catId = parseInt(_xml.VHSS.BODY.SLIDE.HOST.@AUCATID);
				if (_xml.VHSS.BODY.SLIDE.hasOwnProperty("AUDIOLIST")) {
					scene.audioIds=new Array();
					var audioIdList:XMLList=_xml.VHSS.BODY.SLIDE.AUDIOLIST.A;
					for (var i=0;i<audioIdList.length();i++) scene.audioIds.push(parseInt(audioIdList[i].@ID))
				}

				else audioIds=[audioId]
			}
			else {
				scene.audio=null;
				audioIds=[];
			}
			
			var bgUrl:String=baseUrl+_xml.VHSS.BODY.SLIDE.BG.@IMG;
			var bgId:int=parseInt(_xml.VHSS.BODY.SLIDE.BG.@BGID);
			//trace(bgUrl+","+bgId)
			if (bgUrl!=null&&bgUrl.length>0) {
				scene.bg = new SPBackgroundStruct(bgUrl, bgId);
			}
			else scene.bg=null;
			
			
			var skinId:int = parseInt(_xml.VHSS.HEAD.SKIN.@ID);
			//skin.config=new SkinConfiguration();
			
			if (skinId<=0) {
				//scene.skin=SPSkinStruct.NO_SKIN;
				//scene.skin.config.type="none";
				//scene.skin.config.title=unescape(_xml.VHSS.@NAME);				
				scene.skin = null;
			}
			else {
				var skinUrl:String=baseUrl+_xml.VHSS.HEAD.SKIN.@URL;
				scene.skin = new SPSkinStruct(skinUrl, skinId);
				scene.skin.width = parseInt(_xml.VHSS.BODY.SLIDE.SKINCONF.@WIDTH);
				scene.skin.height = parseInt(_xml.VHSS.BODY.SLIDE.SKINCONF.@HEIGHT);
				scene.skin.type = scene.skin.config.type;
				//skin.typeId=SkinData.getTypeIdFromAlias(skinType);
				scene.skin.typeId = 0;
				
				scene.skin.level = parseInt(_xml.VHSS.HEAD.SKIN.@LEVEL);
				scene.skin.config.setFromXML(_xml.VHSS.BODY.SLIDE.SKINCONF,baseUrl);
				trace("in Scene skinType=" + scene.skin.type)
			}
			
			
			//SessionVars.isNewScene=(_xml.VHSS.EDITED=="0");
			scene.isNewScene=(_xml.VHSS.@EDITED=="0");
			
		}*/
		
