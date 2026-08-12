--重力解除
-- 效果：
-- ①：场上的全部表侧表示怪兽的表示形式变更。
function c83133491.initial_effect(c)
	-- ①：场上的全部表侧表示怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83133491.target)
	e1:SetOperation(c83133491.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与确认：检查场上是否存在表侧表示怪兽，并收集这些怪兽作为操作对象，设置改变表示形式的操作信息
function c83133491.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有的表侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：表示形式变更，对象为获取到的所有表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果处理：获取双方场上所有的表侧表示怪兽，并改变它们的表示形式
function c83133491.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取双方场上所有的表侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将这些怪兽的表示形式变更（表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示）
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
