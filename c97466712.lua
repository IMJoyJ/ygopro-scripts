--ハック・ワーム
-- 效果：
-- ①：对方场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c97466712.initial_effect(c)
	-- ①：对方场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c97466712.hspcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则的条件判定函数，用于判断是否满足手卡特殊召唤的条件
function c97466712.hspcon(e,c)
	if c==nil then return true end
	-- 检查对方场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)==0
		-- 检查自身场上是否有可用于特殊召唤的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
