local W={}
local teal=Color3.fromRGB(78,238,204)
local navy=Color3.fromRGB(25,35,56)
local function part(parent,name,size,pos,color,material,shape)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos p.Color=color p.Anchored=true
 p.Material=material or Enum.Material.SmoothPlastic p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=Enum.PartType[shape] end
 p.Parent=parent return p
end
local function label(parent,text,offset,size,color)
 local b=Instance.new("BillboardGui") b.Name="Label" b.Size=UDim2.fromOffset(size or 230,60) b.StudsOffset=offset or Vector3.new(0,3,0) b.AlwaysOnTop=false b.MaxDistance=100 b.Parent=parent
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text t.Font=Enum.Font.GothamBold t.TextSize=17 t.TextColor3=color or Color3.new(1,1,1) t.TextStrokeTransparency=.65 t.Parent=b
 return t
end
function W.Creature(parent,id,color,shape,pos)
 return require(game:GetService("ReplicatedStorage"):WaitForChild("SignalCreature")).Build(parent,id,pos,false)
end
function W.Build()
 local storage=game:GetService("ServerStorage")
 local backup=storage:FindFirstChild("SignalTemplateBackup") or Instance.new("Folder") backup.Name="SignalTemplateBackup" backup.Parent=storage
 for _,name in ipairs({"Baseplate","SpawnLocation"}) do local original=workspace:FindFirstChild(name) if original then original.Parent=backup end end
 local old=workspace:FindFirstChild("SignalYard") if old then old:Destroy() end
 local root=Instance.new("Folder") root.Name="SignalYard" root.Parent=workspace
 part(root,"Island",Vector3.new(200,3,190),Vector3.new(0,-2,0),Color3.fromRGB(50,83,75),Enum.Material.Grass)
 part(root,"MainWalk",Vector3.new(13,.22,160),Vector3.new(0,-.35,0),Color3.fromRGB(115,132,137),Enum.Material.Concrete)
 for _,x in ipairs({-7,7}) do part(root,"WalkLight",Vector3.new(.18,.12,160),Vector3.new(x,-.15,0),teal,Enum.Material.Neon) end
 local sign=part(root,"Welcome",Vector3.new(35,9,1.5),Vector3.new(0,13,-78),navy)
 label(sign,"BRAINROT\nSIGNAL SIMULATOR",Vector3.zero,380,teal)
 for _,x in ipairs({-17,17}) do part(root,"SignPost",Vector3.new(.6,15,.6),Vector3.new(x,6,-78),navy) end
 local beacon=part(root,"EventBeacon",Vector3.new(5,5,5),Vector3.new(0,19,-65),Color3.fromRGB(170,140,255),Enum.Material.Neon,"Ball")
 label(beacon,"MYSTERY BROADCAST\nFollow the purple signal",Vector3.new(0,5,0),300)
 for i=1,6 do
  local col=(i-1)%2 local row=math.floor((i-1)/2)
  local o=Vector3.new(col==0 and -43 or 43,0,-43+row*49)
  local plot=Instance.new("Model") plot.Name="Station"..i plot:SetAttribute("Index",i) plot.Parent=root
  part(plot,"Deck",Vector3.new(54,1,39),o,Color3.fromRGB(66,76,91),Enum.Material.WoodPlanks)
  local accent=({teal,Color3.fromRGB(185,150,255),Color3.fromRGB(255,161,120)})[row+1]
  part(plot,"BackWall",Vector3.new(54,11,1),o+Vector3.new(0,5,19),navy)
  for _,x in ipairs({-26.5,26.5}) do
   part(plot,"Wall",Vector3.new(1,11,24),o+Vector3.new(x,5,7),navy)
   part(plot,"Pillar",Vector3.new(.3,10,.3),o+Vector3.new(x,5,-5),accent,Enum.Material.Neon)
  end
  local roof=part(plot,"Roof",Vector3.new(57,1,28),o+Vector3.new(0,11,7),Color3.fromRGB(64,83,105))
  local fill=Instance.new("PointLight") fill.Color=Color3.fromRGB(196,224,255) fill.Brightness=2 fill.Range=25 fill.Shadows=false fill.Parent=roof
  part(plot,"RoofTrim",Vector3.new(57,.28,.3),o+Vector3.new(0,10.7,-7.2),accent,Enum.Material.Neon)
  for _,wx in ipairs({-12,12}) do part(plot,"Window",Vector3.new(9,4,.15),o+Vector3.new(wx,6,18.4),Color3.fromRGB(82,127,151),Enum.Material.Glass) end
  local title=part(plot,"StationSign",Vector3.new(21,2,.3),o+Vector3.new(-12,9,-7.2),navy)
  label(title,"AVAILABLE STATION",Vector3.zero,260,accent)
  part(plot,"Desk",Vector3.new(10,2.6,4),o+Vector3.new(-15,1.7,-3),Color3.fromRGB(150,113,90),Enum.Material.Wood)
  local radio=part(plot,"Radio",Vector3.new(6,3,2.4),o+Vector3.new(-15,4.3,-3),Color3.fromRGB(240,179,111))
  part(plot,"RadioScreen",Vector3.new(3.2,1.4,.15),radio.Position+Vector3.new(-.6,.2,-1.25),teal,Enum.Material.Neon)
  part(plot,"Dial",Vector3.new(1.1,1.1,.3),radio.Position+Vector3.new(2,0,-1.3),navy,nil,"Ball")
  local prompt=Instance.new("ProximityPrompt") prompt.Name="TunePrompt" prompt.ActionText="Tune signals" prompt.ObjectText="Your radio" prompt.HoldDuration=0 prompt.MaxActivationDistance=14 prompt.RequiresLineOfSight=false prompt.Parent=radio
  label(radio,"TUNE IN\n[E] / Tap",Vector3.new(0,3,0),170,accent)
  local tower=part(plot,"Tower",Vector3.new(.8,18,.8),o+Vector3.new(-21,20,13),Color3.fromRGB(141,155,170))
  for j=1,3 do
   local bar=part(plot,"Antenna"..j,Vector3.new(5+j*2,.25,.25),o+Vector3.new(-21,23+j*2,13),accent,Enum.Material.Neon)
   bar.Transparency=j==1 and 0 or .85
  end
  for j=1,3 do
   local p=o+Vector3.new(0+(j-1)*8,0,7)
   part(plot,"Booth"..j,Vector3.new(7,.5,7),p+Vector3.new(0,.8,0),accent,Enum.Material.Neon)
   part(plot,"BoothPad"..j,Vector3.new(6.6,.3,6.6),p+Vector3.new(0,1.15,0),navy)
   local anchor=part(plot,"Display"..j,Vector3.new(.1,.1,.1),p+Vector3.new(0,3,0),navy) anchor.Transparency=1 anchor.CanCollide=false
   label(anchor,"EMPTY BOOTH",Vector3.new(0,3,0),170,accent)
  end
  local spawn=Instance.new("SpawnLocation") spawn.Name="Arrival" spawn.Size=Vector3.new(6,.3,6) spawn.Position=o+Vector3.new(-15,1,-12) spawn.Anchored=true spawn.Transparency=1 spawn.CanCollide=false spawn.Enabled=false spawn.Parent=plot
  spawn.CFrame=CFrame.new(spawn.Position)*CFrame.Angles(0,math.pi,0)
  task.wait()
 end
 local rng=Random.new(34)
 for i=1,24 do
  local x=(i%2==0 and -1 or 1)*rng:NextNumber(77,93) local z=rng:NextNumber(-85,85)
  part(root,"Trunk",Vector3.new(1.6,7,1.6),Vector3.new(x,2,z),Color3.fromRGB(102,77,68),Enum.Material.Wood)
  part(root,"Canopy",Vector3.new(9,12,9),Vector3.new(x,10,z),Color3.fromRGB(44,rng:NextInteger(100,145),109),nil,"Ball")
 end
 for _,x in ipairs({-96,96}) do
  part(root,"FenceRail",Vector3.new(.5,1.2,180),Vector3.new(x,3,0),Color3.fromRGB(120,142,137),Enum.Material.Wood)
  for z=-85,85,10 do part(root,"FencePost",Vector3.new(1,5,1),Vector3.new(x,1.5,z),Color3.fromRGB(120,142,137),Enum.Material.Wood) end
 end
 for z=-60,70,26 do for _,x in ipairs({-10,10}) do
  part(root,"LampPost",Vector3.new(.5,6,.5),Vector3.new(x,2.5,z),navy)
  local lamp=part(root,"Lamp",Vector3.new(1.3,1.3,1.3),Vector3.new(x,6,z),Color3.fromRGB(255,215,153),Enum.Material.Neon,"Ball")
  local l=Instance.new("PointLight") l.Color=lamp.Color l.Range=18 l.Brightness=1.5 l.Parent=lamp
 end end
 local light=game:GetService("Lighting") light.ClockTime=17.5 light.Brightness=2.5 light.Ambient=Color3.fromRGB(139,152,182) light.OutdoorAmbient=Color3.fromRGB(144,163,184)
 local atmosphere=light:FindFirstChild("SignalAtmosphere") or Instance.new("Atmosphere") atmosphere.Name="SignalAtmosphere" atmosphere.Density=.24 atmosphere.Color=Color3.fromRGB(168,185,219) atmosphere.Parent=light
 return root
end
return W
