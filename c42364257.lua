--避雷針
-- 效果：
-- 对方使用了「雷击」的时候，破坏对方全部怪兽代替自己的怪兽。发动后这张卡破坏。
function c42364257.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，连锁时触发，条件为对方使用雷击，目标为对方场上怪兽，发动时破坏自己，效果类型为CATEGORY_DISABLE
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42364257.condition)
	e1:SetTarget(c42364257.target)
	e1:SetOperation(c42364257.activate)
	c:RegisterEffect(e1)
end
-- 当对方使用了「雷击」的时候，破坏对方全部怪兽代替自己的怪兽。发动后这张卡破坏。
function c42364257.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方使用了「雷击」的时候，破坏对方全部怪兽代替自己的怪兽。发动后这张卡破坏。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(12580477) and Duel.IsChainDisablable(ev)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c42364257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息为破坏对方场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 使连锁效果无效并破坏对方场上所有怪兽
function c42364257.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	if Duel.NegateEffect(ev) then
		-- 获取对方场上所有怪兽
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		-- 以效果原因破坏对方场上所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
