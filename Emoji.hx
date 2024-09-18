package;

using api.IdeckiaApi;
using StringTools;

typedef Props = {
	@:editable("prop_emoji_server", "https://github.com/cheatsnake/emojihub")
	var emoji_server:String;
	@:editable("prop_emoji_size", 50)
	var emoji_size:Int;
}

enum ViewMode {
	image;
	name;
	unicode;
}

@:name("emoji")
@:description("action_description")
@:localize
class Emoji extends IdeckiaAction {
	var currentViewMode:ViewMode = image;
	var currentResponse:Response;
	var initialTextSize:UInt;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			currentViewMode = image;
			initialTextSize = initialState.textSize;
			execute(initialState).then(outcome -> resolve(outcome.state)).catchError(reject);
		});
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			var http = new haxe.Http(props.emoji_server);
			http.addHeader("Content-type", "application/json");
			http.onError = reject;
			http.onData = (data) -> {
				currentResponse = haxe.Json.parse(data);
				resolve(new ActionOutcome({state: showResponse(currentState)}));
			};
			http.request();
		});
	}

	function showResponse(currentState:ItemState) {
		currentState.text = switch currentViewMode {
			case image:
				var unicodes = [
					for (unicode in currentResponse.unicode)
						unicode.replace('U+', '')
				];
				currentState.textSize = props.emoji_size;
				'{emoji.${unicodes.join(',')}}';
			case name:
				currentState.textSize = initialTextSize;
				currentResponse.name;
			case unicode:
				currentState.textSize = initialTextSize;
				currentResponse.unicode.join(',');
		}

		return currentState;
	}

	override function onLongPress(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise<ActionOutcome>((resolve, reject) -> {
			currentViewMode = switch currentViewMode {
				case image: name;
				case name: unicode;
				case unicode: image;
			}
			resolve(new ActionOutcome({state: showResponse(currentState)}));
		});
	}
}

typedef Response = {
	var name:String;
	var category:String;
	var group:String;
	var htmlCode:Array<String>;
	var unicode:Array<String>;
}
