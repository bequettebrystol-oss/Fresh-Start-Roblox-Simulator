local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local DSS=game:GetService("DataStoreService")
local C=require(RS:WaitForChild("SignalConfig"))
local W=require(script.Parent:WaitForChild("SignalWorld"))
local yard=workspace:FindFirstChild("SignalYard") or W.Build()
local event=RS:FindFirstChild("SignalEvent") or Instance.new("RemoteEvent") event.Name="SignalEvent" event.Parent=RS
local store=DSS:GetDataStore("BrainrotSignal_v1")
local profiles={} local claims={} local sessions={} local rate={}
local floorDebounce={} local floorOccupants={}
local rng=Random.new()
local nextBroadcast=workspace:GetServerTimeNow()+90
local broadcastEnd=0
local broadcastBand=1
local closing=false
local function send(p,kind,data) if p.Parent then event:FireClient(p,kind,data) end end
local function notify(p,msg) send(p,"Notice",msg) end
local function state(p)
 local d=profiles[p] if not d or not d.Ready then return end
 local best,income=C.Best(d.Owned,d)
 send(p,"State",{Money=math.floor(d.Money*100+.5)/100,Antenna=d.Antenna,Receiver=d.Receiver,Floors=d.Floors,Upgrades=C.Levels(d),Slots=C.Slots(d),Owned=d.Owned,Income=income,Best=best,Plot=d.Plot.Name,Save=d.Save,Ready=true})
end
local function display(p,animate)
 local d=profiles[p] if not d then return end
 W.SetFloor(d.Plot,d.Floors,animate)
 local best=C.Best(d.Owned,d)
 local old=d.Plot:FindFirstChild("Performers") if old then old:Destroy() end
 local folder=Instance.new("Folder") folder.Name="Performers" folder.Parent=d.Plot
 local slots=C.Slots(d)
 local rank=0
 for j=1,12 do
  local anchor=d.Plot:FindFirstChild("Display"..j)
  local active=C.SlotActive(d,j) local visible=j<=6 or d.Floors>=2
  if active then rank+=1 end
  local entry=active and best[rank] or nil
  anchor.Label.Enabled=visible
  anchor.Label.TextLabel.Text=entry and (C.Creatures[entry.Id].Name.."\n$"..C.Money(entry.Value).." / sec") or ("BOOTH "..j..(active and "\nEMPTY" or "\nLOCKED"))
  d.Plot["Booth"..j].Transparency=not visible and 1 or active and 0 or .8
  d.Plot["Booth"..j].CanCollide=visible
  d.Plot["BoothPad"..j].Transparency=visible and 0 or 1 d.Plot["BoothPad"..j].CanCollide=visible
  if entry then
   local c=C.Creatures[entry.Id]
   local m=W.Creature(folder,entry.Id,c.Color,c.Shape,anchor.Position)
   m:SetAttribute("Home",anchor.Position) m:SetAttribute("Phase",j*2)
  end
 end
 for j=1,3 do d.Plot["Antenna"..j].Transparency=j<=d.Antenna and 0 or .85 end
 for j=1,5 do d.Plot["Amplifier"..j].Transparency=j<d.Amplifier and 0 or .85 end
 d.Plot.StabilizerCoil.Transparency=.7-(d.Stabilizer-1)*.15
 d.Plot.DecoderCore.Transparency=.7-(d.Decoder-1)*.15
 d.Plot.ReceiverRack.Size=Vector3.new(3,3+(d.Receiver-1)*.3,3)
 for _,u in ipairs(C.Upgrades) do d.Plot:SetAttribute(u.Key,d[u.Key]) end
 d.Plot:SetAttribute("ActiveBooths",slots)
 d.Plot:SetAttribute("Floors",d.Floors)
 W.UpdatePads(d.Plot,d)
end
local function near(p)
 local d=profiles[p] local char=p.Character local root=char and char:FindFirstChild("HumanoidRootPart")
 return d and d.Ready and root and (root.Position-d.Plot.Radio.Position).Magnitude<24
