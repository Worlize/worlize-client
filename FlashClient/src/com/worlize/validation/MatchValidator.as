package com.worlize.validation
{
	import flash.events.Event;
	
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	public class MatchValidator extends Validator
	{
		private var _matchSource: Object = null;
		private var _matchProperty: String = null;
		private var _noMatchError: String = "Fields did not match";
		
		[Inspectable(category="General", defaultValue="Fields did not match")]
		public function set noMatchError( argError:String):void{
			_noMatchError = argError;
		}
		public function get noMatchError():String{
			return _noMatchError;
		}
		
		[Inspectable(category="General", defaultValue="null")]
		public function set matchSource( argObject:Object):void{
//			removeTriggerHandler();
			_matchSource = argObject;
//			addTriggerHandler();
		}
		public function get matchSource():Object{
			return _matchSource;
		}
		
		[Inspectable(category="General", defaultValue="null")]
		public function set matchProperty( argProperty:String):void{
			_matchProperty = argProperty;
		}
		public function get matchProperty():String{
			return _matchProperty;
		}
		
		override protected function doValidation(value:Object):Array {
			
			// Call base class doValidation().
			var results:Array = super.doValidation(value.ours);
			
			var val:String = value.ours ? String(value.ours) : "";
			if (results.length > 0 || ((val.length == 0) && !required)){
				return results;
			}else{
				if(val != value.toMatch){
					results.length = 0;
					results.push( new ValidationResult(true,null,"mismatch",_noMatchError));
					return results;
				}else{
					return results;
				}
			}
		}  
		
		override protected function getValueFromSource():Object {
			var value:Object = {};
			
			value.ours = super.getValueFromSource();
			
			if (_matchSource && _matchProperty){
				value.toMatch = _matchSource[_matchProperty];
			}else{
				value.toMatch = null;
			}
			return value;
		}
		
//		override public function set triggerEvent(value:String):void
//		{
//			removeTriggerHandler();
//			super.triggerEvent = value;
//			addTriggerHandler();
//		}
//		
//		private function addTriggerHandler():void
//		{
//			if (_matchSource)
//				_matchSource.addEventListener(triggerEvent,triggerHandler);
//		}
//		
//		private function removeTriggerHandler():void
//		{
//			if (_matchSource)
//				_matchSource.removeEventListener(triggerEvent,triggerHandler);
//		}
//		
//		private function triggerHandler(event:Event):void
//		{
//			validate();
//		}
	}
}

