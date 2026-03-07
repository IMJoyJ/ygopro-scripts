--サイバー・シャーク
-- 效果：
-- 自己场上有水属性怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
function c32393580.initial_effect(c)
	-- 效果原文内容：自己场上有水属性怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32393580,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c32393580.ntcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的水属性怪兽（表侧表示）
function c32393580.ntfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 判断召唤条件是否满足：不需解放、等级5以上、场上存在空位、自己场上有水属性怪兽表侧表示
function c32393580.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不需解放召唤的条件：不需解放、等级5以上、场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少1只表侧表示的水属性怪兽
		and Duel.IsExistingMatchingCard(c32393580.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
