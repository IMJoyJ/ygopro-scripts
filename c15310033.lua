--アンノウン・シンクロン
-- 效果：
-- 「未知同调士」的①的方法的特殊召唤在决斗中只能有1次。
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c15310033.initial_effect(c)
	-- 「未知同调士」的①的方法的特殊召唤在决斗中只能有1次；①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15310033+EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c15310033.spcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则效果的召唤条件判定函数：c为nil时不限制具体卡片，返回true用于规则判断；否则判定这张卡的控制者是否满足自己场上没有怪兽、对方场上有怪兽，并且自己场上存在可用的主要怪兽区域。
function c15310033.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查这张卡的控制者自己的主要怪兽区域没有怪兽，即“自己场上没有怪兽存在”。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查这张卡的控制者对方场上的主要怪兽区域存在怪兽，即“对方场上有怪兽存在”。
		and	Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查这张卡的控制者自己场上有可用的主要怪兽区域，确保可以从手卡特殊召唤到空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
