local rsa = {}

--// Modules
local big_num = require("BigNum")

--// Utils
local function deep_copy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local math = deep_copy(_G.math)

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

-- The P & Q values are purely for demonstration
-- purposes only. Do not use such numbers in a 
-- practical scneario.
local p = big_num.new(57899) 
local q = big_num.new(32257)

local n = p * q

local big_one = big_num.new(1)
local big_zero = big_num.new(0)

local phi = (p - big_one) * (q - big_one)

local function derive_expo(phi: number)
  local e = big_num.new(11131)
  local d
  local offset = big_num.new(200)
  
  while math.gcd(e, phi) ~= big_one do
    e += offset 
  end
  
  d = math.extended_gcd(e, phi)

  while d < big_one do
    d += phi
  end

  return e, d
end


setmetatable(rsa, {
  __call = function(phi: number, n: number)
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

  if msg < big_zero or msg > n or math.gcd(msg, n) ~= big_one then
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
