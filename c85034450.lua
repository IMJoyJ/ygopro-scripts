--SRパチンゴーカート
-- 效果：
-- ①：1回合1次，从手卡丢弃1只机械族怪兽，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c85034450.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1只机械族怪兽，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c85034450.descost)
	e1:SetTarget(c85034450.destg)
	e1:SetOperation(c85034450.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中可丢弃的机械族怪兽
function c85034450.cfilter(c)
	return c:IsDiscardable() and c:IsRace(RACE_MACHINE)
end
-- 发动代价：从手卡丢弃1只机械族怪兽
function c85034450.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85034450.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1只机械族怪兽作为发动代价
	Duel.DiscardHand(tp,c85034450.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动：选择场上1只怪兽作为对象，并设置破坏的操作信息
function c85034450.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏该怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的怪兽
function c85034450.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
