--BF－東雲のコチ
-- 效果：
-- 特殊召唤的这张卡不能作为同调素材。
function c41902352.initial_effect(c)
	-- 特殊召唤的这张卡不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetCondition(c41902352.synlimit)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 特殊召唤的这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetCost(c41902352.spcost)
	c:RegisterEffect(e2)
end
-- 取效果的持有者（这张卡），判断其召唤类型是否包含特殊召唤（SUMMON_TYPE_SPECIAL）；该结果为是否附加『不能作为同调素材』限制的条件。
function c41902352.synlimit(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 此函数作为特殊召唤手续的代价判定：若召唤类型 sumtype 等于『特殊召唤+作为同调素材』则返回 false，导致该特殊召唤不被允许；以此防止这张卡通过『被作为同调素材的特殊召唤』方式成为同调素材。
function c41902352.spcost(e,c,tp,sumtype)
	return sumtype~=SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SYNCHRO_MATERIAL
end
