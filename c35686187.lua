--断頭台の惨劇
-- 效果：
-- 对方场上表侧攻击表示存在的怪兽的表示形式变更为表侧守备表示时才能发动。对方场上守备表示存在的怪兽全部破坏。
function c35686187.initial_effect(c)
	-- 效果原文：对方场上表侧攻击表示存在的怪兽的表示形式变更为表侧守备表示时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c35686187.condition)
	e1:SetTarget(c35686187.target)
	e1:SetOperation(c35686187.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否为对方场上表侧攻击表示变为表侧守备表示
function c35686187.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP_ATTACK) and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果作用：判断是否有对方场上表侧攻击表示变为表侧守备表示的怪兽
function c35686187.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35686187.cfilter,1,nil,1-tp)
end
-- 效果作用：筛选对方场上所有守备表示的怪兽
function c35686187.filter(c)
	return c:IsDefensePos()
end
-- 效果作用：设置连锁处理时的破坏目标为对方场上所有守备表示的怪兽
function c35686187.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断对方场上是否存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35686187.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取对方场上所有守备表示的怪兽组成组
	local g=Duel.GetMatchingGroup(c35686187.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置连锁操作信息为破坏效果，目标为所有守备表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏对方场上所有守备表示怪兽的效果
function c35686187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有守备表示的怪兽组成组
	local g=Duel.GetMatchingGroup(c35686187.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 效果作用：将所有目标怪兽以效果原因破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
