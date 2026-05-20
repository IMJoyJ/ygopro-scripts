--ライトレイ マドール
-- 效果：
-- 从游戏中除外的自己的光属性怪兽是3只以上的场合，这张卡可以从手卡特殊召唤。这张卡1回合只有1次不会被战斗破坏。
function c82579942.initial_effect(c)
	-- 从游戏中除外的自己的光属性怪兽是3只以上的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c82579942.spcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c82579942.valcon)
	c:RegisterEffect(e2)
end
-- 过滤除外区表侧表示的光属性怪兽
function c82579942.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则的条件函数，检查怪兽区空位以及除外区的光属性怪兽数量
function c82579942.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家的主要怪兽区域是否有可用的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外区是否存在至少3张表侧表示的光属性怪兽
		and Duel.IsExistingMatchingCard(c82579942.spfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 判断破坏原因是否为战斗破坏
function c82579942.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
