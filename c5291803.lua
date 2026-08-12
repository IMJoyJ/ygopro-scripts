--先史遺産トゥーラ・ガーディアン
-- 效果：
-- 场地魔法卡表侧表示存在的场合，这张卡可以从手卡特殊召唤。「先史遗产 图拉守护者」在自己场上只能有1只表侧表示存在。
function c5291803.initial_effect(c)
	c:SetUniqueOnField(1,0,5291803)
	-- 场地魔法卡表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5291803.spcon)
	c:RegisterEffect(e1)
end
-- 检查怪兽区域是否有空位且场上存在表侧表示的场地魔法卡作为特殊召唤条件
function c5291803.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查怪兽区域是否有可用空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在表侧表示的场地魔法卡
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
