--トークン収穫祭
-- 效果：
-- 破坏场上所有衍生物。回复破坏衍生物数量×800的基本分。
function c57182235.initial_effect(c)
	-- 破坏场上所有衍生物。回复破坏衍生物数量×800的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c57182235.target)
	e1:SetOperation(c57182235.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与处理信息设置
function c57182235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只衍生物
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_TOKEN) end
	-- 获取场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 设置操作信息，表示该效果会破坏场上所有的衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息，表示该效果会使发动玩家回复破坏数量×800的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*800)
end
-- 效果处理的执行
function c57182235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 因效果破坏获取到的所有衍生物，并记录实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 使发动玩家回复实际破坏数量×800的基本分
	Duel.Recover(tp,ct*800,REASON_EFFECT)
end
