--古代の歯車
-- 效果：
-- 自己场上有「古代的齿车」表侧表示存在时，这张卡可以从手卡以攻击表示特殊召唤。
function c31557782.initial_effect(c)
	-- 自己场上有「古代的齿车」表侧表示存在时，这张卡可以从手卡以攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31557782.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选出场上表侧表示且卡名为「古代的齿车」（卡号31557782）的卡。
function c31557782.filter(c)
	return c:IsFaceup() and c:IsCode(31557782)
end
-- 特殊召唤手续的条件：在己方场上存在表侧表示「古代的齿车」且己方主要怪兽区有空位时，允许这张卡从手卡以攻击表示特殊召唤。
function c31557782.spcon(e,c)
	if c==nil then return true end
	-- 检查己方主要怪兽区是否有至少1个空位，保证可以放置特殊召唤的怪兽。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查己方场上是否存在1张表侧表示的「古代的齿车」（卡号31557782），以满足效果原文中“自己场上有「古代的齿车」表侧表示存在时”这一条件。
		and Duel.IsExistingMatchingCard(c31557782.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
