# Action for [ideckia](https://ideckia.github.io/): emoji

## Description

Show a random emoji (by default from [emojihub](https://github.com/cheatsnake/emojihub)) every click

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| emoji_server | String | Emojis server | false | "https://github.com/cheatsnake/emojihub" | null |
| emoji_size | Int | Emojis size | false | 50 | null |

## On single click

Updates the emoji

## On long click

Changes the visualization mode: emoji itself, name, unicode

## Example in layout file

```json
{
    "state": {
        "text": "emoji action example",
        "actions": [
            {
                "name": "emoji",
                "props": {
                    "emoji_server": "https://github.com/cheatsnake/emojihub",
                    "emoji_size": 50
                }
            }
        ]
    }
}
```