end
local function save(p)
 local d=profiles[p] if not d or not d.Save or d.Saving then return end
 d.Saving=true
 local snapshot={Money=math.floor(d.Money*100+.5)/100,Floors=d.Floors,Antenna=d.Antenna,Receiver=d.Receiver,Owned=table.clone(d.Owned),Session=d.Token,Lease=os.time()+180}
 for _,u in ipairs(C.Upgrades) do snapshot[u.Key]=d[u.Key] end
 local ok,result=pcall(function()
  return store:UpdateAsync("u"..p.UserId,function(previous)
   if previous and previous.Session~=d.Token then return nil end
   return snapshot
  end)
 end)
 d.Saving=false
 if not ok then warn("Signal save failed",p.UserId,result) notify(p,"Saving is delayed. Keep this session open.")
 elseif not result then d.Save=false notify(p,"This station's save session changed. Rejoin before making more progress.") end
end
local function arrival(p,d,char)
 local root=char:WaitForChild("HumanoidRootPart",10)
 if root then char:PivotTo(d.Plot.Arrival.CFrame+Vector3.new(0,4,0)) end
end
local function join(p)
 if profiles[p] then return end
 local plot
 for i=1,6 do if not claims[i] then claims[i]=p plot=yard["Station"..i] break end end
 if not plot then p:Kick("All six stations are occupied. Please join another server.") return end
 local d={Money=0,Floors=1,Antenna=1,Receiver=1,Owned={},Plot=plot,Save=false,Ready=false,Token=game:GetService("HttpService"):GenerateGUID(false)}
 for key,value in pairs(C.Levels({})) do d[key]=value end
 profiles[p]=d
 if not Run:IsStudio() then
  local ok,result=pcall(function()
   return store:UpdateAsync("u"..p.UserId,function(old)
    if old and old.Session and (old.Lease or 0)>os.time() then return nil end
    old=old or {Money=0,Antenna=1,Receiver=1,Owned={}}
    old.Session=d.Token old.Lease=os.time()+180 return old
   end)
  end)
  if ok and result and result.Session==d.Token then
   d.Money=math.clamp(tonumber(result.Money) or 0,0,1e12)
   d.Floors=C.FloorLevel(result)
   for key,value in pairs(C.Levels(result)) do d[key]=value end
   for key,count in pairs(type(result.Owned)=="table" and result.Owned or {}) do
    local id=tonumber(key)
    if id and C.Creatures[id] and type(count)=="number" and count==count then d.Owned[tostring(id)]=math.clamp(math.floor(count),1,100000) end
   end
   d.Save=true
  elseif ok and not result then
   claims[plot:GetAttribute("Index")]=nil profiles[p]=nil
   p:Kick("Your station is still open in another server. Try again in a few minutes.") return
  else warn("Signal data load failed",p.UserId) end
 end
 if not p.Parent then claims[plot:GetAttribute("Index")]=nil profiles[p]=nil return end
 d.Ready=true
 plot:SetAttribute("Owner",p.UserId)
 plot.StationSign.Label.TextLabel.Text=p.DisplayName.."'s STATION"
 plot.Radio.TunePrompt.ObjectText=p.DisplayName.."'s radio"
 p.CharacterAdded:Connect(function(char) arrival(p,d,char) end)
 if p.Character then task.spawn(arrival,p,d,p.Character) end
 display(p) state(p)
end
local function leave(p)
 local d=profiles[p]
 if d then
  if d.Removing then return end
  d.Removing=true
  while d.Saving do task.wait(.1) end
  save(p)
  if d.Save then
   pcall(function() store:UpdateAsync("u"..p.UserId,function(old) if old and old.Session==d.Token then old.Session=nil old.Lease=0 return old end return nil end) end)
  end
  claims[d.Plot:GetAttribute("Index")]=nil
  d.Plot:SetAttribute("Owner",nil)
  d.Plot.StationSign.Label.TextLabel.Text="AVAILABLE STATION"
  local performers=d.Plot:FindFirstChild("Performers") if performers then performers:Destroy() end
  W.SetFloor(d.Plot,1)
  for j=1,12 do
   d.Plot["Display"..j].Label.TextLabel.Text="BOOTH "..j..(j<=3 and "\nEMPTY" or "\nLOCKED")
   d.Plot["Display"..j].Label.Enabled=j<=6
   d.Plot["Booth"..j].Transparency=j<=3 and 0 or j<=6 and .8 or 1
   d.Plot["BoothPad"..j].Transparency=j<=6 and 0 or 1
   d.Plot["Booth"..j].CanCollide=j<=6 d.Plot["BoothPad"..j].CanCollide=j<=6
  end
  W.UpdatePads(d.Plot,{Floors=1,Money=0})
 end
 profiles[p]=nil sessions[p]=nil rate[p]=nil floorDebounce[p]=nil floorOccupants[p]=nil
