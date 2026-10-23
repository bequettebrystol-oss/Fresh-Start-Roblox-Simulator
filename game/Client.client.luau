local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local C=require(RS:WaitForChild("SignalConfig"))
local Creature=require(RS:WaitForChild("SignalCreature"))
local event=RS:WaitForChild("SignalEvent")
local colors={Bg=Color3.fromRGB(14,22,37),Panel=Color3.fromRGB(25,38,57),Muted=Color3.fromRGB(151,170,190),Text=Color3.fromRGB(240,246,245),Teal=Color3.fromRGB(78,238,204),Purple=Color3.fromRGB(182,153,255),Orange=Color3.fromRGB(255,175,118)}
local gui=Instance.new("ScreenGui") gui.Name="SignalHUD" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local function create(class,parent,props)
 local o=Instance.new(class) for k,v in pairs(props or {}) do o[k]=v end o.Parent=parent return o
end
local function corner(o,r) create("UICorner",o,{CornerRadius=UDim.new(0,r or 12)}) end
local function text(parent,str,pos,size,fontSize,color)
 return create("TextLabel",parent,{Text=str,Position=pos,Size=size,Font=Enum.Font.GothamMedium,TextSize=fontSize or 14,TextColor3=color or colors.Text,BackgroundTransparency=1,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left})
end
local function button(parent,str,pos,size,color)
 local b=create("TextButton",parent,{Text=str,Position=pos,Size=size,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=colors.Bg,BackgroundColor3=color or colors.Teal,AutoButtonColor=true}) corner(b,9) return b
end
local function frame(parent,pos,size,color)
 local f=create("Frame",parent,{Position=pos,Size=size,BackgroundColor3=color or colors.Panel,BorderSizePixel=0}) corner(f) return f
end
local header=frame(gui,UDim2.new(0,12,0,10),UDim2.new(1,-24,0,62),colors.Bg)
text(header,"SIGNAL / SIMULATOR",UDim2.fromOffset(14,6),UDim2.new(.58,0,0,23),16,colors.Teal).Font=Enum.Font.GothamBlack
local cash=text(header,"$0  /  $0 per sec",UDim2.fromOffset(14,32),UDim2.new(.65,0,0,21),14)
local collectionButton=button(header,"Collection",UDim2.new(1,-116,0,13),UDim2.fromOffset(104,36),colors.Purple)
local status=text(gui,"Connecting to your station...",UDim2.fromOffset(20,80),UDim2.new(1,-40,0,25),12,colors.Muted)
local eventLabel=text(gui,"",UDim2.fromOffset(20,108),UDim2.new(1,-40,0,28),13,colors.Purple)
local bottom=frame(gui,UDim2.new(.5,0,1,-76),UDim2.new(1,-24,0,60),colors.Bg) bottom.AnchorPoint=Vector2.new(.5,0)
create("UISizeConstraint",bottom,{MaxSize=Vector2.new(760,60)})
local tune=button(bottom,"TUNE RADIO",UDim2.new(0,8,0,9),UDim2.new(.3,-8,0,42))
bottom.Name="Navigation" tune.Name="TuneButton"
local antenna=button(bottom,"Antenna $350",UDim2.new(.3,4,0,9),UDim2.new(.35,-8,0,42),colors.Purple)
local receiver=button(bottom,"Receiver $100",UDim2.new(.65,0,0,9),UDim2.new(.35,-8,0,42),colors.Orange)
antenna.Name="AntennaButton" receiver.Name="ReceiverButton"
local overlay=frame(gui,UDim2.fromScale(.5,.53),UDim2.fromOffset(740,470),colors.Bg) overlay.AnchorPoint=Vector2.new(.5,.5) overlay.Visible=false
overlay.Name="ListeningRoom"
create("UIStroke",overlay,{Color=Color3.fromRGB(68,88,108),Thickness=1})
local title=text(overlay,"THE LISTENING ROOM",UDim2.fromOffset(20,13),UDim2.new(1,-80,0,28),20,colors.Teal) title.Font=Enum.Font.GothamBlack
local close=button(overlay,"X",UDim2.new(1,-49,0,12),UDim2.fromOffset(34,30),colors.Panel) close.TextColor3=colors.Text
close.Name="CloseButton"
local choose=frame(overlay,UDim2.fromOffset(16,55),UDim2.new(1,-32,1,-71),colors.Panel)
choose.Name="Choose"
text(choose,"Choose a frequency band",UDim2.fromOffset(14,8),UDim2.new(1,-28,0,28),16)
local bands={}
local selected=1 local risky=false local profile=nil local signal=nil local dial=.5 local progress=0 local dragging=false local direction=0 local sendAt=0 local receivedId=nil
local function notice(msg)
 status.Text=msg status.TextColor3=colors.Teal
