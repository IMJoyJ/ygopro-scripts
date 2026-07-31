--魔導獣 ジャッカル
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以自己场上1张可以放置魔力指示物的卡为对象才能发动。这张卡破坏，给那张卡放置1个魔力指示物。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把自己场上3个魔力指示物取除，把这张卡解放才能发动。从卡组把「魔导兽 胡狼」以外的1只「魔导兽」效果怪兽特殊召唤。
function c91182675.initial_effect(c)
	-- 注册灵摆卡片属性与规则
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
	-- 在连锁生成时注册连锁标记（用于魔法卡发动成功时放置指示物）
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
c91182675.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果发动条件检查
function c91182675.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断另一边的灵摆区域是否没有卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 指示物放置目标过滤：表侧表示且能放置魔力指示物的卡
function c91182675.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 放置指示物效果发动准备与目标确认
function c91182675.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and c91182675.ctfilter(chkc) end
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 判断自己场上是否存在可以放置魔力指示物的其他卡
		and Duel.IsExistingTarget(c91182675.ctfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择自己场上1张可以放置魔力指示物的卡作为对象
	Duel.SelectTarget(tp,c91182675.ctfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置连锁操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 放置指示物效果处理：破坏自身并给目标卡放置1个魔力指示物
function c91182675.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e)
		-- 判断自身是否成功被效果破坏
		and Duel.Destroy(c,REASON_EFFECT)~=0
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
-- 魔法卡发动处理：给自身放置1个魔力指示物
function c91182675.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 特殊召唤效果Cost处理：取除3个魔力指示物并解放自身
function c91182675.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：自己场上有3个魔力指示物且自身可以解放
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) and c:IsReleasable() end
	-- 从自己场上取除3个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
	-- 将自身解放
	Duel.Release(c,REASON_COST)
end
-- 特殊召唤过滤条件：卡名以外的「魔导兽」效果怪兽
function c91182675.spfilter(c,e,tp)
	return c:IsSetCard(0x10d) and not c:IsCode(91182675)
		and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动准备与目标确认
function c91182675.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断解放自身后怪兽区域是否有可用空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断卡组是否存在满足条件的「魔导兽」效果怪兽
		and Duel.IsExistingMatchingCard(c91182675.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理：从卡组特殊召唤1只「魔导兽」效果怪兽
function c91182675.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足条件的「魔导兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c91182675.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
