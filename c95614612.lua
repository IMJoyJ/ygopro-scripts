--砲弾ヤリ貝
-- 效果：
-- 当场上存在「海」时，这张卡不受魔法效果的影响。
function c95614612.initial_effect(c)
	-- 在卡片中记录该卡记有卡名「海」（22702055）
	aux.AddCodeList(c,22702055)
	-- 当场上存在「海」时，这张卡不受魔法效果的影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c95614612.econ)
	e1:SetValue(c95614612.efilter)
	c:RegisterEffect(e1)
end
-- 定义效果生效条件：场上存在「海」
function c95614612.econ(e)
	-- 判断场上是否存在「海」（包括卡名视为「海」的卡）
	return Duel.IsEnvironment(22702055)
end
-- 定义免疫效果的过滤函数，指定不受魔法卡的效果影响
function c95614612.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
