-- Read-only balance checks. Run in Studio's Command Bar after installing the game.
local C=require(game:GetService("ReplicatedStorage"):WaitForChild("SignalConfig"))
local maximum={Floors=3}
local totalCost=0
local purchases=0
for _,upgrade in ipairs(C.Upgrades) do
 maximum[upgrade.Key]=#upgrade.Costs+1
 for _,cost in ipairs(upgrade.Costs) do assert(cost>0) totalCost+=cost purchases+=1 end
end
for _,cost in ipairs(C.FloorCosts) do assert(cost>0) totalCost+=cost purchases+=1 end
local owned={}
local maxReward=0
for id=1,#C.Creatures do owned[tostring(id)]=10 maxReward=math.max(maxReward,C.CaptureReward(id,true)) end
local _,maximumIncome=C.Best(owned,maximum)
local minimumCapture=.75+C.Required(maximum.Decoder,1,false)/C.PerfectSpeed
local boundMinutes=totalCost/(maximumIncome+maxReward/minimumCapture)/60
local _,starterIncome=C.Best({["1"]=1},C.Levels({}))
assert(starterIncome==.25,"Starter income must retain fractional earnings")
assert(C.Slots(maximum)==12,"Full station should have twelve slots")
assert(C.Slots({Booths=1,Floors=2})==6,"Floor purchase must add actual upstairs slots")
assert(not C.SlotActive({Booths=1,Floors=2},4) and C.SlotActive({Booths=1,Floors=2},7),"Upstairs must not unlock ground slots")
assert(C.FloorLevel({})==1,"Legacy profiles must start with an unbuilt upstairs")
assert(minimumCapture>6 and maximumIncome<110 and boundMinutes>45,"Economy is faster than the current balance target")
return {
 TotalPurchaseCost=totalCost,
 Purchases=purchases,
 StarterIncomePerSecond=starterIncome,
 MaximumIncomePerSecond=maximumIncome,
 MinimumPossibleCaptureSeconds=minimumCapture,
 OptimisticFreshStartAccountingBoundMinutes=boundMinutes,
 Note="Accounting bound assumes instant maximum income and the best cash reward every shortest capture. It is not a measured full playthrough. Existing balances are excluded.",
}
