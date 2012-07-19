package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChatEvent;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class NoSoup extends Sprite
	{
		public var api:WorlizeAPI;
		
		private var botName:String = "Harry";
		
		private var chatTimer:Timer = new Timer(1000, 1);
		
		private var pendingResponse:Object;
		
		private var rules:Array = [
			{
				condition: "all",
				responseMode: "random",
				words: ["soup"],
				responses: [
					{ say: "No soup for you!" }
				]
			},
			{
				condition: "all",
				responseMode: "random",
				words: ["soap"],
				responses: [
					{ say: "No soap radio!" }
				]
			},
			{
				condition: "all",
				responseMode: "random",
				words: ["asparagus"],
				responses: [
					{ say: "I prefer rutabagas myself!" }
				]
			},
			{
				condition: "all",
				responseMode: "random",
				words: ["do you like"],
				responses: [
					{ say: ":meh." }
				]
			},
			{
				condition: "all",
				responseMode: "random",
				words: ["may the force be with you"],
				responses: [
					{ say: "The force will be with you, {{username}}!" }
				]
			},
			{
				condition: "any",
				responseMode: "linear",
				words: [
					new RegExp("(hi|hello) .*harry")
				],
				responses: [
					{ say: "Hello, {{username}} what can I get you?" },
					{ say: "Hello to you too, {{username}}!" },
					{ say: "Hey, {{username}}.  What'll it be?" } 
				]
			},
			{
				condition: "any",
				responseMode: "linear",
				words: [ "happy hour", "happyhour" ],
				responses: [
					{ say: "Free Drinks during Happy Hour!" }
				]
			},
			{
				condition: "any",
				words: [ 'harry', 'bartender', 'barkeep', 'bottender' ],
				rules: [
					{
						condition: "any",
						words: [ "give me", "gimme", "i want", "make me", "may i have", "i'll have", "i get a", "can I have", "i'll get a" ],
						notWords: [ 'please', 'may i', 'plz' ],
						responseMode: "linear",
						responses: [
							{ say: "Ask nicely, {{username}}." },
							{ say: "Say \"please,\" {{username}}." },
							{ say: "I'd be happy to oblige, but ask nicely, {{username}}" }
						]
					},
					{
						condition: "any",
						words: [ "you suck", "hate you" ],
						responseMode: "random",
						responses: [
							{ say: "I don't particularly care for you either, {{username}}!" }
						]
					},
					{
						condition: "any",
						words: [ 'fuck', 'wanker', 'bitch', 'bastard', 'shit', 'cocksucker' ],
						responseMode: "linear",
						responses: [
							{ say: "Don't talk to me like that, {{username}}!" },
							{ say: "How dare you speak to me like that, {{username}}!" },
							{ say: "Get out of my bar, {{username}}!" },
							{ say: "I'm warning you, {{username}}!" },
							{ say: "You'd better shape up, {{username}}." },
							{ say: "I think you've had a few too many.  I'm cutting you off, {{username}}." }
						]
					},
					{
						condition: "any",
						words: [ new RegExp("are you.*alcoholic.*\\?$") ],
						responseMode: "linear",
						responses: [ 
							{ say: "I've been sober for 12 years, but it's a struggle every day." }
						]
					},
					{
						condition: "any",
						words: [ new RegExp("(re|are) fired"),
						         new RegExp("(going to)? fire?(ing)? you") ],
						responseMode: "random",
						responses: [
							{ say: "!You can't fire me, {{username}}, I quit!" },
							{ say: ":Oh it's going to be like that, is it?!" },
							{ say: "I would reconsider that threat if I were you, {{username}}" }
						]
					},
					{
						condition: "any",
						words: [ 'please', 'plz', 'may i' ],
						rules: [
							{
								condition: "any",
								responseMode: "random",
								words: ["beer","brewski","cold one"],
								responses: [
									{
										say: "Have a beer, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "f6af3702-0889-f117-9d0d-41de40e72d57"
										}
									},
									{
										say: "Here's a nice cold one, {{username}}, on me.",
										dispenseProp: {
											at: "user",
											guid: "d38f14d3-88a6-23a4-0ee5-b9f7c6b7d4b0"
										}
									}
								]
							},
							{
								condition: "all",
								responseMode: "random",
								words: ["strawberry margarita"],
								responses: [
									{
										say: "Enjoy your blended strawberry margarita, {{username}}.  I even rimmed the glass with sugar, just for you.",
										dispenseProp: {
											at: "user",
											guid: "551de43c-7163-894b-7235-ce0c9123350c"
										}
									}
								]
							},
							{
								condition: "all",
								responseMode: "random",
								words: ["margarita"],
								responses: [
									{
										say: "My apologies, I can only make a blended strawberry margarita, {{username}}.  But I rimmed the glass with sugar, just for you!",
										dispenseProp: {
											at: "user",
											guid: "551de43c-7163-894b-7235-ce0c9123350c"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [ "tequilla", "rum", "shot" ],
								responses: [
									{
										say: "Here's a shot, {{username}}.  On the house.",
										dispenseProp: {
											at: "user",
											guid: "7f33a5ab-c3a0-b7b2-3cb7-3e914157ddb0"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [ "tequilla sunrise", "umbrella" ],
								responses: [
									{
										say: "Ah there's nothing like a little tequilla in the morning!",
										dispenseProp: {
											at: "user",
											guid: "a3e63636-98fa-affb-1536-40c8b22237be"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: ["maitai", "mai tai", "tropical", "fruity"],
								responses: [
									{
										say: "A nice fruity Mai Tai, just for you, {{username}}.",
										dispenseProp: {
											at: "user",
											guid: "41a10bf4-0c34-61db-506d-69359c592840"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: ["cosmo","girly"],
								responses: [
									{
										say: "Alright, {{username}}. Cosmopolitan, coming right up!",
										dispenseProp: {
											at: "user",
											guid: "36b310fc-285c-99d9-e726-6a43bd88dee7"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [new RegExp("(pear|apple)(tini| martini)")],
								responses: [
									{
										say: "Here you go, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "c33dbd4b-c42e-4636-5b59-771a125fe84e"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [ "adios", "hurricane" ],
								responses: [
									{
										say: "Here you go, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "9ab508f8-f807-1cee-6e56-863b8bd75220"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [
									new RegExp("(dry|gin|vodka) martini")
								],
								responses: [
									{
										say: "Have a dry martini, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "9c71f161-e9ae-a677-dc42-f6ce26931f72"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: ["martini"],
								responses: [
									{
										say: "Have a pomegranate martini, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "36b310fc-285c-99d9-e726-6a43bd88dee7"
										}
									},
									{
										say: "Have a dry gin martini with vermouth, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "9c71f161-e9ae-a677-dc42-f6ce26931f72"
										}
									},
									{
										say: "Enjoy a nice sweet Appletini, {{username}}!",
										dispenseProp: {
											at: "user",
											guid: "c33dbd4b-c42e-4636-5b59-771a125fe84e"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: ["coke","pepsi","shasta","cola","pepper","root beer","a&w","barqs"],
								responses: [
									{
										say: "Trying to sober up, huh {{username}}?",
										dispenseProp: {
											at: "user",
											guid: "f2c342f0-41df-da66-138b-05832e753c31"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: [ "coffee","java","espresso","macchiato","capuccino","cappuccino" ],
								responses: [
									{
										say: "This'll help with that hangover, {{username}}.",
										dispenseProp: {
											at: "user",
											guid: "59d70087-8d57-ff6f-fcd9-45f981325290"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "random",
								words: ["whiskey", "whisky", "jack", "hennessey", "makers mark", "maker's mark"],
								responses: [
									{
										say: "This is all I got, {{username}}. It'll have to do.",
										dispenseProp: {
											at: "user",
											guid: "fd216956-7449-b6cf-0951-2504621dc918"
										}
									}
								]
							},
							{
								condition: "any",
								responseMode: "linear",
								words: [ "a drink" ],
								responses: [
									{
										say: "What kind of drink would you like, {{username}}?"
									}
								]
							},
							{
								condition: "nomatch",
								responseMode: "linear",
								responses: [
									{ say: "I don't think I can do that, {{username}}." },
									{ say: "Are you sure, {{username}}?" },
									{ say: "I'm not sure that's such a good idea, {{username}}.  Maybe something else?" }
								]
							}
						]
					},
					{
						condition: "any",
						responseMode: "random",
						words: ["thank you", "thanks"],
						responses: [
							{ say: "You're welcome, {{username}}!" },
							{ say: "You're most welcome, {{username}}!" },
							{ say: "Think nothing of it, {{username}}!" },
							{ say: "My pleasure, {{username}}." }
						]
					},
					{
						condition: "any",
						responseMode: "random",
						words: ["gracias"],
						responses: [
							{ say: "¡De nada, {{username}}!" },
							{ say: "¡No hay de qué, {{username}}!" }
						]
					},
					{
						condition: "any",
						responseMode: "linear",
						words: [new RegExp("(\\'s|is|re) .*(awesome|excellent|nice|sweet|cute|hot|adorable|handsome)","i"),
								new RegExp("(does)? (excellent)","i"),
								new RegExp("(make|makes|made|pour|poured|mixes|mixed).*(classic|awesome|perfect|delicious|good|great|tasty|yummy|fantastic).*(drink|cocktail|martini|beer)s?")],
						responses: [
							{ say: "Thanks, {{username}}, I'm glad you think so." },
							{ say: "My mom always told me as much, {{username}}." },
							{ say: ":{{username}}, Your lover told me that last night." }
						]
					},
					{
						condition: "any",
						words: [ "buy you a drink", "get you a drink", "you want a drink", "have a shot", "have a drink" ],
						notWords: [ "i have a", "we'll have a" ],
						responseMode: "random",
						responses: [
							{ say: "Thanks, but I don't drink on the job, {{username}}." }
						]
					},
					{
						condition: "any",
						words: [ new RegExp("(get|buy|give|make|pour) ([\\w]*?) a (.*?)") ],
						responseMode: "linear",
						responses: [
							{ say: "I don't think they would want one of those, {{username}}" }
						]
					},
					{
						condition: "any",
						responseMode: "random",
						words: [new RegExp(' .*\\?$', 'i')],
						responses: [
							{ say: "Yes, {{username}}." },
							{ say: "Absolutely, {{username}}!" },
							{ say: "Without a doubt, {{username}}." },
							{ say: "Probably, {{username}}." },
							{ say: "Maybe, {{username}}!" },
							{ say: "You know, {{username}}, I'm not sure." },
							{ say: "Unfortunately no, {{username}}." },
							{ say: "Not a chance, {{username}}." },
							{ say: "When toasters fly, {{username}}." }
						]
					},
					{
						condition: "any",
						responseMode: "linear",
						words: [new RegExp("^[^\s]*\\?$")],
						responses: [
							{ say: "Yes?" },
							{ say: "What can I do for you, {{username}}?" },
							{ say: "What now?" }
						]
					},
					{
						condition: "any",
						responseMode: "linear",
						words: [new RegExp('\\?$')],
						responses: [
							{ say: "Come again, {{username}}?" },
							{ say: "{{username}}, I didn't quite catch that." },
							{ say: "I do better with \"yes\" or \"no\" questions, {{username}}" },
							{ say: "Whatchu talkin' 'bout, willis?" }
						]
					}
				]
			}
		];
		
		public function NoSoup()
		{
			WorlizeAPI.options.defaultWidth = 50;
			WorlizeAPI.options.defaultHeight = 50;
			WorlizeAPI.options.name = "botTender";
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			
			chatTimer.addEventListener(TimerEvent.TIMER, handleChatTimer);
			
			queueMessage({
				say: "Hi, {{username}}.  I'm Harry, and this is my bar. Ask me anything you want. In the mean time, can I get you a drink?"
			});
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			if (event.isWhisper) { return; }
			processRules(event.originalText, rules);
		}
		
		private function queueMessage(response:Object):void {
			if (response == null) { return; }
			
			pendingResponse = response;
			
			chatTimer.reset();
			chatTimer.delay = ('say' in response) ? 1000 + response.say.length * 15 : 10;
			chatTimer.start();
		}
		
		private function handleChatTimer(event:TimerEvent):void {
			var x:int = api.thisObject.x + 25;
			var y:int = api.thisObject.y + 25;
			
			if ('say' in pendingResponse) {
				var message:String = pendingResponse.say.replace(/\{\{username\}\}/g, api.thisUser.name);
				api.thisRoom.announce("@" + x + "," + y + " " + message);
				api.thisRoom.broadcastMessageLocal({
					msg: "botChat",
					botName: botName,
					text: message
				});
			}
			if ('dispenseProp' in pendingResponse) {
				var dispense:Object = pendingResponse.dispenseProp;
				if ('at' in dispense) {
					var propX:Number = NaN;
					var propY:Number = NaN;

					if (dispense.at === 'user') {
						propX = (api.thisUser.x > api.thisRoom.width-75) ? api.thisUser.x - 75 : api.thisUser.x + 75;
						propY = api.thisUser.y;
					}
					else if (dispense.at is Array) {
						propX = dispense.at[0];
						propY = dispense.at[1];
					}
					if (!isNaN(propX) && !isNaN(propY)) {
						api.thisRoom.addLooseProp(dispense.guid, propX, propY);
						api.thisRoom.broadcastMessageLocal({
							msg: "botDispenseProp",
							botName: botName,
							x: propX,
							y: propY,
							guid: dispense.guid
						});
					}
				}
			}
		}
		
		private function processRules(chat:String, ruleSet:Array):void {
			var success:Boolean = false;
			for each (var rule:Object in ruleSet) {
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
			var word:*;
			if ('notWords' in rule) {
				for each (word in rule.notWords) {
					if (lcChat.search(word) !== -1) {
						return false;
					}
				}
			}
			for each (word in rule.words) {
				if (lcChat.search(word) !== -1) {
					wordsMatched ++;
				}
			}
			if (wordsMatched === rule.words.length) {
				executeResponse(chat, rule);
				return true;
			}
			return false;
		}
		
		private function processRuleConditionAny(chat:String, rule:Object):Boolean {
			var wordsMatched:int = 0;
			var lcChat:String = chat.toLowerCase();
			var word:*;
			if ('notWords' in rule) {
				for each (word in rule.notWords) {
					if (lcChat.search(word) !== -1) {
						return false;
					}
				}
			}
			for each (word in rule.words) {
				if (lcChat.search(word) !== -1) {
					wordsMatched ++;
				}
			}
			if (wordsMatched > 0) {
				executeResponse(chat, rule);
				return true;
			}
			return false;
		}
		
		private function processRuleConditionNoMatch(chat:String, rule:Object):Boolean {
			executeResponse(chat, rule);
			return true;
		}
		
		private function executeResponse(chat:String, rule:Object):void {
			if ('rules' in rule) {
				processRules(chat, rule.rules);
				return;
			}
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
				queueMessage(rule.responses[rule.responseIndex]);
			}
			else if (rule.responseMode === "random") {
				queueMessage(rule.responses[Math.floor(Math.random()*rule.responses.length)]);
			}
			return;
		}
	}
}