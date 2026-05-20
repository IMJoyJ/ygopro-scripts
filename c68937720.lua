--メンタルドレイン
-- 效果：
-- 支付1000基本分才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把手卡的怪兽的效果发动。
function c68937720.initial_effect(c)
	-- 支付1000基本分才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c68937720.cost)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把手卡的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c68937720.aclimit)
	c:RegisterEffect(e2)
end
-- 定义发动卡片时的Cost，用于检查和支付1000基本分
function c68937720.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否拥有至少1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 在发动时，扣除玩家1000基本分作为Cost
	Duel.PayLPCost(tp,1000)
end
-- 判断被限制发动的效果是否为手牌中怪兽的效果
function c68937720.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_HAND) and re:IsActiveType(TYPE_MONSTER)
end
