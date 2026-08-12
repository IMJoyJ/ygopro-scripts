--クリエイト・リゾネーター
-- 效果：
-- ①：自己场上有8星以上的同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c5780210.initial_effect(c)
	-- ①：自己场上有8星以上的同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5780210.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、8星以上且是同调怪兽的卡
function c5780210.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤规则的条件判定：怪兽区域有空位，且自己场上存在满足过滤条件的怪兽
function c5780210.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的怪兽区域是否有可用的空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足过滤条件的卡（表侧表示的8星以上同调怪兽）
		and Duel.IsExistingMatchingCard(c5780210.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
