--極星獣グルファクシ
-- 效果：
-- 对方场上有同调怪兽表侧表示存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c41788781.initial_effect(c)
	-- 对方场上有同调怪兽表侧表示存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c41788781.spcon)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断对方场上是否存在表侧表示的同调怪兽
function c41788781.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的全部条件
function c41788781.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否存在可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否没有怪兽存在
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在至少1只表侧表示的同调怪兽
		and	Duel.IsExistingMatchingCard(c41788781.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
