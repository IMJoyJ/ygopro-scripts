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
-- 定义效果的条件函数，用于判定“场上有「王家长眠之谷」存在”这一前提，满足时该永续免疫效果才适用。
function c46955770.con(e)
	-- 调用Duel.IsEnvironment(47355498)检查当前场上生效的场地是否为卡号47355498「王家长眠之谷」，若是则返回true。
	return Duel.IsEnvironment(47355498)
end
-- 作为EFFECT_IMMUNE_EFFECT的Value过滤函数，当某效果的来源卡不是本卡时返回true，表示该效果属于“这张卡以外的效果”，因此本卡对其免疫。
function c46955770.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
