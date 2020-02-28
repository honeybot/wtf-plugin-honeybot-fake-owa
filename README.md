# Fake OWA plugin for wtf

## Policy example

Mandatory options:
- version: version of OWA to emulate. Currently only 15.0 supported.
- path: path to data folder (usually installed in /usr/local/share/wtf/data/)

```
{
    "name": "fake-owa",
    "version": "0.1",
    "storages": { },
    "plugins": {            
        "honeybot.fake.owa": [{
			"version": "15.0",
			"path":"/usr/local/share/wtf/data/honeybot/fake/owa/"
		}]
    },
    "actions": {},
    "solvers": {}
}
```