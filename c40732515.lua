--神聖魔導王 エンディミオン
-- 效果：
-- ①：这张卡可以把自己场上的「魔法都市 恩底弥翁」放置的6个魔力指示物取除，从手卡·墓地特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
-- ③：1回合1次，从手卡丢弃1张魔法卡，以场上1张卡为对象才能发动。那张卡破坏。
function c40732515.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上的「魔法都市 恩底弥翁」放置的6个魔力指示物取除，从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c40732515.spcon)
	e1:SetOperation(c40732515.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40732515,0))  --"墓地存在的1张魔法卡加入手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c40732515.condition)
	e2:SetTarget(c40732515.target)
	e2:SetOperation(c40732515.operation)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：1回合1次，从手卡丢弃1张魔法卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40732515,1))  --"场上存在的1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c40732515.descost)
	e3:SetTarget(c40732515.destg)
	e3:SetOperation(c40732515.desop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：定义过滤函数，用于筛选场上的「魔法都市 恩底弥翁」卡片，并判断其是否可以移除魔力指示物。
function c40732515.spcfilter(c,tp)
	return c:IsCode(39910367) and c:IsCanRemoveCounter(tp,0x1,1,REASON_COST)
end
-- 规则层面作用：判断特殊召唤条件是否满足，包括是否有足够的魔力指示物（至少6个）和场上是否有空位。
function c40732515.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 规则层面作用：获取场上所有符合条件的「魔法都市 恩底弥翁」卡片组。
	local g=Duel.GetMatchingGroup(c40732515.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	local ct=0
	-- 规则层面作用：遍历卡片组中的每一张卡片。
	for tc in aux.Next(g) do
		ct=ct+tc:GetCounter(0x1)
	end
	-- 规则层面作用：返回是否满足特殊召唤条件（魔力指示物总数≥6 且 场上有空位）。
	return ct>=6 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 规则层面作用：执行特殊召唤时的处理操作，根据场上「魔法都市 恩底弥翁」的数量决定如何移除魔力指示物。
function c40732515.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 规则层面作用：获取场上所有符合条件的「魔法都市 恩底弥翁」卡片组。
	local g=Duel.GetMatchingGroup(c40732515.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	if #g==1 then
		g:GetFirst():RemoveCounter(tp,0x1,6,REASON_COST)
	else
		for i=1,6 do
		-- 规则层面作用：提示玩家选择要移除魔力指示物的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40732515,2))  --"请选择要取除指示物的卡"
		-- 规则层面作用：选择一张符合条件的「魔法都市 恩底弥翁」卡片。
		local tg=Duel.SelectMatchingCard(tp,c40732515.spcfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
		tg:GetFirst():RemoveCounter(tp,0x1,1,REASON_COST)
		end
	end
end
-- 规则层面作用：判断该卡是否是通过①效果特殊召唤成功的。
function c40732515.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 规则层面作用：定义过滤函数，用于筛选墓地中的魔法卡。
function c40732515.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果目标，选择一张墓地中的魔法卡作为对象。
function c40732515.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40732515.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择一张墓地中的魔法卡作为目标。
	local g=Duel.SelectTarget(tp,c40732515.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面作用：设置效果操作信息，指定将目标卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 规则层面作用：执行效果操作，将目标卡加入手牌并洗切手牌。
function c40732515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面作用：洗切玩家的手牌。
		Duel.ShuffleHand(tp)
	end
end
-- 规则层面作用：定义过滤函数，用于筛选手牌中的魔法卡。
function c40732515.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 规则层面作用：设置效果成本，丢弃一张手牌中的魔法卡。
function c40732515.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否存在满足条件的手牌魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40732515.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 规则层面作用：丢弃一张手牌中的魔法卡作为效果成本。
	Duel.DiscardHand(tp,c40732515.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面作用：设置效果目标，选择一张场上的卡作为破坏对象。
function c40732515.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 规则层面作用：检查是否存在满足条件的场上卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 规则层面作用：提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择一张场上的卡作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面作用：设置效果操作信息，指定将目标卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：执行效果操作，破坏目标卡。
function c40732515.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：破坏目标卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
