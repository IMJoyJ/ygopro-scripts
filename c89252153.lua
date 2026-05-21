--E・HERO ネクロダークマン
-- 效果：
-- ①：只在这张卡在墓地存在才有1次，自己在5星以上的「元素英雄」怪兽召唤的场合需要的解放可以不用。
function c89252153.initial_effect(c)
	-- ①：只在这张卡在墓地存在才有1次，自己在5星以上的「元素英雄」怪兽召唤的场合需要的解放可以不用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89252153,0))  --"「元素英雄 死灵暗侠」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c89252153.ntcon)
	e1:SetTarget(c89252153.nttg)
	c:RegisterEffect(e1)
end
-- 召唤手续效果的条件函数，用于判断是否满足不用解放进行召唤的规则条件
function c89252153.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否允许0解放召唤，且当前控制者的怪兽区域有空位
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤手续效果的目标过滤函数，限制为手牌中5星以上的「元素英雄」怪兽
function c89252153.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x3008)
end
