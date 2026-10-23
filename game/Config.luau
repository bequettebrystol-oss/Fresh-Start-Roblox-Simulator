local C = {}
C.Bands = {
 {Name = "BACKYARD FM", Color = Color3.fromRGB(75,239,200)},
 {Name = "MOONWAVE", Color = Color3.fromRGB(177,145,255)},
 {Name = "VOIDCAST", Color = Color3.fromRGB(255,164,98)},
}
C.Creatures = {
 {Name="Bloopini", Band=1, Weight=50, Income=2, Color=Color3.fromRGB(98,231,192), Shape="Ball"},
 {Name="Toast Goblin", Band=1, Weight=30, Income=4, Color=Color3.fromRGB(255,199,119), Shape="Block"},
 {Name="Wobble Bob", Band=1, Weight=16, Income=7, Color=Color3.fromRGB(255,139,183), Shape="Ball"},
 {Name="Sir Static", Band=1, Weight=4, Income=14, Color=Color3.fromRGB(176,162,255), Shape="Block"},
 {Name="Lunar Noodle", Band=2, Weight=50, Income=18, Color=Color3.fromRGB(168,171,255), Shape="Ball"},
 {Name="Disco Dumpling", Band=2, Weight=30, Income=27, Color=Color3.fromRGB(248,139,237), Shape="Ball"},
 {Name="Cosmic Crumb", Band=2, Weight=16, Income=42, Color=Color3.fromRGB(114,218,255), Shape="Block"},
 {Name="Professor Beep", Band=2, Weight=4, Income=75, Color=Color3.fromRGB(255,222,115), Shape="Block"},
 {Name="Void Pickle", Band=3, Weight=50, Income=90, Color=Color3.fromRGB(162,239,120), Shape="Ball"},
 {Name="Glitch Gremlin", Band=3, Weight=30, Income=135, Color=Color3.fromRGB(255,133,108), Shape="Block"},
 {Name="Orbit Overlord", Band=3, Weight=16, Income=210, Color=Color3.fromRGB(128,168,255), Shape="Ball"},
 {Name="The Last Braincell", Band=3, Weight=4, Income=380, Color=Color3.fromRGB(255,224,143), Shape="Ball"},
}
C.AntennaCosts = {350, 2400}
C.ReceiverCosts = {100, 300, 900, 2500}
function C.Value(id, count)
 return C.Creatures[id].Income * (1 + .15 * (math.min(count, 10)-1))
end
function C.Best(owned)
 local best = {}
 for key,count in pairs(owned) do
  local id=tonumber(key)
  if C.Creatures[id] and count>0 then table.insert(best,{Id=id,Count=count,Value=C.Value(id,count)}) end
 end
 table.sort(best,function(a,b) if a.Value==b.Value then return a.Id<b.Id end return a.Value>b.Value end)
 local income=0
 for i=1,math.min(3,#best) do income+=best[i].Value end
 return best,math.floor(income)
end
return C
