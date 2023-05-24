local rsa = require("rsa")

local real_msg = "Hello, world!"

local encrypted = rsa.encrypt_msg(real_msg)
local decrypted = rsa.decrypt_msg(encrypted)

assert(decrypted == real_msg)
