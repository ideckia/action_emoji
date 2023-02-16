package;

using api.IdeckiaApi;
using StringTools;

typedef Props = {
	@:editable("Emojis server", "https://emojihub.yurace.pro/api/random")
	var emoji_server:String;
	@:editable("Emojis size", 50)
	var emoji_size:Int;
}

enum ViewMode {
	image;
	name;
	unicode;
}

@:name("emoji")
@:description("Show a random emoji every click")
class Emoji extends IdeckiaAction {
	var currentViewMode:ViewMode = image;
	var currentResponse:Response;
	var initialTextSize:UInt;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		currentViewMode = image;
		initialTextSize = initialState.textSize;
		return execute(initialState);
	}

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var http = new haxe.Http(props.emoji_server);
			http.addHeader("Content-type", "application/json");
			http.onError = reject;
			http.onData = (data) -> {
				try {
					currentResponse = haxe.Json.parse(data);
					resolve(showResponse(currentState));
				} catch (e:haxe.Exception) {
					reject(e);
				}
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

	override function onLongPress(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise<ItemState>((resolve, reject) -> {
			currentViewMode = switch currentViewMode {
				case image: name;
				case name: unicode;
				case unicode: image;
			}
			resolve(showResponse(currentState));
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
