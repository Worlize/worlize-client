package com.worlize.api.model
{
	import com.worlize.worlize_internal;

	/**
	 * Represents a prop image definition.
	 * 
	 * <p>Multiple instances of a single prop can be placed around
	 * the room.  Each instance is individually represented as a
	 * <code>LooseProp</code> which references the actual <code>Prop</code>
	 * definition.</p>
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.2
	 */	
	public class Prop
	{
		use namespace worlize_internal;
		
		/**
		 * @private 
		 */		
		protected var _name:String;
		
		/**
		 * @private 
		 */		
		protected var _guid:String;
		
		/**
		 * @private 
		 */		
		protected var _thumbnailURL:String;
		
		/**
		 * @private 
		 */		
		protected var _creatorGuid:String;
		
		/**
		 * Constructor.
		 * 
		 * <p><code>Prop</code> instances are created and managed internally
		 * by the Worlize API and are not meant to be instantiated manually.</p> 
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public function Prop() {
			
		}
		
		/**
		 * A name given to the prop by its creator.
		 *  
		 * @return name 
		 * @productversion Worlize APIv.2
		 */		
		public function get name():String {
			return _name;
		}
		
		/**
		 * The prop's Global Unique Identifier
		 *  
		 * @return the prop's GUID
		 * @productversion Worlize APIv.2
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * A URL to a thumbnail of this prop for display purposes.
		 * 
		 * @return thumbnail URL 
		 * @productversion Worlize APIv.2
		 */		
		public function get thumbnailURL():String {
			return _thumbnailURL;
		}
		
		/**
		 * The User GUID of the person who created the prop.
		 *  
		 * @return user GUID. 
		 * @see com.worlize.api.model.User#guid
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function creatorGuid():String {
			return _creatorGuid;
		}

		/**
		 * @private
		 */		
		public function toJSON():Object {
			return {
				name: _name,
				guid: _guid,
				thumbnailURL: _thumbnailURL,
				creatorGuid: _creatorGuid
			};
		}
		
		/**
		 * @private
		 */		
		public function toString():String {
			return "[Prop name=" + _name + " guid=" + _guid + "]";
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):Prop {
			var prop:Prop = new Prop();
			prop._guid = data.guid;
			prop._creatorGuid = data.creatorGuid;
			prop._name = data.name;
			prop._thumbnailURL = data.thumbnailURL;
			return prop;
		}
	}
}