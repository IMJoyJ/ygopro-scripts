--機甲忍者アース
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c22812068.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c22812068.spcon)
	c:RegisterEffect(e1)
end
-- 判断特殊召唤条件是否满足
function c22812068.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上是否有怪兽
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
