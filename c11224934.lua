--強化空間
-- 效果：
-- 自己场上表侧表示存在的全部超量怪兽的攻击力直到结束阶段时上升那怪兽的超量素材每1个300。
function c11224934.initial_effect(c)
	-- 自己场上表侧表示存在的全部超量怪兽的攻击力直到结束阶段时上升那怪兽的超量素材每1个300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11224934.target)
	e1:SetOperation(c11224934.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示且有超量素材的怪兽
function c11224934.filter(c)
	return c:IsFaceup() and c:GetOverlayCount()~=0
end
-- 效果的发动时点判定函数
function c11224934.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11224934.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果的发动处理函数
function c11224934.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c11224934.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将攻击力提升效果应用到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetOverlayCount()*300)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
