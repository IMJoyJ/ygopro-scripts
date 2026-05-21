--サイレント・アングラー
-- 效果：
-- ①：自己场上有水属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能从手卡把怪兽特殊召唤。
function c90303176.initial_effect(c)
	-- ①：自己场上有水属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能从手卡把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c90303176.spcon)
	e1:SetOperation(c90303176.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且是水属性的怪兽
function c90303176.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 特殊召唤规则的条件函数
function c90303176.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的水属性怪兽
		and Duel.IsExistingMatchingCard(c90303176.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤规则的操作函数，用于在特殊召唤成功时适用限制效果
function c90303176.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤过的回合，自己不能从手卡把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c90303176.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从手卡特殊召唤的效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的区域过滤函数，指定为手牌
function c90303176.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_HAND)
end
