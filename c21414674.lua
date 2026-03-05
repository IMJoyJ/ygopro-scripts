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
-- 过滤函数，用于判断场上是否存在表侧表示的「魔术手」「火焰手」「寒冰手」。
function c21414674.filter(c)
	return c:IsFaceup() and c:IsCode(22530212,68535320,95929069)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件。
function c21414674.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家的怪兽区域是否有可用空间。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1张满足过滤条件的卡。
		and Duel.IsExistingMatchingCard(c21414674.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
