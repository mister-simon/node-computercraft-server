# node-computercraft-server

Computercraft scripts made available via a node based server currently hosted on heroku.

Focus of the project is to make fun and fancy scripts in a more developer friendly way, pulling scripts globally from the node server as if pulling from a git repo.

# Setting up

- Make a turtle or computer
  - For a fancier effect, make it advanced
- Type `lua`
- Copy and paste the one liner: [scripts/getAllScriptsOneLiner.lua](https://github.com/mister-simon/node-computercraft-server/blob/master/scripts/getAllScriptsOneLiner.lua)

```lua
loadstring(http.get("https://cc-scripts.herokuapp.com/scripts/getAllScripts.lua").readAll())()
```

- Now you can add nice things like a startup script

```lua
-- Grab scripts again
shell.run("scripts/getAllScriptsFancy.lua")
```
