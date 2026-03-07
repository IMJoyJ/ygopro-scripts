--星間竜パーセク
-- 效果：
-- 自己场上有8星的怪兽存在的场合，这张卡可以不用解放作召唤。
function c32872833.initial_effect(c)
	-- 效果原文内容：自己场上有8星的怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32872833,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c32872833.ntcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的8星表侧表示怪兽
function c32872833.filter(c)
	return c:IsFaceup() and c:IsLevel(8)
end
-- 效果作用：满足召唤条件时可以不进行解放召唤
function c32872833.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤时是否满足场上存在空位的条件
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少1只8星的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c32872833.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