end
local function buyFloor(p,plot,index,pad)
 local d=profiles[p]
 if not d or not d.Ready or d.Removing or (floorDebounce[p] or 0)>os.clock() then return end
 floorDebounce[p]=os.clock()+1.5
 if d.Plot~=plot then notify(p,"This building pad belongs to another station.") return end
 if d.Floors~=index then return end
 local char=p.Character local root=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 then return end
 local delta=root.Position-pad.Position
 if math.abs(delta.Y)>5 or Vector2.new(delta.X,delta.Z).Magnitude>5.5 then return end
 if sessions[p] then notify(p,"Close your current signal before using a building pad.") return end
 local cost=C.FloorCosts[index]
 if d.Money<cost then notify(p,"Need $"..C.Money(cost-d.Money).." more for this building pad.") return end
 d.Money-=cost d.Floors+=1
 display(p,true) state(p)
 send(p,"FloorBuilt",{Level=d.Floors,Slots=C.Slots(d),Cost=cost})
 task.spawn(save,p)
end
local function start(p,band,risky)
 local d=profiles[p] if not d or not near(p) then notify(p,"Walk to your radio to tune in.") return end
 if sessions[p] then notify(p,"Finish or close your current signal first.") return end
 if type(band)~="number" or band%1~=0 or band<1 or band>d.Antenna then return end
 risky=risky==true
 local special=workspace:GetServerTimeNow()<broadcastEnd
 local roll=rng:NextNumber(0,100) local total=0 local id
 local weights=risky and {28,34,28,10} or {50,30,16,4}
 if special then weights=risky and {18,28,32,22} or {30,32,26,12} end
 for i=1,4 do total+=weights[i] if roll<=total then id=(band-1)*4+i break end end
 id=id or band*4
 local now=workspace:GetServerTimeNow()
 local s=C.SignalStats(d,band,risky)
 s.Id=id s.Start=now s.Progress=0 s.Dial=.5 s.LastDial=0 s.Band=band s.Risky=risky s.Special=special
 s.Phase=rng:NextNumber(0,6.28) s.Missed=0 s.PerfectTime=0 s.LockTime=0
 local pingOK,ping=pcall(function() return p:GetNetworkPing() end)
 s.Ping=pingOK and math.clamp(ping,0,.18) or 0
 sessions[p]=s
 send(p,"Signal",{Start=s.Start,Phase=s.Phase,Speed=s.Speed,Width=s.Width,Amplitude=s.Amplitude,Required=s.Required,Grace=s.Grace,Duration=s.Duration,Risky=risky,Band=band,Special=special})
end
event.OnServerEvent:Connect(function(p,command,a,b)
 if type(command)~="string" or not profiles[p] or not profiles[p].Ready or profiles[p].Removing then return end
 local now=os.clock() local r=rate[p] or {Time=now,Count=0} rate[p]=r
 if now-r.Time>=1 then r.Time=now r.Count=0 end
 r.Count+=1 if r.Count>35 then return end
 local d=profiles[p]
 if command=="Hello" then state(p) send(p,"Broadcast",{Band=broadcastBand,Ends=broadcastEnd,Next=nextBroadcast})
 elseif command=="Start" then start(p,a,b)
 elseif command=="Dial" then
  local s=sessions[p]
  if s and type(a)=="number" and a==a and a>=0 and a<=1 then s.Dial=a s.LastDial=workspace:GetServerTimeNow() end
 elseif command=="Cancel" then sessions[p]=nil
 elseif command=="Upgrade" and not sessions[p] then
  local upgrade
  for _,u in ipairs(C.Upgrades) do if u.Key==a then upgrade=u break end end
  if not upgrade then return end
  local level=d[upgrade.Key] local cost=upgrade.Costs[level]
  if not cost then notify(p,upgrade.Name.." is fully upgraded.") return end
  if d.Money<cost then notify(p,"Need $"..cost.." for "..upgrade.Name..".") return end
  d.Money-=cost d[upgrade.Key]+=1 notify(p,upgrade.Name.." upgraded! "..C.Description(upgrade.Key,d[upgrade.Key]))
  display(p) state(p)
 elseif command=="Upgrade" then notify(p,"Finish or close your current signal before upgrading.")
 end
end)
for i=1,6 do
 local plot=yard["Station"..i]
 plot.Radio.TunePrompt.Triggered:Connect(function(p)
  local d=profiles[p] if d and d.Plot==plot then send(p,"Open",{}) else notify(p,"This is another player's radio. Find your named station.") end
 end)
 plot.ReceiverRack.UpgradePrompt.Triggered:Connect(function(p)
  local d=profiles[p] if d and d.Plot==plot then send(p,"OpenUpgrades",{}) else notify(p,"Use the workbench in your station.") end
 end)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(leave)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(join,p) end
