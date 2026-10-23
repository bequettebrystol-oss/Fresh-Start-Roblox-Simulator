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
local rng=Random.new()
local nextBroadcast=workspace:GetServerTimeNow()+90
local broadcastEnd=0
local broadcastBand=1
local closing=false
local function send(p,kind,data) if p.Parent then event:FireClient(p,kind,data) end end
local function notify(p,msg) send(p,"Notice",msg) end
local function state(p)
 local d=profiles[p] if not d or not d.Ready then return end
 local best,income=C.Best(d.Owned)
 send(p,"State",{Money=math.floor(d.Money),Antenna=d.Antenna,Receiver=d.Receiver,Owned=d.Owned,Income=income,Best=best,Plot=d.Plot.Name,Save=d.Save,Ready=true})
end
local function display(p)
 local d=profiles[p] if not d then return end
 local best=C.Best(d.Owned)
 local old=d.Plot:FindFirstChild("Performers") if old then old:Destroy() end
 local folder=Instance.new("Folder") folder.Name="Performers" folder.Parent=d.Plot
 for j=1,3 do
  local anchor=d.Plot:FindFirstChild("Display"..j)
  local entry=best[j]
  anchor.Label.TextLabel.Text=entry and (C.Creatures[entry.Id].Name.."\n$"..math.floor(entry.Value).." / sec") or "EMPTY BOOTH"
  if entry then
   local c=C.Creatures[entry.Id]
   local m=W.Creature(folder,entry.Id,c.Color,c.Shape,anchor.Position)
   m:SetAttribute("Home",anchor.Position) m:SetAttribute("Phase",j*2)
  end
 end
 for j=1,3 do d.Plot["Antenna"..j].Transparency=j<=d.Antenna and 0 or .85 end
end
local function near(p)
 local d=profiles[p] local char=p.Character local root=char and char:FindFirstChild("HumanoidRootPart")
 return d and d.Ready and root and (root.Position-d.Plot.Radio.Position).Magnitude<24
end
local function save(p)
 local d=profiles[p] if not d or not d.Save or d.Saving then return end
 d.Saving=true
 local snapshot={Money=math.floor(d.Money),Antenna=d.Antenna,Receiver=d.Receiver,Owned=table.clone(d.Owned),Session=d.Token,Lease=os.time()+180}
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
 local d={Money=0,Antenna=1,Receiver=1,Owned={},Plot=plot,Save=false,Ready=false,Token=game:GetService("HttpService"):GenerateGUID(false)}
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
   d.Antenna=math.clamp(math.floor(tonumber(result.Antenna) or 1),1,3)
   d.Receiver=math.clamp(math.floor(tonumber(result.Receiver) or 1),1,5)
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
  for j=1,3 do d.Plot["Display"..j].Label.TextLabel.Text="EMPTY BOOTH" end
 end
 profiles[p]=nil sessions[p]=nil rate[p]=nil
end
local function start(p,band,risky)
 local d=profiles[p] if not d or not near(p) then notify(p,"Walk to your radio to tune in.") return end
 if sessions[p] then notify(p,"Finish or close your current signal first.") return end
 if type(band)~="number" or band%1~=0 or band<1 or band>d.Antenna then return end
 risky=risky==true
 local special=workspace:GetServerTimeNow()<broadcastEnd
 local roll=rng:NextNumber(0,100) local total=0 local id
 local weights=risky and {28,34,28,10} or {50,30,16,4}
 if special then weights={20,30,32,18} end
 for i=1,4 do total+=weights[i] if roll<=total then id=(band-1)*4+i break end end
 id=id or band*4
 local now=workspace:GetServerTimeNow()
 local s={Id=id,Start=now,Progress=0,Dial=.5,LastDial=0,Band=band,Risky=risky,Special=special,
  Phase=rng:NextNumber(0,6.28),Speed=(risky and 1.7 or .9)+band*.15,Width=(risky and .10 or .17)+(d.Receiver-1)*.022,LastSend=0}
 sessions[p]=s
 send(p,"Signal",{Start=s.Start,Phase=s.Phase,Speed=s.Speed,Width=s.Width,Risky=risky,Band=band,Special=special})
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
  if a=="Antenna" then
   local cost=C.AntennaCosts[d.Antenna]
   if not cost then notify(p,"Antenna is fully upgraded.") return end
   if d.Money<cost then notify(p,"Need $"..cost.." for the next antenna.") return end
   d.Money-=cost d.Antenna+=1 notify(p,C.Bands[d.Antenna].Name.." unlocked!")
  elseif a=="Receiver" then
   local cost=C.ReceiverCosts[d.Receiver]
   if not cost then notify(p,"Receiver is fully upgraded.") return end
   if d.Money<cost then notify(p,"Need $"..cost.." for the next receiver.") return end
   d.Money-=cost d.Receiver+=1 notify(p,"Receiver upgraded: a wider tuning window!")
  else return end
  display(p) state(p)
 end
end)
for i=1,6 do
 local plot=yard["Station"..i]
 plot.Radio.TunePrompt.Triggered:Connect(function(p)
  local d=profiles[p] if d and d.Plot==plot then send(p,"Open",{}) else notify(p,"This is another player's radio. Find your named station.") end
 end)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(leave)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(join,p) end
local tickIncome=0 local tickSave=0 local tickCapture=0
Run.Heartbeat:Connect(function(dt)
 tickIncome+=dt tickSave+=dt tickCapture+=dt
 local now=workspace:GetServerTimeNow()
 if now>=nextBroadcast then
  broadcastBand=rng:NextInteger(1,3) broadcastEnd=now+45 nextBroadcast=now+180
  event:FireAllClients("Broadcast",{Band=broadcastBand,Ends=broadcastEnd,Next=nextBroadcast})
 end
 if tickCapture>=.1 then
  local step=math.min(tickCapture,.25) tickCapture=0
  for p,s in pairs(sessions) do
   if not near(p) or now-s.Start>35 then sessions[p]=nil send(p,"End","Signal lost. Try another frequency.")
   else
    local target=.5+.34*math.sin((now-s.Start)*s.Speed+s.Phase)
    local locked=now-s.LastDial<.65 and math.abs(s.Dial-target)<=s.Width/2
    s.Progress=math.clamp(s.Progress+(locked and step or -step*.45),0,3.5)
    send(p,"Progress",{Progress=s.Progress,Locked=locked,Id=s.Progress>1.5 and s.Id or nil})
    if s.Progress>=3.5 then
     local d=profiles[p] local key=tostring(s.Id)
     d.Owned[key]=(d.Owned[key] or 0)+1
     d.Money+=C.Creatures[s.Id].Income*3
     sessions[p]=nil display(p) state(p)
     send(p,"Caught",{Id=s.Id,Count=d.Owned[key],Special=s.Special})
    end
   end
  end
 end
 if tickIncome>=1 then
  local elapsed=math.floor(tickIncome) tickIncome-=elapsed
  for p,d in pairs(profiles) do local _,income=C.Best(d.Owned) d.Money=math.min(1e12,d.Money+income*elapsed) state(p) end
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
