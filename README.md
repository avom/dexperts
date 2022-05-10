# dexperts

Spell checker experts for Delphi IDE. It's currently just a proof of concept and tested on Delphi 10.4.

Easiest way to install it is to build the dll and enable it using GExperts Expeper Manager.

Settings are loaded from user AppData\Local\Dexperts\settings.json.

```
{
	"spelling_error": {
		"color": "red",
		"style": "sin"
	}
}
```

Valid options for style are line, dashes, dots and sin.

The directory must also contain a file dictionary.txt containing list of supported words one per line. For example https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt
