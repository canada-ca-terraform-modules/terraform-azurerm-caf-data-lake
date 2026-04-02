locals {
  name_regex          = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters  name: \/"'[]:|<>+=;,?*@&
  env_4               = substr(var.env, 0, 4)
  userDefinedString_7 = substr(var.userDefinedString, 0, 7)
}
