--ローズ・パピヨン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
-- ②：只要自己场上有这张卡以外的昆虫族怪兽存在，这张卡可以直接攻击。
function c8910240.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8910240,0))  --"使用「蔷薇蝴蝶」的效果上级召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	-- 设置增加召唤次数效果的目标为等级7以上的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
	e1:SetValue(0x1)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有这张卡以外的昆虫族怪兽存在，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c8910240.dircon)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否为表侧表示的昆虫族怪兽
function c8910240.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 直接攻击效果的启用条件：自己场上存在除自身以外的昆虫族怪兽
function c8910240.dircon(e)
	-- 检查自己场上是否存在至少1张不等于自身且满足过滤条件（表侧表示昆虫族）的卡
	return Duel.IsExistingMatchingCard(c8910240.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
