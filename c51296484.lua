--粛声の竜賢姫サフィラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张仪式魔法卡送去墓地。那之后，可以把1只战士族·龙族而光属性的仪式怪兽从自己的卡组·墓地加入手卡。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册两个效果，分别为①和②效果，①为手牌发动的起动效果，②为墓地发动的仪式召唤效果
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张仪式魔法卡送去墓地。那之后，可以把1只战士族·龙族而光属性的仪式怪兽从自己的卡组·墓地加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tscost)
	e1:SetTarget(s.tstg)
	e1:SetOperation(s.tsop)
	c:RegisterEffect(e1)
	-- 为仪式魔法卡注册等级合计满足条件的仪式召唤程序，用于②效果的发动条件
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为将此卡除外
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价函数，检查是否可以丢弃此卡作为代价
function s.tscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 执行将此卡送去墓地的操作，作为①效果的发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 筛选满足条件的仪式魔法卡（类型为仪式魔法卡且能送去墓地）
function s.tsfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- ①效果的发动宣言阶段，检查是否卡组存在满足条件的仪式魔法卡并设置操作信息
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tsfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 筛选满足条件的战士族·龙族而光属性的仪式怪兽（可加入手牌）
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- ①效果的发动处理阶段，选择一张仪式魔法卡送去墓地，并询问是否将符合条件的仪式怪兽加入手牌
function s.tsop(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家选择要送去墓地的仪式魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,s.tsfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认所选卡片成功送去墓地且位于墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查自己卡组或墓地中是否存在满足条件的仪式怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
		-- 询问玩家是否将符合条件的仪式怪兽加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把仪式怪兽加入手卡？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组或墓地中选择1张满足条件的仪式怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		-- 将选中的仪式怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认所选加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 用于筛选可作为仪式召唤祭品的战士族·龙族而光属性的仪式怪兽
function s.filter(c,e,tp,chk)
	return c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and (not chk or c~=e:GetHandler())
end
