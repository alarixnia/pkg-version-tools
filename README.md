# pkg-version-tools

Tools for identifying when stuff in pkgsrc needs updating.

_Current data sources_: Wikidata, Freshcode

Please be cautious of excessively querying these APIs.

_Requirements_: `textproc/lua-cjson`, `www/lua-curl`, `pkgtools/pkgsrc-todo`

Usage
-----

If your pkgsrc is outside `/usr/pkgsrc`, set `PKGSRCDIR` in the environment.

Commands take a list of packages in the form of category/name. Comments begin with #.

Add new packages with their data sources to packages.lua.

Examples
--------

```
lua gen_todo.lua < package_list.txt
```
