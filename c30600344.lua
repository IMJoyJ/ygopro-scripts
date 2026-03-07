--エクシーズ・バースト
-- 效果：
-- 自己场上有6阶以上的超量怪兽存在的场合才能发动。对方场上盖放的卡全部破坏。
function c30600344.initial_effect(c)
	-- 效果原文内容：自己场上有6阶以上的超量怪兽存在的场合才能发动。对方场上盖放的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c30600344.condition)
	e1:SetTarget(c30600344.target)
	e1:SetOperation(c30600344.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查怪兽是否表侧表示且阶级大于等于6
function c30600344.cfilter(c)
	return c:IsFaceup() and c:IsRankAbove(6)
end
-- 效果作用：检查自己场上是否存在阶级大于等于6的超量怪兽
function c30600344.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在阶级大于等于6的超量怪兽
	return Duel.IsExistingMatchingCard(c30600344.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：检查卡是否为里侧表示
function c30600344.filter(c)
	return c:IsFacedown()
end
-- 效果作用：设置连锁处理时的破坏目标
function c30600344.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30600344.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 效果作用：获取对方场上所有里侧表示的卡
	local g=Duel.GetMatchingGroup(c30600344.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏效果
function c30600344.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有里侧表示的卡
	local g=Duel.GetMatchingGroup(c30600344.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 效果作用：将目标卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
