local upower = require("upower")

tab = upower:get_status()

for k,v in pairs(tab) do
   print(k,v)
end
