--アンノウン・シンクロン
-- 效果：
-- 「未知同调士」的①的方法的特殊召唤在决斗中只能有1次。
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c15310033.initial_effect(c)
	-- 效果原文内容：「未知同调士」的①的方法的特殊召唤在决斗中只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15310033+EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c15310033.spcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c15310033.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 己方场上没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 对方场上存在怪兽
		and	Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 己方场上存在可用召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
