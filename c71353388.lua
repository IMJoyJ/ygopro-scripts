--リード・バタフライ
-- 效果：
-- 对方场上有同调怪兽表侧表示存在，自己场上没有同调怪兽表侧表示存在的场合，这张卡可以从手卡特殊召唤。
function c71353388.initial_effect(c)
	-- 对方场上有同调怪兽表侧表示存在，自己场上没有同调怪兽表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71353388.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的同调怪兽
function c71353388.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤规则的条件函数：检查怪兽区域空格以及双方场上的同调怪兽存在情况
function c71353388.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的同调怪兽
		and Duel.IsExistingMatchingCard(c71353388.cfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否不存在表侧表示的同调怪兽
		and	not Duel.IsExistingMatchingCard(c71353388.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
