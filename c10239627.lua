--マジカル・アブダクター
-- 效果：
-- ←3 【灵摆】 3→
-- ①：只要这张卡在灵摆区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：1回合1次，把这张卡3个魔力指示物取除才能发动。从卡组把1只灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×100。
-- ③：1回合1次，把这张卡3个魔力指示物取除才能发动。从卡组把1只魔法师族·1星怪兽加入手卡。
function c10239627.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤及作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- 只要这张卡在灵摆区域（或怪兽区域）存在，每次自己或者对方把魔法卡发动——此为记录魔法卡发动时这张卡已在场上的辅助效果（对应灵摆①与怪兽①的共同前提）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	-- 当连锁发生时记录这张卡已在场上存在，作为后续判断是否放置魔力指示物的依据
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	e3:SetOperation(c10239627.acop)
	c:RegisterEffect(e3)
	-- 1回合1次，把这张卡3个魔力指示物取除才能发动。从卡组把1只灵摆怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c10239627.thcost)
	e4:SetTarget(c10239627.thtg1)
	e4:SetOperation(c10239627.thop1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c10239627.thtg2)
	e5:SetOperation(c10239627.thop2)
	c:RegisterEffect(e5)
	-- 这张卡的攻击力上升这张卡的魔力指示物数量×100
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(c10239627.atkval)
	c:RegisterEffect(e6)
end
c10239627.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若该连锁发动的是魔法卡的卡的发动且这张卡在连锁发生时已在场上存在，则给这张卡放置1个魔力指示物
function c10239627.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 作为发动代价，取除这张卡的3个魔力指示物
function c10239627.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 检索用的过滤条件：可以加入手卡的灵摆怪兽
function c10239627.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 发动条件检测：确认卡组存在可加入手卡的灵摆怪兽，并设置卡组检索加入手卡的操作信息
function c10239627.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只可以加入手卡的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡（卡组检索），供其他效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让自己从卡组选择1只灵摆怪兽加入手卡，并让对方确认那张卡
function c10239627.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的卡以效果处理送去持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）加入手卡的那张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索用的过滤条件：可以加入手卡的魔法师族·1星怪兽
function c10239627.thfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 发动条件检测：确认卡组存在可加入手卡的魔法师族·1星怪兽，并设置卡组检索加入手卡的操作信息
function c10239627.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只可以加入手卡的魔法师族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡（卡组检索），供其他效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让自己从卡组选择1只魔法师族·1星怪兽加入手卡，并让对方确认那张卡
function c10239627.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1只满足条件的魔法师族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的卡以效果处理送去持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）加入手卡的那张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 计算攻击力上升值：返回这张卡的魔力指示物数量×100
function c10239627.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*100
end
