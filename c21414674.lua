--プロミネンス・ハンド
-- 效果：
-- ①：自己场上有「魔术手」「火焰手」「寒冰手」的其中任意种存在的场合，这张卡可以从手卡特殊召唤。
function c21414674.initial_effect(c)
	-- ①：自己场上有「魔术手」「火焰手」「寒冰手」的其中任意种存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c21414674.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否为表侧表示且卡号为22530212（魔术手）、68535320（火焰手）或95929069（寒冰手）。
function c21414674.filter(c)
	return c:IsFaceup() and c:IsCode(22530212,68535320,95929069)
end
-- 特殊召唤条件：c为nil时返回true表示存在可以特殊召唤的卡；c非nil时，需满足控制者主要怪兽区有空位且其场上有符合filter的「魔术手」「火焰手」「寒冰手」之一。
function c21414674.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡的控制者的主要怪兽区是否有空位（空格数大于0），确保特殊召唤时有可用区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查控制者场上是否存在至少1张满足c21414674.filter的卡（表侧表示的「魔术手」「火焰手」「寒冰手」中的任意一种）。
		and Duel.IsExistingMatchingCard(c21414674.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
