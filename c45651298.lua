--ミミミック
-- 效果：
-- 对方场上有怪兽存在，自己场上有3星的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「似耳怪」的特殊召唤1回合只能有1次。
function c45651298.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上有3星的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法的「似耳怪」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45651298+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c45651298.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且等级为3的怪兽，用于筛选自己场上是否存在可作为条件的3星怪兽。
function c45651298.filter(c)
	return c:IsFaceup() and c:IsLevel(3)
end
-- 特殊召唤规则效果的判定函数：若c为nil则视为该规则召唤本身可被系统询问；否则需要同时满足对方场上有怪兽、自己主怪兽区有空位、自己场上有表侧表示3星怪兽，才能从手卡特殊召唤这张卡。
function c45651298.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在怪兽（对方怪兽区卡数大于0）。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己主怪兽区是否有可用的空格，确保有位置可以特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示且等级为3的怪兽（通过过滤器检索，不取对象）。
		and Duel.IsExistingMatchingCard(c45651298.filter,tp,LOCATION_MZONE,0,1,nil)
end
