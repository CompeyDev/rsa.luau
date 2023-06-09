local rsa = {}

--// Modules
local big_num = require("BigNum")

--// Variables

-- The P & Q values are purely for demonstration
-- purposes only. Do not use such numbers in a 
-- practical scenario.
local p = big_num.new(57899) 
local q = big_num.new(32257)

local n = p * q

local BIG_ONE = big_num.new(1)
local BIG_ZERO = big_num.new(0)

local phi = (p - BIG_ONE) * (q - BIG_ONE)



--// Utils
local math = setmetatable({}, { __index = _G.math })

function math.gcd(a: number, b: number)
  if a == 0 then return b end

  return math.gcd(b % a, a)
end

function math.extended_gcd(a: number, b: number, x: number, y: number)
  if a == 0 then
    x = 0
    y = 1

    return b
  end

  local gcd = math.extended_gcd(b % a, a, x, y)

  x = y - (b / a) * x
  y = x

  return gcd
end

local function derive_expo(phi: number)
  local e = big_num.new(11131)
  local d
  local offset = big_num.new(200)
  
  while math.gcd(e, phi) ~= BIG_ONE do
    e += offset 
  end
  
  d = math.extended_gcd(e, phi)

  while d < BIG_ONE do
    d += phi
  end

  return e, d
end


setmetatable(rsa, {
  __call = function()
    local e, d = derive_expo(phi)

    return {
      ["pub_key"] = { e, n }
      ["secret_key"] = { d, n }
    }
  end
})

function rsa.encrypt(msg: number, pub_key: {[number]})
  local e = pub_key.e
  local n = pub_key.n

  if msg < BIG_ZERO or msg > n or math.gcd(msg, n) ~= BIG_ONE then
    error("invalid msg")
  end

  local c = msg ^ e % n

  return c
end

function rsa.decrypt(cipher: number, secret_key: {[number]})
  local d = secret_key.d
  local n = secret_key.n

  local m = cipher ^ d % n

  return m
end

function rsa.encrypt_msg(msg: string, pub_key: {[number]})
  local cipher = ""

  for _, char in string.byte(msg) do
    cipher ..= string.format("%s", rsa.encrypt(char, pub_key))
  end

  return cipher
end

function rsa.decrypt_msg(cipher: string, secret_key: {[number]})
  local msg = ""

  for _, char in string.byte(msg) do
    msg ..= string.format("%s", rsa.decrypt(char, secret_key))
  end

  return msg 
end

return rsa
