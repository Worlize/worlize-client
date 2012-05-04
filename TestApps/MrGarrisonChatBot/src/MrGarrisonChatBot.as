package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChatEvent;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class MrGarrisonChatBot extends Sprite
	{
		public var api:WorlizeAPI;
		
		private var chatTimer:Timer = new Timer(1000, 1);
		
		private var pendingMessage:String;
		
		private var rules:Array = [
			{
				condition: "all",
				responseMode: "random",
				words: ["garrison"],
				responses: [
					"What do you want?",
					"Shut up!",
					"What the hell do you think you're doing?"
				]
			},
			{
				condition: "any",
				responseMode: "linear",
				words: ["lemmywinks","lemmiwinks"],
				responses: [
					"We're going to introduce the endothermic heat of the gerbil to the exothermic heat of Mr. Slave's ass.",
				]
			},
			{
				condition: "nomatch",
				responseMode: "random",
				responses: [
					"This'll get me fired for sure!",
					"This is Mr. Slave, the teacher's assistant.  Or as I like to call him, the \"Teacher's Ass.\"",
					null,
					null
				]
			}
		];
		
		public function MrGarrisonChatBot()
		{
			WorlizeAPI.options.defaultWidth = 50;
			WorlizeAPI.options.defaultHeight = 50;
			WorlizeAPI.options.name = "Mr. Slave Chat Bot";
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			
			chatTimer.addEventListener(TimerEvent.TIMER, handleChatTimer);
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			processRules(event.originalText);
		}
		
		private function queueMessage(chat:String):void {
			if (chat == null) { return; }
			pendingMessage = chat;
			chatTimer.reset();
			chatTimer.delay = 1000 + pendingMessage.length * 15;
			chatTimer.start();
		}
		
		private function handleChatTimer(event:TimerEvent):void {
			var x:int = api.thisObject.x + 25;
			var y:int = api.thisObject.y + 25;
			api.thisRoom.announce("@" + x + "," + y + " " + pendingMessage);
			api.thisRoom.broadcastMessageLocal({
				msg: "mrGarrisonChat",
				text: pendingMessage
			});
		}
		
		private function processRules(chat:String):void {
			var success:Boolean = false;
			for each (var rule:Object in rules) {
				if (rule.condition === 'all') {
					success = processRuleConditionAll(chat, rule);
				}
				else if (rule.condition === 'any') {
					success = processRuleConditionAny(chat, rule);
				}
				else if (rule.condition === 'nomatch') {
					success = processRuleConditionNoMatch(chat, rule);
				}
				else {
					throw new Error("Unrecognized Rule Condition: " + rule.condition);
				}
				if (success) {
					break;
				}
			}
		}
		
		private function processRuleConditionAll(chat:String, rule:Object):Boolean {
			var wordsMatched:int = 0;
			var lcChat:String = chat.toLowerCase();
			for each (var word:String in rule.words) {
				if (lcChat.indexOf(word) !== -1) {
					wordsMatched ++;
				}
			}
			if (wordsMatched === rule.words.length) {
				queueMessage(chooseResponse(rule));
				return true;
			}
			return false;
		}
		
		private function processRuleConditionAny(chat:String, rule:Object):Boolean {
			var wordsMatched:int = 0;
			var lcChat:String = chat.toLowerCase();
			for each (var word:String in rule.words) {
				if (lcChat.indexOf(word) !== -1) {
					wordsMatched ++;
				}
			}
			if (wordsMatched > 0) {
				queueMessage(chooseResponse(rule));
				return true;
			}
			return false;
		}
		
		private function processRuleConditionNoMatch(chat:String, rule:Object):Boolean {
			queueMessage(chooseResponse(rule));
			return true;
		}
		
		private function chooseResponse(rule:Object):String {
			if (rule.responseMode === "linear") {
				if (!rule.hasOwnProperty('responseIndex')) {
					rule.responseIndex = 0;
				}
				else {
					rule.responseIndex ++;
				}
				if (rule.responseIndex >= rule.responses.length) {
					rule.responseIndex = 0;
				}
				return rule.responses[rule.responseIndex];
			}
			else if (rule.responseMode === "random") {
				return rule.responses[Math.floor(Math.random()*rule.responses.length)];
			}
			return "No response defined";
		}
	}
}