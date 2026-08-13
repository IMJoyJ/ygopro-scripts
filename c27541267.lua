--侵略の汎発感染
-- 效果：
-- ①：自己场上的全部「入魔」怪兽直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
function c27541267.initial_effect(c)
	-- ①：自己场上的全部「入魔」怪兽直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27541267.target)
	e1:SetOperation(c27541267.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：该卡必须为表侧表示且属于「入魔」系列（0xa），用于确定本效果能作用到的怪兽。
function c27541267.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa)
end
-- 发动时的判定：检查自己场上是否存在至少1只表侧表示「入魔」怪兽，以此作为本卡能否发动的前提。
function c27541267.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认自己场上存在至少1只满足filter条件的表侧表示「入魔」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27541267.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：取得自己场上所有表侧表示「入魔」怪兽，并为这些怪兽逐一赋予免疫效果，使它们直到回合结束不受这张卡以外的魔法·陷阱卡效果影响。
function c27541267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有表侧表示「入魔」怪兽的集合g，作为后续赋予免疫效果的对象。
	local g=Duel.GetMatchingGroup(c27541267.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到回合结束时不受这张卡以外的魔法·陷阱卡的效果影响。
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
-- 免疫判定条件：来源效果须为魔法·陷阱卡效果，且该效果的持有者不是这张卡（即“这张卡以外”的魔法·陷阱卡效果）。
function c27541267.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
