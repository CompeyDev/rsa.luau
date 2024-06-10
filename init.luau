local rsa = require("rsa")

local keys = rsa()
local real_msg = "Hello, world!"

local encrypted = rsa.encrypt_msg(real_msg, keys.pub_key)
local decrypted = rsa.decrypt_msg(encrypted, keys.secret_key)

assert(decrypted == real_msg)
