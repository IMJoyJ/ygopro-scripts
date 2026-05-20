--ソウルドレイン
-- 效果：
-- 支付1000基本分才能发动。只要这张卡在场上存在，从游戏中除外的怪兽的效果以及墓地存在的怪兽的效果不能发动。
function c73599290.initial_effect(c)
	-- 支付1000基本分才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c73599290.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，从游戏中除外的怪兽的效果以及墓地存在的怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c73599290.aclimit)
	c:RegisterEffect(e2)
end
-- 定义发动卡片时的代价（Cost）函数，用于检查并支付1000基本分
function c73599290.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否拥有至少1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除发动玩家1000基本分作为发动的代价
	Duel.PayLPCost(tp,1000)
end
-- 定义限制发动的条件：当效果的发动位置是墓地或除外区，且该效果是怪兽的效果时，禁止发动
function c73599290.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return (loc==LOCATION_GRAVE or loc==LOCATION_REMOVED) and re:IsActiveType(TYPE_MONSTER)
end
