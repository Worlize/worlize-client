package com.worlize.interactivity.model
{
	import com.worlize.model.Prop;

	[Bindable]
	public class LooseProp
	{
		public var prop:Prop;
		public var id:uint = 0;
		public var x:int = 0;
		public var y:int = 0;
		public var refCount:int = 0;
	}
}