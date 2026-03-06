--侵略の汎発感染
-- 效果：
-- ①：自己场上的全部「入魔」怪兽直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
function c27541267.initial_effect(c)
	-- 效果原文内容：①：自己场上的全部「入魔」怪兽直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27541267.target)
	e1:SetOperation(c27541267.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出场上表侧表示的「入魔」怪兽
function c27541267.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa)
end
-- 效果作用：判断是否满足发动条件，即自己场上是否存在至少1只表侧表示的「入魔」怪兽
function c27541267.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即自己场上是否存在至少1只表侧表示的「入魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27541267.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果作用：将场上所有满足条件的「入魔」怪兽变为免疫魔法·陷阱卡效果的状态
function c27541267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检索满足条件的「入魔」怪兽组成group
	local g=Duel.GetMatchingGroup(c27541267.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 效果原文内容：自己场上的全部「入魔」怪兽直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c27541267.efilter)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果作用：判断一个效果是否为魔法·陷阱卡效果且所有者不是该怪兽本身
function c27541267.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
