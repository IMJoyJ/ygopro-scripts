--グランド・ドラゴン
-- 效果：
-- 这张卡在自己场上至少有1只其他的怪兽存在不能召唤。自己场上没有这张卡以外的龙族怪兽存在时，这张卡不能攻击宣言。
function c93220472.initial_effect(c)
	-- 这张卡在自己场上至少有1只其他的怪兽存在不能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c93220472.sumcon)
	c:RegisterEffect(e1)
	-- 自己场上没有这张卡以外的龙族怪兽存在时，这张卡不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c93220472.atkcon)
	c:RegisterEffect(e2)
end
-- 定义不能召唤效果的生效条件
function c93220472.sumcon(e)
	-- 判断自己场上的怪兽数量是否大于0（即存在其他怪兽）
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
-- 过滤自己场上表侧表示的龙族怪兽
function c93220472.afilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 定义不能攻击效果的生效条件
function c93220472.atkcon(e)
	-- 判断自己场上是否存在除这张卡以外的表侧表示龙族怪兽，若不存在则满足不能攻击的条件
	return not Duel.IsExistingMatchingCard(c93220472.afilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
