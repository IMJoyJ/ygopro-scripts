--悪魔払い
-- 效果：
-- 场上的恶魔族怪兽全部破坏。
function c26725158.initial_effect(c)
	-- 场上的恶魔族怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26725158.target)
	e1:SetOperation(c26725158.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择场上表侧表示且种族为恶魔族的怪兽。
function c26725158.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 效果发动时的目标处理：检查场上是否存在符合条件的表侧恶魔族怪兽，若存在则获取全部此类怪兽并设定破坏的操作信息。
function c26725158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若场上不存在任何符合条件的表侧恶魔族怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示的恶魔族怪兽，用于后续设定破坏对象。
	local sg=Duel.GetMatchingGroup(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本次效果处理将破坏这些怪兽，并记录数量，供相关卡片或效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时的操作：重新获取当前场上所有符合条件的表侧恶魔族怪兽，并将其全部破坏。
function c26725158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示且种族为恶魔族的怪兽，作为本次破坏的对象。
	local sg=Duel.GetMatchingGroup(c26725158.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果破坏的原因将这些怪兽全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
