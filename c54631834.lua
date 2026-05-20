--端末世界
-- 效果：
-- 自己主要阶段1才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方的主要阶段2跳过。
function c54631834.initial_effect(c)
	-- 自己主要阶段1才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c54631834.condition)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方的主要阶段2跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetCode(EFFECT_SKIP_M2)
	c:RegisterEffect(e2)
end
-- 定义卡片发动的条件函数，限制只能在主要阶段1发动
function c54631834.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
