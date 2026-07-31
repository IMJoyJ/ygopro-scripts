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
	-- 开启卡片的灵摆属性与灵摆召唤/放置逻辑。
	aux.EnablePendulumAttribute(c)
	-- ● 诱发效果（连锁注册）：魔法发动检测
在灵摆区域或怪兽区域存在，当有效果连锁发动时注册连锁标记（配合魔力指示物放置）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	-- 连锁注册辅助处理：在连锁发动时打上标记。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ● 诱发效果（放置指示物）：魔法卡发动成功时放置魔力指示物
每次自己或对方把魔法卡发动，在这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	e3:SetOperation(c10239627.acop)
	c:RegisterEffect(e3)
	-- ● 效果①（灵摆效果）：检索灵摆怪兽
1回合1次，把这张卡3个魔力指示物取除才能发动。从卡组把1只灵摆怪兽加入手牌。
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
	-- ● 效果②（怪兽效果）：攻击力上升
这张卡的攻击力上升这张卡的魔力指示物数量×100。
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
-- 当魔法卡发动处理完毕且存在连锁标记时，为这张卡添加1个魔力指示物。
function c10239627.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- Cost：取除这张卡的3个魔力指示物。
function c10239627.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 筛选卡组中可加入手牌的灵摆怪兽。
function c10239627.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果检索的目标确认与操作信息设定。
function c10239627.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果检索的具体处理：从卡组把1只灵摆怪兽加入手牌。
function c10239627.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选卡组中可加入手牌的魔法师族·1星怪兽。
function c10239627.thfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 怪兽效果检索的目标确认与操作信息设定。
function c10239627.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的魔法师族·1星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果检索的具体处理：从卡组把1只魔法师族·1星怪兽加入手牌。
function c10239627.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的魔法师族·1星怪兽。
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 计算攻击力上升数值（指示物数量×100）。
function c10239627.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*100
end
