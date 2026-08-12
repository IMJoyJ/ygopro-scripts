--フェザー・ウィンド
-- 效果：
-- 自己场上有「元素英雄 羽翼侠」表侧表示存在的场合才能发动。魔法·陷阱卡的发动无效，并把那张卡破坏。
function c71060915.initial_effect(c)
	-- 将卡片关联的怪兽系列设定为「英雄」（0x3008），以便进行系列判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 自己场上有「元素英雄 羽翼侠」表侧表示存在的场合才能发动。魔法·陷阱卡的发动无效，并把那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c71060915.condition)
	e1:SetTarget(c71060915.target)
	e1:SetOperation(c71060915.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「元素英雄 羽翼侠」。
function c71060915.filter(c)
	return c:IsFaceup() and c:IsCode(21844576)
end
-- 检查发动条件：自己场上有表侧表示的「元素英雄 羽翼侠」，且连锁上的效果是魔法·陷阱卡的发动，并且该发动可以被无效。
function c71060915.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「元素英雄 羽翼侠」。
	return Duel.IsExistingMatchingCard(c71060915.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且当前连锁的效果是魔法·陷阱卡的发动，且该发动可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果发动时的目标选择与操作信息设置：确认效果可以发动，并设置无效与破坏的操作信息。
function c71060915.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果该卡可被破坏且与效果有关联，则将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使魔法·陷阱卡的发动无效并破坏。
function c71060915.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡与该效果有关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
