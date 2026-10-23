local C=require(script.Parent:WaitForChild("SignalConfig"))
local M={}
function M.Build(parent,id,pos,silhouette)
 local c=C.Creatures[id] local m=Instance.new("Model") m.Name="Performer" m:SetAttribute("CreatureId",id)
 local dark=Color3.fromRGB(25,35,56) local mint=Color3.fromRGB(78,238,204)
 local function p(name,size,offset,color,shape,neon)
  local x=Instance.new("Part") x.Name=name x.Size=size x.Position=pos+offset x.Color=silhouette and Color3.fromRGB(8,12,24) or color
  x.Anchored=true x.CanCollide=false x.Material=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
  if shape then x.Shape=Enum.PartType[shape] end x.Parent=m return x
 end
 local bodySize=(id==5 and Vector3.new(1.6,3.2,1.6)) or (id==9 and Vector3.new(1.8,3.1,1.8)) or Vector3.new(2.5,2.7,2)
 local body=p("Body",bodySize,Vector3.zero,c.Color,c.Shape)
 for _,x in ipairs({-.57,.57}) do
  p("Eye",Vector3.new(.66,.78,.23),Vector3.new(x,.4,-1),Color3.fromRGB(250,250,242),"Ball")
  p("Pupil",Vector3.new(.27,.38,.15),Vector3.new(x,.36,-1.14),dark,"Ball")
  p("Foot",Vector3.new(.8,.45,1.15),Vector3.new(x,-1.3,-.1),dark)
 end
 p("Mouth",Vector3.new(.6,.16,.16),Vector3.new(0,-.38,-1.13),dark)
 p("Aerial",Vector3.new(.16,.8,.16),Vector3.new(0,1.7,0),dark)
 p("SignalTip",Vector3.new(.4,.4,.4),Vector3.new(0,2.2,0),mint,"Ball",true)
 if id==2 then
  p("ToastCrust",Vector3.new(2.9,.45,2.2),Vector3.new(0,1.3,0),Color3.fromRGB(166,91,51))
  p("Butter",Vector3.new(.8,.22,.7),Vector3.new(.45,1.63,-.3),Color3.fromRGB(255,239,147))
 elseif id==3 then
  for _,x in ipairs({-1.6,1.6}) do p("WobbleEar",Vector3.new(1.1,.6,.9),Vector3.new(x,.4,0),c.Color,"Ball") end
 elseif id==4 then
  p("HatBrim",Vector3.new(3,.18,2.5),Vector3.new(0,1.45,0),dark)
  p("TopHat",Vector3.new(1.8,1.2,1.7),Vector3.new(0,2.05,0),dark)
  p("HatBand",Vector3.new(1.85,.22,1.75),Vector3.new(0,1.66,0),mint,nil,true)
 elseif id==5 then
  for j=1,3 do p("NoodleTail",Vector3.new(1,.6,1),Vector3.new(1.2+j*.45,-.8+math.sin(j)*.5,.2),c.Color,"Ball") end
 elseif id==6 then
  for j=1,8 do local a=j*math.pi/4 p("DiscoSpark",Vector3.new(.36,.36,.36),Vector3.new(math.cos(a)*1.5,math.sin(a)*1.5,0),j%2==0 and mint or Color3.fromRGB(255,220,110),nil,true) end
 elseif id==7 then
  for j=1,5 do p("Crumb",Vector3.new(.5,.5,.5),Vector3.new((j%3-1)*.65,.7-(j%2)*1.3,-1.1),dark) end
 elseif id==8 then
  p("GoggleBar",Vector3.new(2.7,.18,.3),Vector3.new(0,.65,-1.25),dark)
  p("ProfessorCap",Vector3.new(3,.2,2.6),Vector3.new(0,1.5,0),Color3.fromRGB(115,92,197))
 elseif id==9 then
  for j=1,6 do p("PickleBump",Vector3.new(.35,.35,.35),Vector3.new(j%2==0 and -.9 or .9,-1+j*.35,0),Color3.fromRGB(99,177,66),"Ball") end
 elseif id==10 then
  for _,x in ipairs({-1.3,1.3}) do p("GlitchEar",Vector3.new(.7,1,.7),Vector3.new(x,1.4,0),mint,nil,true) end
 elseif id==11 then
  for j=1,12 do local a=j*math.pi/6 p("Orbit",Vector3.new(.35,.35,.35),Vector3.new(math.cos(a)*2,.2+math.sin(a)*.6,math.sin(a)*1.4),Color3.fromRGB(255,223,139),"Ball",true) end
 elseif id==12 then
  for j=1,5 do p("BrainLobe",Vector3.new(.9,.8,.9),Vector3.new((j-3)*.45,1.1+math.sin(j)*.15,0),Color3.fromRGB(255,157,199),"Ball") end
  p("Crown",Vector3.new(1,.3,1),Vector3.new(0,2.15,0),Color3.fromRGB(255,223,98),nil,true)
 end
 m.PrimaryPart=body m.Parent=parent return m
end
return M
