package com.worlize.interactivity.model
{
	import com.adobe.utils.ArrayUtil;
	import com.worlize.interactivity.view.JellyImages;
	import com.worlize.model.SimpleAvatar;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;

	[Bindable]
	public class InteractivityUser extends EventDispatcher
	{
		public var isSelf:Boolean = false;
		public var isVirtual:Boolean = false;
		public var id:String;
		public var name:String = "Uninitialized User";
		public var x:int;
		public var y:int;
		private var _face:int = 1;
		public var faceImage:Class = JellyImages.map[0];
		public var color:int = 2;
		public var simpleAvatar:SimpleAvatar;
		public var videoAvatarStreamName:String;
		public var showFace:Boolean = true;
		public var facebookId:String;
		public var blocked:Boolean = false;
		private var _worldPermissions:Array = [];
		private var _worldPermissionMap:Object = {};
		private var _globalPermissions:Array = [];
		private var _globalPermissionMap:Object = {};
		private var _appliedPermissions:Array = [];
		private var _appliedPermissionMap:Object = {};
		private var _worldRestrictions:Object = {};
		private var _globalRestrictions:Object = {};
		
		public function clone():InteractivityUser {
			var u:InteractivityUser = new InteractivityUser();
			u.isSelf = isSelf;
			u.id = id;
			u.name = name;
			u.x = x;
			u.y = y;
			u._face = _face;
			u.faceImage = faceImage;
			u.color = color;
			u.simpleAvatar = simpleAvatar;
			u.videoAvatarStreamName = videoAvatarStreamName;
			u.showFace = showFace;
			u.facebookId = facebookId;
			u.blocked = blocked;
			return u;
		}
		
		[Bindable(event="permissionsChanged")]
		public function set worldPermissions(newValue:Array):void {
			if (newValue === null) { newValue = []; }
			if (_worldPermissions !== newValue) {
				var sortedNew:Array = newValue.sort();
				if (!ArrayUtil.arraysAreEqual(_worldPermissions, sortedNew)) {
					_worldPermissions = sortedNew;
					_worldPermissionMap = buildPermissionMap(_worldPermissions);
					dispatchEvent(new FlexEvent('worldPermissionsChanged'));
				}
			}
		}
		public function get worldPermissions():Array {
			return _worldPermissions;
		}
		
		public function toggleWorldPermission(permissionName:String):void {
			if (_worldPermissions.indexOf(permissionName) !== -1) {
				removeWorldPermission(permissionName);
			}
			else {
				addWorldPermission(permissionName);
			}
		}
		
		public function addWorldPermission(permissionName:String):void {
			var index:int = _worldPermissions.indexOf(permissionName);
			if (index === -1) {
				_worldPermissions.push(permissionName);
				_worldPermissions = _worldPermissions.sort();
				_worldPermissionMap = buildPermissionMap(_worldPermissions);
				dispatchEvent(new FlexEvent('worldPermissionsChanged'));
			}
		}
		
		public function removeWorldPermission(permissionName:String):void {
			var index:int = _worldPermissions.indexOf(permissionName);
			if (index !== -1) {
				_worldPermissions.splice(index, 1);
				_worldPermissionMap = buildPermissionMap(_worldPermissions);
				dispatchEvent(new FlexEvent('worldPermissionsChanged'));
			}
		}
		
		[Bindable(event="globalPermissionsChanged")]
		public function set globalPermissions(newValue:Array):void {
			if (newValue === null) { newValue = []; }
			if (_globalPermissions !== newValue) {
				var sortedNew:Array = newValue.sort();
				if (!ArrayUtil.arraysAreEqual(_globalPermissions, sortedNew)) {
					_globalPermissions = sortedNew;
					_globalPermissionMap = buildPermissionMap(_globalPermissions);
					dispatchEvent(new FlexEvent('globalPermissionsChanged'));
				}
			}
		}
		public function get globalPermissions():Array {
			return _globalPermissions;
		}
		
		[Bindable(event="appliedPermissionsChanged")]
		public function set appliedPermissions(newValue:Array):void {
			if (newValue === null) { newValue = []; }
			if (_appliedPermissions !== newValue) {
				var sortedNew:Array = newValue.sort();
				if (!ArrayUtil.arraysAreEqual(_appliedPermissions, sortedNew)) {
					_appliedPermissions = sortedNew;
					_appliedPermissionMap = buildPermissionMap(_appliedPermissions);
					dispatchEvent(new FlexEvent('appliedPermissionsChanged'));
				}
			}
		}
		public function get appliedPermissions():Array {
			return _appliedPermissions;
		}
		
		private function buildPermissionMap(permissions:Array):Object {
			var map:Object = {};
			for each (var permission:String in permissions) {
				map[permission] = true;
			}
			return map;
		}
		
		public function updateRestrictionsFromObject(data:Object):void {
			function buildRestrictionMap(data:Object):Object {
				var obj:Object = {};
				for each (var restrictionData:Object in data) {
					var restriction:UserRestriction = UserRestriction.fromData(restrictionData);
					obj[restriction.name] = restriction;
				}
				return obj;
			}
			
			_worldRestrictions = buildRestrictionMap(data.world);
			_globalRestrictions = buildRestrictionMap(data.global);
			
			dispatchEvent(new FlexEvent('restrictionsChanged'));
		}
		
		[Bindable(event="restrictionsChanged")]
		public function hasActiveRestriction(name:String):Boolean {
			if (_worldRestrictions[name] || _globalRestrictions[name]) {
				return true;
			}
			return false;
		}
		
		[Bindable(event="restrictionsChanged")]
		public function hasWorldRestriction(name:String):Boolean {
			return Boolean(_worldRestrictions[name]);
		}
		
		[Bindable(event="restrictionsChanged")]
		public function hasGlobalRestriction(name:String):Boolean {
			return Boolean(_globalRestrictions[name]);
		}
		
		[Bindable(event="restrictionsChanged")]
		public function getWorldRestriction(name:String):UserRestriction {
			return _worldRestrictions[name] as UserRestriction;
		}
		
		[Bindable(event="restrictionsChanged")]
		public function getGlobalRestriction(name:String):UserRestriction {
			return _globalRestrictions[name] as UserRestriction;
		}
		
		[Bindable(event="appliedPermissionsChanged")]
		public function hasPermission(name:String):Boolean {
			return _appliedPermissionMap[name] ? true : false;
		}
		
		[Bindable(event="worldPermissionsChanged")]
		public function hasWorldPermission(name:String):Boolean {
			return _worldPermissionMap[name] ? true : false;
		}
		
		[Bindable(event="globalPermissionsChanged")]
		public function hasGlobalPermission(name:String):Boolean {
			return _globalPermissionMap[name] ? true : false;
		}
		
		[Bindable(event="faceChanged")]
		public function set face(newValue:int):void {
			if (newValue > 12) {
				newValue = 0;
			}
			newValue = Math.max(0, newValue);
			if (_face != newValue) {
				_face = newValue;
				faceImage = JellyImages.map[_face];
				dispatchEvent(new Event("faceChanged"));
			}
		}

		public function get face():int {
			return _face;
		}
		
		public function naked():void {
			
		}
	}
}