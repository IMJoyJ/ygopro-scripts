--BF－黒槍のブラスト
-- 效果：
-- ①：自己场上有「黑羽-黑枪之布拉斯特」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c49003716.initial_effect(c)
	-- ①：自己场上有「黑羽-黑枪之布拉斯特」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49003716.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在满足条件的「黑羽」怪兽（非自身）
function c49003716.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(49003716)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function c49003716.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家场上是否有足够的怪兽区域可用于特殊召唤
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断玩家场上是否存在至少1只满足过滤条件的「黑羽」怪兽
		Duel.IsExistingMatchingCard(c49003716.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
