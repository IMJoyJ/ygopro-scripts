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
-- 过滤函数：检查卡片是否为表侧表示、属于「黑羽」字段（0x33）且不是卡名「黑羽-黑枪之布拉斯特」自身，用于检索满足①条件所需的「黑羽」怪兽。
function c49003716.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(49003716)
end
-- 特殊召唤规则的条件函数：c为空时表示允许规则发动本身；否则要求这张卡的控制者场上存在可用的主要怪兽区空格，且自己场上存在满足filter的「黑羽」怪兽，从而允许这张卡从手卡进行规则特殊召唤。
function c49003716.spcon(e,c)
	if c==nil then return true end
	-- 判定这张卡的控制者场上是否仍有可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1只满足filter条件的「黑羽」怪兽（表侧表示、黑羽字段、非黑枪自身）。
		Duel.IsExistingMatchingCard(c49003716.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
