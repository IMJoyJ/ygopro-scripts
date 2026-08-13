--先史遺産トゥーラ・ガーディアン
-- 效果：
-- 场地魔法卡表侧表示存在的场合，这张卡可以从手卡特殊召唤。「先史遗产 图拉守护者」在自己场上只能有1只表侧表示存在。
function c5291803.initial_effect(c)
	c:SetUniqueOnField(1,0,5291803)
	-- 场地魔法卡表侧表示存在的场合，这张卡可以从手卡特殊召唤。「先史遗产 图拉守护者」在自己场上只能有1只表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5291803.spcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则效果的发动条件：若c为空则视为可发动；否则检查当前控制者tp是否有空余的主要怪兽区，以及双方场地区是否存在表侧表示的场地魔法卡。
function c5291803.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家tp的主要怪兽区是否有空位，即确认有可用区域来进行从手卡的特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场地区（自己或对方）是否存在至少1张表侧表示的场地魔法卡，以满足从手卡特殊召唤所需的条件。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
