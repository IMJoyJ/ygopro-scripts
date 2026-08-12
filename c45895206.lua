--闇をかき消す光
-- 效果：
-- 对方场上里侧表示的怪兽全部表侧表示。
function c45895206.initial_effect(c)
	-- 对方场上里侧表示的怪兽全部表侧表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45895206.target)
	e1:SetOperation(c45895206.activate)
	c:RegisterEffect(e1)
end
-- 检查对方场上是否存在里侧表示的怪兽
function c45895206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索对方场上是否存在至少1张里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有里侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 将对方场上所有里侧表示的怪兽变为表侧表示
function c45895206.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有里侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将怪兽组全部改变为表侧表示形式
		Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	end
end
