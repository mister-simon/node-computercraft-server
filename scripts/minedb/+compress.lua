local pp     = require("cc.pretty").pretty_print
local getNas = require("/scripts/minedb/nas")
local arr    = require("/scripts/api/arr")

local nas    = getNas("back")
nas.setInputName('minecraft:chest_16')
nas.setOutputName('minecraft:chest_17')

local items = nas.list()
arr.each(items, function(collection)
    print(collection.displayName())
    collection.compress()
end)