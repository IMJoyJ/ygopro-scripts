--ジャンク・フォアード
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
function c56410040.initial_effect(c)
	-- 自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56410040,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c56410040.spcon)
	c:RegisterEffect(e1)
end
-- 判定是否满足特殊召唤的条件
function c56410040.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
