--魔導獣 ジャッカル
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己场上1张可以放置魔力指示物的卡为对象才能发动。这张卡破坏，给那张卡放置1个魔力指示物。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把自己场上3个魔力指示物取除，把这张卡解放才能发动。从卡组把「魔导兽 胡狼」以外的1只「魔导兽」效果怪兽特殊召唤。
function c91182675.initial_effect(c)
	-- 为怪兽卡添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动等基本规则）。
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己场上1张可以放置魔力指示物的卡为对象才能发动。这张卡破坏，给那张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91182675,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,91182675)
	e1:SetCondition(c91182675.ctcon)
	e1:SetTarget(c91182675.cttg)
	e1:SetOperation(c91182675.ctop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 注册连锁发生时的标记，用于在连锁处理结束时判断是否有魔法卡发动。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c91182675.acop)
	c:RegisterEffect(e3)
	-- ②：把自己场上3个魔力指示物取除，把这张卡解放才能发动。从卡组把「魔导兽 胡狼」以外的1只「魔导兽」效果怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(91182675,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c91182675.spcost)
	e4:SetTarget(c91182675.sptg)
	e4:SetOperation(c91182675.spop)
	c:RegisterEffect(e4)
end
-- 灵摆效果发动的条件函数：另一边的灵摆区域没有卡存在。
function c91182675.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除自身外，自己的灵摆区域是否没有其他卡存在。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数：选择场上表侧表示且可以放置魔力指示物的卡。
function c91182675.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 灵摆效果的发动准备（检查与选择目标，设置操作信息）。
function c91182675.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and c91182675.ctfilter(chkc) end
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查自己场上是否存在除自身以外、可以成为效果对象且能放置魔力指示物的卡。
		and Duel.IsExistingTarget(c91182675.ctfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要放置指示物的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 玩家选择自己场上1张可以放置魔力指示物的卡作为效果对象。
	Duel.SelectTarget(tp,c91182675.ctfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置连锁操作信息：包含破坏自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁操作信息：包含放置1个魔力指示物的操作。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 灵摆效果的处理函数：破坏自身，并给目标卡放置1个魔力指示物。
function c91182675.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象（即要放置魔力指示物的卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e)
		-- 尝试破坏自身，并确认是否破坏成功。
		and Duel.Destroy(c,REASON_EFFECT)~=0
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
-- 魔法卡发动连锁处理完毕时的处理：给这张卡放置1个魔力指示物。
function c91182675.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 怪兽效果②的发动代价函数：移除3个魔力指示物并解放自身。
function c91182675.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否能从自己场上移除3个魔力指示物，且这张卡是否可以被解放。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) and c:IsReleasable() end
	-- 从自己场上移除3个魔力指示物作为发动代价。
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
	-- 解放自身作为发动代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：从卡组检索「魔导兽 胡狼」以外的「魔导兽」效果怪兽。
function c91182675.spfilter(c,e,tp)
	return c:IsSetCard(0x10d) and not c:IsCode(91182675)
		and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果②的发动准备（检查怪兽区域空位、卡组中是否存在合法怪兽，并设置操作信息）。
function c91182675.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在解放这张卡后，自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在满足特殊召唤条件的「魔导兽」效果怪兽。
		and Duel.IsExistingMatchingCard(c91182675.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的效果处理：从卡组特殊召唤1只「魔导兽」效果怪兽。
function c91182675.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「魔导兽」效果怪兽。
	local g=Duel.SelectMatchingCard(tp,c91182675.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