end
for i,b in ipairs(C.Bands) do
 local btn=button(choose,b.Name,UDim2.new((i-1)/3,10,0,50),UDim2.new(1/3,-20,0,62),b.Color) btn.TextSize=12 bands[i]=btn
 btn.Activated:Connect(function()
  if profile and i<=profile.Antenna then selected=i for j,x in ipairs(bands) do x.BackgroundTransparency=j==i and 0 or .6 end
  else notice("Upgrade your antenna to unlock this band.") end
 end)
end
local desc=text(choose,"Clear signals are easy to hold. Faint signals have better rare odds.",UDim2.fromOffset(16,125),UDim2.new(1,-32,0,44),14,colors.Muted)
local mode=button(choose,"SIGNAL: CLEAR / EASY",UDim2.new(0,16,0,185),UDim2.new(1,-32,0,46))
mode.Activated:Connect(function() risky=not risky mode.Text=risky and "SIGNAL: FAINT / RISKY" or "SIGNAL: CLEAR / EASY" mode.BackgroundColor3=risky and colors.Orange or colors.Teal end)
local startButton=button(choose,"SEARCH THE STATIC",UDim2.new(0,16,1,-65),UDim2.new(1,-32,0,46),colors.Purple)
startButton.Name="SearchButton"
startButton.Activated:Connect(function() event:FireServer("Start",selected,risky) end)
local tuning=frame(overlay,UDim2.fromOffset(16,55),UDim2.new(1,-32,1,-71),colors.Panel) tuning.Visible=false
local subtitle=text(tuning,"Follow the moving signal",UDim2.fromOffset(15,7),UDim2.new(1,-30,0,26),15,colors.Muted)
local tuningPreview=create("ViewportFrame",tuning,{Size=UDim2.new(1,-40,0,90),Position=UDim2.fromOffset(20,30),BackgroundTransparency=1,Ambient=Color3.fromRGB(210,210,210)})
local reveal=text(tuning,"? ? ?",UDim2.fromOffset(15,119),UDim2.new(1,-30,0,21),18,colors.Purple) reveal.TextXAlignment=Enum.TextXAlignment.Center reveal.Font=Enum.Font.GothamBlack
local quality=text(tuning,"STATIC",UDim2.fromOffset(15,141),UDim2.new(1,-30,0,18),12,colors.Muted) quality.TextXAlignment=Enum.TextXAlignment.Center
local track=frame(tuning,UDim2.new(0,20,0,163),UDim2.new(1,-40,0,48),colors.Bg)
local zone=frame(track,UDim2.fromScale(.4,0),UDim2.fromScale(.17,1),colors.Teal) zone.BackgroundTransparency=.4
local needle=frame(track,UDim2.new(.5,-2,0,-5),UDim2.new(0,4,1,10),colors.Text) needle.ZIndex=3
local input=create("TextButton",track,{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=5,AutoButtonColor=false})
local bar=frame(tuning,UDim2.new(0,20,0,226),UDim2.new(1,-40,0,10),colors.Bg)
local fill=frame(bar,UDim2.fromScale(0,0),UDim2.fromScale(0,1),colors.Teal)
local help=text(tuning,"Drag the dial • A/D or arrow keys\nHold the white marker inside the glowing zone",UDim2.new(0,20,0,247),UDim2.new(1,-40,0,43),13,colors.Muted)
local left=button(tuning,"<",UDim2.new(0,20,1,-59),UDim2.new(.47,-20,0,44),colors.Purple)
local right=button(tuning,">",UDim2.new(.53,0,1,-59),UDim2.new(.47,-20,0,44),colors.Purple)
local result=frame(overlay,UDim2.fromOffset(16,55),UDim2.new(1,-32,1,-71),colors.Panel) result.Visible=false
local resultTitle=text(result,"SIGNAL CAPTURED",UDim2.fromOffset(16,8),UDim2.new(1,-32,0,25),16,colors.Teal) resultTitle.TextXAlignment=Enum.TextXAlignment.Center
local viewport=create("ViewportFrame",result,{Size=UDim2.new(1,-40,0,170),Position=UDim2.fromOffset(20,36),BackgroundTransparency=1,Ambient=Color3.fromRGB(220,220,220),LightColor=Color3.new(1,1,1)})
local resultName=text(result,"",UDim2.fromOffset(16,207),UDim2.new(1,-32,0,37),23,colors.Text) resultName.TextXAlignment=Enum.TextXAlignment.Center resultName.Font=Enum.Font.GothamBlack
local resultInfo=text(result,"",UDim2.fromOffset(16,247),UDim2.new(1,-32,0,45),13,colors.Muted) resultInfo.TextXAlignment=Enum.TextXAlignment.Center
local again=button(result,"FIND ANOTHER SIGNAL",UDim2.new(0,16,1,-62),UDim2.new(1,-32,0,44))
local library=frame(overlay,UDim2.fromOffset(16,55),UDim2.new(1,-32,1,-71),colors.Panel) library.Visible=false
local scrolling=create("ScrollingFrame",library,{Size=UDim2.new(1,-20,1,-20),Position=UDim2.fromOffset(10,10),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()})
local grid=create("UIGridLayout",scrolling,{CellSize=UDim2.new(.5,-8,0,78),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder})
local cards={}
for id,c in ipairs(C.Creatures) do
 local card=frame(scrolling,UDim2.new(),UDim2.new(),colors.Bg) card.LayoutOrder=id
 local name=text(card,"???",UDim2.fromOffset(10,7),UDim2.new(1,-20,0,29),13,c.Color)
 local info=text(card,C.Bands[c.Band].Name,UDim2.fromOffset(10,38),UDim2.new(1,-20,0,32),11,colors.Muted)
 cards[id]={Name=name,Info=info}
