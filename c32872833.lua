--星間竜パーセク
-- 效果：
-- 自己场上有8星的怪兽存在的场合，这张卡可以不用解放作召唤。
function c32872833.initial_effect(c)
	-- 对应效果原文：自己场上有8星的怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32872833,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c32872833.ntcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示且等级为8的怪兽。
function c32872833.filter(c)
	return c:IsFaceup() and c:IsLevel(8)
end
-- 召唤规则效果的召唤条件判定：若c为空则视为规则发动条件允许；否则要求是无解放召唤、自己主要怪兽区有空位，且自己场上有表侧表示等级8的怪兽。
function c32872833.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查召唤方式是否为无解放召唤（解放数量为0），同时确认自己主要怪兽区有空位可以通常召唤。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示且等级为8的怪兽，作为可以不解放召唤的条件。
		and Duel.IsExistingMatchingCard(c32872833.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
