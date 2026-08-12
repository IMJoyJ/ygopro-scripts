--グラビティ・ボール
-- 效果：
-- 反转：对方场上存在的表侧表示怪兽全部的表示形式改变。
function c29216198.initial_effect(c)
	-- 反转：对方场上存在的表侧表示怪兽全部的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29216198,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c29216198.target)
	e1:SetOperation(c29216198.operation)
	c:RegisterEffect(e1)
end
-- 检索对方场上存在的表侧表示怪兽
function c29216198.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 改变对方场上所有表侧表示怪兽的表示形式
function c29216198.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将怪兽改变为表侧守备表示
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
