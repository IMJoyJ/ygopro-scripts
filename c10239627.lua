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
	-- 为灵摆怪兽启用灵摆属性，使其可以进行灵摆召唤并在灵摆区域存在时触发相关效果
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	-- 注册连锁记录效果，用于后续检测这张卡在连锁处理时是否在场上存在
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在灵摆区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
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
-- 定义连锁解决时的处理函数，用于在魔法卡发动并解决后放置魔力指示物
function c10239627.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 定义代价支付函数，检查并取除3个魔力指示物作为效果发动代价
function c10239627.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 定义灵摆怪兽的检索过滤函数，筛选卡组中可加入手牌的灵摆怪兽
function c10239627.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 定义灵摆区域起动效果的目标函数，检查是否存在可检索的灵摆怪兽
function c10239627.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，宣布将要执行的回手牌效果并指定目标位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义灵摆区域起动效果的处理函数，执行检索并加入手牌的操作
function c10239627.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示信息，告知玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 让玩家从卡组中选择1只灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义魔法师族·1星怪兽的检索过滤函数
function c10239627.thfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(1) and c:IsAbleToHand()
end
-- 定义怪兽区域起动效果的目标函数，检查是否存在符合条件的怪兽
function c10239627.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只魔法师族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10239627.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，宣布将要执行的回手牌效果并指定目标位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义怪兽区域起动效果的处理函数，执行检索并加入手牌的操作
function c10239627.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示信息，告知玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 让玩家从卡组中选择1只魔法师族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,c10239627.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义攻击力数值的计算函数，返回魔力指示物数量×100作为攻击力上升值
function c10239627.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*100
end
