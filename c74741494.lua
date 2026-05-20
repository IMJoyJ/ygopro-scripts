--能力調整
-- 效果：
-- 自己场上表侧表示存在的全部怪兽的等级直到结束阶段时下降1星。
function c74741494.initial_effect(c)
	-- 自己场上表侧表示存在的全部怪兽的等级直到结束阶段时下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74741494.target)
	e1:SetOperation(c74741494.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选自己场上表侧表示且等级在2星以上的怪兽
function c74741494.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 效果发动的靶向与可行性检查函数
function c74741494.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且等级在2星以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74741494.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取符合条件的怪兽并逐一降低其等级
function c74741494.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级在2星以上的怪兽
	local g=Duel.GetMatchingGroup(c74741494.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级直到结束阶段时下降1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
