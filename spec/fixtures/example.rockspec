package = "example"
version = "1.0.0-1"
source = {
   url = "git://github.com/example/example.git",
   tag = "v1.0.0"
}
description = {
   summary = "An example Lua package",
   detailed = [[
      This is an example package.
   ]],
   homepage = "https://github.com/example/example",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luafilesystem >= 1.8.0",
   "lpeg ~> 1.0",
   "luasocket"
}
build = {
   type = "builtin",
   modules = {
      example = "src/example.lua"
   }
}