end
local sound=create("Sound",game:GetService("SoundService"),{Name="SignalTone",SoundId="rbxasset://sounds/electronicpingshort.wav",Volume=0,Looped=true})
local function page(which)
 choose.Visible=which=="Choose" tuning.Visible=which=="Tuning" result.Visible=which=="Result" library.Visible=which=="Library"
 title.Text=which=="Library" and "YOUR SIGNAL COLLECTION" or "THE LISTENING ROOM"
 overlay.Visible=true
end
local function stop()
 if signal then event:FireServer("Cancel") end signal=nil progress=0 dragging=false direction=0 sound:Stop()
end
local function open() if not profile then return end if signal then page("Tuning") else page("Choose") end end
close.Activated:Connect(function() stop() overlay.Visible=false end)
tune.Activated:Connect(open)
again.Activated:Connect(function() page("Choose") end)
collectionButton.Activated:Connect(function() stop() page("Library") end)
antenna.Activated:Connect(function() event:FireServer("Upgrade","Antenna") end)
receiver.Activated:Connect(function() event:FireServer("Upgrade","Receiver") end)
local function inputPosition(x)
 dial=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
end
input.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true inputPosition(i.Position.X) end
end)
UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then inputPosition(i.Position.X) end end)
UIS.InputEnded:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false direction=0 end
 if i.KeyCode==Enum.KeyCode.A or i.KeyCode==Enum.KeyCode.D or i.KeyCode==Enum.KeyCode.Left or i.KeyCode==Enum.KeyCode.Right then direction=0 end
end)
UIS.InputBegan:Connect(function(i,processed)
 if processed then return end
 if i.KeyCode==Enum.KeyCode.Escape then stop() overlay.Visible=false end
 if not signal then return end
 if i.KeyCode==Enum.KeyCode.A or i.KeyCode==Enum.KeyCode.Left then direction=-1 end
 if i.KeyCode==Enum.KeyCode.D or i.KeyCode==Enum.KeyCode.Right then direction=1 end
end)
for _,pair in ipairs({{left,-1},{right,1}}) do
 pair[1].InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then direction=pair[2] end end)
