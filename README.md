# pkg-version-tools

Tools for identifying when stuff in pkgsrc needs updating.

**Current data sources**: Wikidata, Freshcode

Please be cautious of excessively querying these APIs.

**Requirements**: `textproc/lua-cjson`, `www/lua-curl`,

**For gen_todo**: `pkgtools/pkgsrc-todo`

**For gen_html**: `textproc/lua-lustache`

Usage
-----

If your pkgsrc is outside `/usr/pkgsrc`, set `PKGSRCDIR` in the environment.

Commands take a list of packages in the form of category/name. Comments begin with #.

Add new packages with their data sources to packages.lua.

Examples
--------

```
lua gen_todo.lua < package_list.txt
lua gen_html.lua < package_list.txt
```
