-- Abbreviations used in this article and the LuaSnip docs
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
-- Place this in ${HOME}/.config/nvim/LuaSnip/all.lua
return {
  -- A snippet that expands the trigger "hi" into the string "Hello, world!".
  require("luasnip").snippet(
    { trig = "hi" },
    { t("Hello, World!\n") }
  ),

  require("luasnip").snippet(
    { trig = "structdef" },
    {
        -- t({"typedef struct S S;", "struct S {", "};"})
        t("typedef struct "), i(1), t(" "), rep(1), t({";",
        "struct "}), rep(1), t({" {",
        "};"})
        -- fmta(
        --     [[
        --         typedef struct <> <>;
        --         struct <> {
        --         };
        --     ]],
        --     { i(1), rep(1), rep(1) }
        -- )
    }
  ),
}
