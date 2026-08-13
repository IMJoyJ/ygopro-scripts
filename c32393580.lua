--サイバー・シャーク
-- 效果：
-- 自己场上有水属性怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
function c32393580.initial_effect(c)
	-- 自己场上有水属性怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32393580,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c32393580.ntcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且水属性，用于筛选出自己场上的表侧水属性怪兽。
function c32393580.ntfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 召唤规则效果的条件函数：c为nil时返回true表示允许进行规则召唤；实际召唤时要求不需要解放、这张卡等级不低于5、自己场上有空余怪兽区且存在表侧表示的水属性怪兽。
function c32393580.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断无解放召唤的基础条件：解放数要求为0、这张卡等级不低于5且自己主要怪兽区有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 追加条件：自己场上存在至少1张表侧表示的水属性怪兽（通过ntfilter筛选）。
		and Duel.IsExistingMatchingCard(c32393580.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