end
local function preview(id,target,silhouette)
 target=target or viewport
 target:ClearAllChildren()
 local world=Instance.new("WorldModel") world.Parent=target
 Creature.Build(world,id,Vector3.zero,silhouette)
 local camera=create("Camera",target,{CFrame=CFrame.lookAt(Vector3.new(4,2,-8),Vector3.new(0,.3,0)),FieldOfView=36}) target.CurrentCamera=camera
end
local broadcast={Band=1,Ends=0,Next=0}
event.OnClientEvent:Connect(function(kind,data)
 if kind=="State" then
  profile=data cash.Text="$"..data.Money.."  /  $"..data.Income.." per sec"
  antenna.Text=C.AntennaCosts[data.Antenna] and "Antenna $"..C.AntennaCosts[data.Antenna] or "Antenna MAX"
  receiver.Text=C.ReceiverCosts[data.Receiver] and "Receiver $"..C.ReceiverCosts[data.Receiver] or "Receiver MAX"
  for i,b in ipairs(bands) do b.Text=i<=data.Antenna and C.Bands[i].Name or (C.Bands[i].Name.."\nLOCKED") b.BackgroundTransparency=i==selected and 0 or .6 end
  local total=0
  for id,c in ipairs(C.Creatures) do
   local count=data.Owned[tostring(id)] or 0
   cards[id].Name.Text=count>0 and c.Name or "???"
   cards[id].Info.Text=count>0 and ("$"..math.floor(C.Value(id,count)).." / sec   •   x"..count) or C.Bands[c.Band].Name
   if count>0 then total+=1 end
  end
  collectionButton.Text=total.." / 12"
  if status.Text=="Connecting to your station..." then notice("Your radio is on the desk. Tune in to catch your first brainrot!") end
 elseif kind=="Open" then open()
 elseif kind=="Notice" then notice(data)
 elseif kind=="Signal" then
  signal=data progress=0 dial=.5 receivedId=nil page("Tuning")
  preview(1,tuningPreview,true)
  reveal.Text="? ? ?" reveal.TextColor3=C.Bands[data.Band].Color
  subtitle.Text=C.Bands[data.Band].Name..(data.Special and " / MYSTERY SIGNAL" or data.Risky and " / FAINT SIGNAL" or " / CLEAR SIGNAL")
  sound:Play()
 elseif kind=="Progress" then
  progress=data.Progress fill.Size=UDim2.fromScale(progress/3.5,1)
  if data.Id and receivedId~=data.Id then receivedId=data.Id reveal.Text=C.Creatures[data.Id].Name preview(data.Id,tuningPreview,false) end
 elseif kind=="Caught" then
  stop() page("Result") preview(data.Id)
  local c=C.Creatures[data.Id] resultName.Text=c.Name resultName.TextColor3=c.Color
  resultTitle.Text=data.Count==1 and "NEW SIGNAL DISCOVERED!" or "SIGNAL AMPLIFIED!"
  resultInfo.Text="Base income: $"..c.Income.." / sec  •  Owned: "..data.Count.."\nYour best three automatically go on air. Duplicates amplify income."
  notice("Captured "..c.Name.."! Your strongest signals are now broadcasting.")
 elseif kind=="End" then stop() page("Choose") notice(data)
 elseif kind=="Broadcast" then broadcast=data end
end)
local lastSize=Vector2.zero local animationClock=0 local compact=false
Run.RenderStepped:Connect(function(dt)
 local camera=workspace.CurrentCamera if not camera then return end
 local size=gui.AbsoluteSize
 if size~=lastSize then
  lastSize=size
  compact=size.Y<490
  overlay.Size=UDim2.fromOffset(math.min(740,size.X-24),compact and size.Y-20 or math.min(470,size.Y-154))
  overlay.Position=UDim2.fromScale(.5,compact and .5 or .53)
  if compact then
   title.TextSize=16
   choose.Position=UDim2.fromOffset(12,45) choose.Size=UDim2.new(1,-24,1,-57)
   tuning.Position=choose.Position tuning.Size=choose.Size result.Position=choose.Position result.Size=choose.Size library.Position=choose.Position library.Size=choose.Size
   for _,v in ipairs(choose:GetChildren()) do if v:IsA("TextLabel") and v~=desc then v.Position=UDim2.fromOffset(12,0) v.Size=UDim2.new(1,-24,0,22) v.TextSize=13 end end
   for i,b in ipairs(bands) do b.Position=UDim2.new((i-1)/3,8,0,27) b.Size=UDim2.new(1/3,-16,0,40) end
   desc.Position=UDim2.fromOffset(12,71) desc.Size=UDim2.new(1,-24,0,28) desc.TextSize=12
   mode.Position=UDim2.fromOffset(12,104) mode.Size=UDim2.new(1,-24,0,40)
   startButton.Position=UDim2.new(0,12,1,-52) startButton.Size=UDim2.new(1,-24,0,42)
   subtitle.Position=UDim2.fromOffset(12,0) subtitle.Size=UDim2.new(1,-24,0,20) subtitle.TextSize=12
   tuningPreview.Position=UDim2.fromScale(0,.06) tuningPreview.Size=UDim2.fromScale(1,.23)
   reveal.Position=UDim2.fromScale(0,.28) reveal.Size=UDim2.fromScale(1,.09) reveal.TextSize=16
   quality.Position=UDim2.fromScale(0,.37) quality.Size=UDim2.fromScale(1,.08)
   track.Position=UDim2.new(0,16,.47,0) track.Size=UDim2.new(1,-32,0,40)
   bar.Position=UDim2.new(0,16,.69,0) bar.Size=UDim2.new(1,-32,0,6)
   help.Visible=false
   left.Position=UDim2.new(0,16,1,-48) left.Size=UDim2.new(.47,-16,0,44)
   right.Position=UDim2.new(.53,0,1,-48) right.Size=UDim2.new(.47,-16,0,44)
   viewport.Position=UDim2.fromOffset(20,20) viewport.Size=UDim2.new(1,-40,.39,0)
   resultTitle.Position=UDim2.fromOffset(12,0) resultTitle.TextSize=13
   resultName.Position=UDim2.fromScale(0,.46) resultName.Size=UDim2.fromScale(1,.12) resultName.TextSize=19
   resultInfo.Position=UDim2.new(0,12,.58,0) resultInfo.Size=UDim2.new(1,-24,.20,0) resultInfo.TextSize=11
   again.Position=UDim2.new(0,12,1,-48) again.Size=UDim2.new(1,-24,0,44)
  else
   title.TextSize=20
   for _,p in ipairs({choose,tuning,result,library}) do p.Position=UDim2.fromOffset(16,55) p.Size=UDim2.new(1,-32,1,-71) end
   for _,v in ipairs(choose:GetChildren()) do if v:IsA("TextLabel") and v~=desc then v.Position=UDim2.fromOffset(14,8) v.Size=UDim2.new(1,-28,0,28) v.TextSize=16 end end
   for i,b in ipairs(bands) do b.Position=UDim2.new((i-1)/3,10,0,50) b.Size=UDim2.new(1/3,-20,0,62) end
   desc.Position=UDim2.fromOffset(16,125) desc.Size=UDim2.new(1,-32,0,44) desc.TextSize=14
   mode.Position=UDim2.fromOffset(16,185) mode.Size=UDim2.new(1,-32,0,46)
   startButton.Position=UDim2.new(0,16,1,-65) startButton.Size=UDim2.new(1,-32,0,46)
   subtitle.Position=UDim2.fromOffset(15,7) subtitle.Size=UDim2.new(1,-30,0,26) subtitle.TextSize=15
   tuningPreview.Position=UDim2.fromOffset(20,30) tuningPreview.Size=UDim2.new(1,-40,0,90)
   reveal.Position=UDim2.fromOffset(15,119) reveal.Size=UDim2.new(1,-30,0,21) reveal.TextSize=18
   quality.Position=UDim2.fromOffset(15,141) quality.Size=UDim2.new(1,-30,0,18)
   track.Position=UDim2.fromOffset(20,163) track.Size=UDim2.new(1,-40,0,48)
   bar.Position=UDim2.fromOffset(20,226) bar.Size=UDim2.new(1,-40,0,10)
   help.Visible=true
   left.Position=UDim2.new(0,20,1,-59) left.Size=UDim2.new(.47,-20,0,44)
   right.Position=UDim2.new(.53,0,1,-59) right.Size=UDim2.new(.47,-20,0,44)
   viewport.Position=UDim2.fromOffset(20,36) viewport.Size=UDim2.new(1,-40,0,170)
   resultTitle.Position=UDim2.fromOffset(16,8) resultTitle.TextSize=16
   resultName.Position=UDim2.fromOffset(16,207) resultName.Size=UDim2.new(1,-32,0,37) resultName.TextSize=23
   resultInfo.Position=UDim2.fromOffset(16,247) resultInfo.Size=UDim2.new(1,-32,0,45) resultInfo.TextSize=13
   again.Position=UDim2.new(0,16,1,-62) again.Size=UDim2.new(1,-32,0,44)
  end
 end
 header.Visible=not (compact and overlay.Visible)
 bottom.Visible=not (compact and overlay.Visible)
 status.Visible=not (compact and overlay.Visible)
 eventLabel.Visible=not (compact and overlay.Visible)
 local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
 if touchGui and touchGui:IsA("ScreenGui") then touchGui.Enabled=not overlay.Visible end
 local now=workspace:GetServerTimeNow()
 if broadcast.Ends>now then eventLabel.Text="MYSTERY LIVE  /  ALL BANDS  /  "..math.ceil(broadcast.Ends-now).."s  /  Better rare odds!"
 elseif broadcast.Next>0 then eventLabel.Text="Next mystery broadcast in "..math.max(0,math.ceil(broadcast.Next-now)).."s" end
 if signal then
  dial=math.clamp(dial+direction*dt*.65,0,1)
  local target=.5+.34*math.sin((now-signal.Start)*signal.Speed+signal.Phase)
  zone.Position=UDim2.fromScale(target-signal.Width/2,0) zone.Size=UDim2.fromScale(signal.Width,1)
  needle.Position=UDim2.new(dial,-2,0,-5)
  local locked=math.abs(dial-target)<=signal.Width/2
  zone.BackgroundColor3=locked and colors.Teal or colors.Purple
  local strength=math.clamp(1-math.abs(dial-target)*3,0,1)
  quality.Text=locked and ("LOCKED  /  "..math.floor(progress/3.5*100).."%") or "STATIC  /  Follow the glowing zone"
  quality.TextColor3=locked and colors.Teal or colors.Muted
  if not receivedId then reveal.TextTransparency=.65-strength*.5 end
  sound.Volume=.04+strength*.09 sound.PlaybackSpeed=.65+strength*.65
  sendAt+=dt if sendAt>=.09 then sendAt=0 event:FireServer("Dial",dial) end
 else reveal.TextTransparency=0 end
 animationClock+=dt
 if animationClock>.05 then
  animationClock=0
  local yard=workspace:FindFirstChild("SignalYard")
  if yard and yard:FindFirstChild("EventBeacon") then yard.EventBeacon.Color=broadcast.Ends>now and Color3.fromRGB(195,125+math.sin(now*5)*50,255) or colors.Purple end
  if yard then for _,plot in ipairs(yard:GetChildren()) do
   local performers=plot:FindFirstChild("Performers")
   if performers then for _,m in ipairs(performers:GetChildren()) do
    local home=m:GetAttribute("Home") if home and m.PrimaryPart then m:PivotTo(CFrame.new(home+Vector3.new(0,math.sin(now*2+(m:GetAttribute("Phase") or 0))*.18,0))*CFrame.Angles(0,math.sin(now)*.12,0)) end
   end end
  end end
 end
end)
task.spawn(function()
 for _=1,20 do if profile then break end event:FireServer("Hello") task.wait(1) end
 task.wait(2)
 if profile and not profile.Save then notice("Session-only progress in Studio / when saving is unavailable.") end
end)
