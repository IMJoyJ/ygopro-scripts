--封魔一閃
-- 效果：
-- 对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
function c39956951.initial_effect(c)
	-- 效果原文内容：对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c39956951.condition)
	e1:SetTarget(c39956951.target)
	e1:SetOperation(c39956951.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断怪兽区域是否全部有怪兽存在
function c39956951.cfilter(c)
	return c:GetSequence()<5
end
-- 规则层面作用：判断对方场上怪兽区域是否全部有怪兽存在
function c39956951.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断对方场上怪兽区域是否全部有怪兽存在
	return Duel.GetMatchingGroupCount(c39956951.cfilter,tp,0,LOCATION_MZONE,nil)>=5
end
-- 效果原文内容：对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
function c39956951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查对方场上是否存在至少1张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：获取对方场上所有怪兽卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 规则层面作用：设置连锁操作信息，指定要破坏的怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果原文内容：对方场上的怪兽卡区域全部有怪兽存在的场合才能发动。对方场上存在的全部怪兽破坏。
function c39956951.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取对方场上所有怪兽卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 规则层面作用：将对方场上所有怪兽卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
