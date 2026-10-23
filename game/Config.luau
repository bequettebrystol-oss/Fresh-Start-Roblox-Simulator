local C = {}
C.Bands = {
 {Name = "BACKYARD FM", Color = Color3.fromRGB(75,239,200)},
 {Name = "MOONWAVE", Color = Color3.fromRGB(177,145,255)},
 {Name = "VOIDCAST", Color = Color3.fromRGB(255,164,98)},
}
C.Creatures = {
 {Name="Bloopini", Band=1, Weight=50, Income=.25, Color=Color3.fromRGB(98,231,192), Shape="Ball"},
 {Name="Toast Goblin", Band=1, Weight=30, Income=.4, Color=Color3.fromRGB(255,199,119), Shape="Block"},
 {Name="Wobble Bob", Band=1, Weight=16, Income=.65, Color=Color3.fromRGB(255,139,183), Shape="Ball"},
 {Name="Sir Static", Band=1, Weight=4, Income=1.1, Color=Color3.fromRGB(176,162,255), Shape="Block"},
 {Name="Lunar Noodle", Band=2, Weight=50, Income=1.4, Color=Color3.fromRGB(168,171,255), Shape="Ball"},
 {Name="Disco Dumpling", Band=2, Weight=30, Income=2, Color=Color3.fromRGB(248,139,237), Shape="Ball"},
 {Name="Cosmic Crumb", Band=2, Weight=16, Income=2.9, Color=Color3.fromRGB(114,218,255), Shape="Block"},
 {Name="Professor Beep", Band=2, Weight=4, Income=4.5, Color=Color3.fromRGB(255,222,115), Shape="Block"},
 {Name="Void Pickle", Band=3, Weight=50, Income=5.5, Color=Color3.fromRGB(162,239,120), Shape="Ball"},
 {Name="Glitch Gremlin", Band=3, Weight=30, Income=7.5, Color=Color3.fromRGB(255,133,108), Shape="Block"},
 {Name="Orbit Overlord", Band=3, Weight=16, Income=10, Color=Color3.fromRGB(128,168,255), Shape="Ball"},
 {Name="The Last Braincell", Band=3, Weight=4, Income=15, Color=Color3.fromRGB(255,224,143), Shape="Ball"},
}
C.AntennaCosts = {900, 14000}
C.ReceiverCosts = {80,300,1100,4000,12000,32000,65000}
C.FloorCosts={6500,35000}
C.PerfectSpeed=1.10
C.PerfectCash=1.10
C.Upgrades = {
 {Key="Antenna",Name="Antenna",Costs=C.AntennaCosts},
 {Key="Receiver",Name="Receiver",Costs=C.ReceiverCosts},
 {Key="Stabilizer",Name="Signal stabilizer",Costs={120,500,2100,7500}},
 {Key="Decoder",Name="Signal decoder",Costs={180,850,3800,14000}},
 {Key="Amplifier",Name="Broadcast amplifier",Costs={250,1300,6000,20000,55000}},
 {Key="Booths",Name="Ground floor booths",Costs={650,3200,12000}},
}
function C.FloorLevel(data)
 local level=tonumber(data and data.Floors) or 1
 if level~=level then level=1 end
 return math.clamp(math.floor(level),1,3)
end
function C.SlotActive(data,index)
 if index<=6 then return index<=2+((data and data.Booths) or 1) end
 return index<=9 and C.FloorLevel(data)>=2 or index<=12 and index>=10 and C.FloorLevel(data)>=3
end
function C.Money(value)
 local rounded=math.floor(value*100+.5)/100
 if rounded%1==0 then return tostring(math.floor(rounded)) end
 return (string.format("%.2f",rounded):gsub("0$",""))
end
function C.Required(level,band,risky) return 8+(band-1)*2+(risky and 2 or 0)-.5*(level-1) end
function C.CaptureReward(id,perfect)
 return math.max(1,math.floor(C.Creatures[id].Income*.4*(perfect and C.PerfectCash or 1)*100+.5)/100)
end
function C.Levels(data)
 local levels={}
 for _,u in ipairs(C.Upgrades) do
  local n=tonumber(data and data[u.Key]) or 1
  if n~=n then n=1 end
  levels[u.Key]=math.clamp(math.floor(n),1,#u.Costs+1)
 end
 return levels
end
function C.Slots(data) return 2+((data and data.Booths) or 1)+3*(C.FloorLevel(data)-1) end
function C.Multiplier(data) return 1+.10*(((data and data.Amplifier) or 1)-1) end
function C.Description(key,level)
 if key=="Antenna" then return "Receives "..C.Bands[level].Name
 elseif key=="Receiver" then return "Tuning window +"..string.format("%.1f",(level-1)*2.2).." percentage points"
 elseif key=="Stabilizer" then return "Drift "..(level-1)*8 .."% slower / "..string.format("%.2fs",.20+.06*(level-1)).." slip grace"
 elseif key=="Decoder" then return string.format("%.1fs lock on clear Backyard FM",C.Required(level,1,false))
 elseif key=="Amplifier" then return "+"..(level-1)*10 .."% broadcast income"
 elseif key=="Booths" then return tostring(level+2).." ground floor booths (upstairs uses pads)" end
 return ""
end
function C.SignalStats(data,band,risky)
 return {Speed=((risky and 1.1 or .7)+band*.18)*(1-.08*(data.Stabilizer-1)),
  Width=(risky and .115 or .185)+(data.Receiver-1)*.022,
  Required=C.Required(data.Decoder,band,risky),Grace=.20+.06*(data.Stabilizer-1),
  Amplitude=risky and .34 or .30,Duration=70}
end
function C.Target(s,now)
 local t=(now-s.Start)*s.Speed+s.Phase
 return .5+s.Amplitude*(s.Risky and (.8*math.sin(t)+.2*math.sin(t*1.7+s.Phase)) or math.sin(t))
end
function C.Value(id, count)
 return C.Creatures[id].Income * (1 + .03 * (math.min(count, 10)-1))
end
function C.Best(owned,levels)
 local best = {}
 for key,count in pairs(owned) do
  local id=tonumber(key)
  if C.Creatures[id] and count>0 then table.insert(best,{Id=id,Count=count,Value=C.Value(id,count)*C.Multiplier(levels)}) end
 end
 table.sort(best,function(a,b) if a.Value==b.Value then return a.Id<b.Id end return a.Value>b.Value end)
 local income=0
 for i=1,math.min(C.Slots(levels),#best) do income+=best[i].Value end
 return best,math.floor(income*100+.5)/100
end
return C
