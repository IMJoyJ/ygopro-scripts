--先史遺産モアイ
-- 效果：
-- 自己场上有名字带有「先史遗产」的怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
function c87430304.initial_effect(c)
	-- 自己场上有名字带有「先史遗产」的怪兽存在的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(c87430304.hspcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「先史遗产」怪兽
function c87430304.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x70)
end
-- 特殊召唤规则的条件判定：自身怪兽区域有空位，且自己场上存在表侧表示的「先史遗产」怪兽
function c87430304.hspcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的「先史遗产」怪兽
		and Duel.IsExistingMatchingCard(c87430304.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
