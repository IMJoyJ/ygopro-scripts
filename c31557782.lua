--古代の歯車
-- 效果：
-- 自己场上有「古代的齿车」表侧表示存在时，这张卡可以从手卡以攻击表示特殊召唤。
function c31557782.initial_effect(c)
	-- 效果原文内容：自己场上有「古代的齿车」表侧表示存在时，这张卡可以从手卡以攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31557782.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：检查场上是否存在表侧表示的古代的齿车
function c31557782.filter(c)
	return c:IsFaceup() and c:IsCode(31557782)
end
-- 特殊召唤的条件函数：判断是否满足特殊召唤的条件
function c31557782.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断玩家场上是否存在至少1张表侧表示的古代的齿车
		and Duel.IsExistingMatchingCard(c31557782.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
