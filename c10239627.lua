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
	-- 为怪兽卡设置灵摆属性（注册灵摆召唤以及在灵摆区域的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。/①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	-- 设置操作函数为记录连锁信息（用于在连锁处理结束时确认此卡是否仍表侧表示存在）
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在灵摆区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。/①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	e3:SetOperation(c10239627.acop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，把这张卡3个魔力指示物取除才能发动。从卡组把1只灵摆怪兽加入手卡。
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
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×100。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(c10239627.atkval)
	c:RegisterEffect(e6)
end
-- 放置指示物效果的效果处理：若发动的是魔法卡且连锁发生时此卡在场上存在，给此卡放置1个魔力指示物
function c10239627.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检索效果的代价：取除此卡的3个魔力指示物
function c10239627.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 检索灵摆怪兽的过滤条件：是灵摆怪兽且可以加入手卡
function c10239627.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检索灵摆怪兽效果的靶指向与发动条件：检查卡组是否存在满足条件的卡，并设置连锁操作信息为将卡片加入手卡
function c10239627.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张可以加入手卡的灵摆怪兽并返回结果
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索灵摆怪兽效果的效果处理：从卡组选择1只灵摆怪兽加入手卡，并给对方确认
function c10239627.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索魔法师族·1星怪兽的过滤条件：是魔法师族、1星且可以加入手卡
function c10239627.thfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 检索魔法师族·1星怪兽效果的靶指向与发动条件：检查卡组是否存在满足条件的卡，并设置连锁操作信息为将卡片加入手卡
function c10239627.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张可以加入手卡的魔法师族·1星怪兽并返回结果
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索魔法师族·1星怪兽效果的效果处理：从卡组选择1只魔法师族·1星怪兽加入手卡，并给对方确认
function c10239627.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升值的计算函数：返回此卡上的魔力指示物数量×100的值
function c10239627.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*100
end
