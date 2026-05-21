--フォトン・スレイヤー
-- 效果：
-- 场上有超量怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
function c9718968.initial_effect(c)
	-- 场上有超量怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c9718968.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为表侧表示的超量怪兽
function c9718968.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 特殊召唤规则的判定条件：自身怪兽区域有空位，且场上存在表侧表示的超量怪兽
function c9718968.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1张表侧表示的超量怪兽
		and Duel.IsExistingMatchingCard(c9718968.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
