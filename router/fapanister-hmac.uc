#!/usr/bin/ucode
let d = require("digest");
let key = b64dec(key_b64);
if (length(key) > 64)
  key = hexdec(d.sha256(key));

function pad(k, p) {
  let out = "";
  for (let i = 0; i < 64; i++)
    out += chr((i < length(k) ? ord(k, i) : 0) ^ p);
  return out;
}

let inner = hexdec(d.sha256(pad(key, 0x36) + body));
print(d.sha256(pad(key, 0x5c) + inner));
