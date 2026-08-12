--墓守の異端者
-- 效果：
-- ①：只要这张卡在怪兽区域存在，并在场上有「王家长眠之谷」存在，这张卡不受这张卡以外的效果影响。
function c46955770.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，并在场上有「王家长眠之谷」存在，这张卡不受这张卡以外的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c46955770.con)
	e1:SetValue(c46955770.efilter)
	c:RegisterEffect(e1)
end
-- 检查场地是否为「王家长眠之谷」
function c46955770.con(e)
	-- 判断场地卡是否为「王家长眠之谷」（卡号47355498）
	return Duel.IsEnvironment(47355498)
end
-- 效果过滤器：排除自身效果
function c46955770.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
