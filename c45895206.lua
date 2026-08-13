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
-- 效果发动时的目标检测与操作信息登记：确认对方场上有里侧表示怪兽，并记录将要改变表示形式的怪兽集合及数量。
function c45895206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若对方场上不存在任何里侧表示怪兽，则不能发动本卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有里侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	-- 将本次效果要改变表示形式的怪兽集合及数量登记到操作信息中，供连锁处理时相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理阶段：重新获取对方场上里侧表示的怪兽，并将其全部变为表侧表示。
function c45895206.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有里侧表示怪兽的集合，以应对发动前可能的变化。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将选中的里侧怪兽全部翻转为表侧表示（原里侧攻击表示变为表侧攻击表示，原里侧守备表示变为表侧守备表示）。
		Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	end
end
