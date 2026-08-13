--サンダー・ボルト
-- 效果：
-- ①：对方场上的怪兽全部破坏。
function c12580477.initial_effect(c)
	-- ①：对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12580477.target)
	e1:SetOperation(c12580477.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理：检查对方场上是否存在怪兽，若有则取得对方场上全部怪兽，并将这些怪兽设置为本次效果的破坏对象以写入操作信息。
function c12580477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若在效果发动时（chk==0）对方场上不存在任何怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上当前存在的全部怪兽，用于后续设置破坏的操作信息。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 把获取到的对方怪兽全体作为破坏对象写入操作信息，数量为怪兽数量，以便星尘龙等卡能够对应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时的执行函数：再次获取对方场上全部怪兽并全部破坏。
function c12580477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上的全部怪兽，确保破坏对象为当前存在的怪兽。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）将对方场上全部怪兽破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
