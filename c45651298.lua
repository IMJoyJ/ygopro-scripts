--ミミミック
-- 效果：
-- 对方场上有怪兽存在，自己场上有3星的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「似耳怪」的特殊召唤1回合只能有1次。
function c45651298.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽存在，自己场上有3星的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「似耳怪」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45651298+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c45651298.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：检查场上是否存在表侧表示的3星怪兽
function c45651298.filter(c)
	return c:IsFaceup() and c:IsLevel(3)
end
-- 判断特殊召唤条件是否满足：对方场上有怪兽存在、自己场上存在空位、自己场上存在3星怪兽
function c45651298.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 判断自己场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上存在3星怪兽
		and Duel.IsExistingMatchingCard(c45651298.filter,tp,LOCATION_MZONE,0,1,nil)
end