local tickIncome=0 local tickSave=0 local tickCapture=0 local tickPads=0
Run.Heartbeat:Connect(function(dt)
 tickIncome+=dt tickSave+=dt tickCapture+=dt tickPads+=dt
 local now=workspace:GetServerTimeNow()
 if now>=nextBroadcast then
  broadcastBand=rng:NextInteger(1,3) broadcastEnd=now+45 nextBroadcast=now+180
  event:FireAllClients("Broadcast",{Band=broadcastBand,Ends=broadcastEnd,Next=nextBroadcast})
 end
 if tickPads>=.15 then
  tickPads=0
  for p,d in pairs(profiles) do
   local stage=d.Floors local char=p.Character local root=char and char:FindFirstChild("HumanoidRootPart")
   local pad=stage<=2 and d.Plot[stage==1 and "FloorPad" or "ExpansionPad"] or nil
   local delta=root and pad and root.Position-pad.Position
   local inside=delta and math.abs(delta.Y)<=5 and Vector2.new(delta.X,delta.Z).Magnitude<=5.5
   if inside then
    if floorOccupants[p]~=stage then floorOccupants[p]=stage buyFloor(p,d.Plot,stage,pad) end
   else floorOccupants[p]=nil end
  end
 end
 if tickCapture>=.1 then
  local step=math.min(tickCapture,.25) tickCapture=0
  for p,s in pairs(sessions) do
   if not near(p) or now-s.Start>s.Duration then sessions[p]=nil send(p,"End","Signal lost. Try another frequency.")
   else
    local target=C.Target(s,now-s.Ping)
    local distance=math.abs(s.Dial-target)
    local locked=now-s.LastDial<.6 and distance<=s.Width/2
    local perfect=locked and distance<=s.Width*.22
    s.Missed=locked and 0 or s.Missed+step
    if now-s.Start>=.75 then
     if locked then s.LockTime+=step if perfect then s.PerfectTime+=step end end
     s.Progress=math.clamp(s.Progress+(locked and step*(perfect and C.PerfectSpeed or 1) or s.Missed>s.Grace and -step*.30 or 0),0,s.Required)
    end
    send(p,"Progress",{Progress=s.Progress,Locked=locked,Perfect=perfect,Holding=not locked and s.Missed<=s.Grace,Id=s.Progress>s.Required*.4 and s.Id or nil})
    if s.Progress>=s.Required then
     local d=profiles[p] local key=tostring(s.Id)
     d.Owned[key]=(d.Owned[key] or 0)+1
     local perfectCatch=s.PerfectTime/math.max(.01,s.LockTime)>=.6
     local reward=C.CaptureReward(s.Id,perfectCatch)
     d.Money+=reward
     sessions[p]=nil display(p) state(p)
     send(p,"Caught",{Id=s.Id,Count=d.Owned[key],Special=s.Special,Perfect=perfectCatch,Reward=reward})
    end
   end
  end
 end
 if tickIncome>=1 then
  local elapsed=math.floor(tickIncome) tickIncome-=elapsed
  for p,d in pairs(profiles) do local _,income=C.Best(d.Owned,d) d.Money=math.min(1e12,d.Money+income*elapsed) W.UpdatePads(d.Plot,d) state(p) end
 end
 if tickSave>=60 then tickSave=0 for p,d in pairs(profiles) do if not d.Removing then task.spawn(save,p) end end end
end)
game:BindToClose(function()
 if closing then return end closing=true
 local remaining=0
 for p in pairs(profiles) do remaining+=1 task.spawn(function() leave(p) remaining-=1 end) end
 local deadline=os.clock()+25
 while remaining>0 and os.clock()<deadline do task.wait(.1) end
end)
