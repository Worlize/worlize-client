package com.worlize.view.components
{
	import com.worlize.view.skins.DynamicHeightListSkin;
	
	import spark.components.List;
	
	public class DynamicHeightList extends List
	{
		[Bindable]
		public var maxRowCount:int = 5;
		
		public function DynamicHeightList()
		{
			super();
		}
	}
}