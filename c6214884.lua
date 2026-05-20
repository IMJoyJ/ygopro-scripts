--暗黒界の狂王 ブロン
-- 效果：
-- ①：这张卡给与对方战斗伤害时才能发动。选自己1张手卡丢弃。
function c6214884.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时才能发动。选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6214884,0))  --"选择1张手卡丢弃去墓地"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c6214884.condition)
	e1:SetTarget(c6214884.target)
	e1:SetOperation(c6214884.operation)
	c:RegisterEffect(e1)
end
-- 判断造成战斗伤害的玩家是否为对方玩家。
function c6214884.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标检查与操作信息设置。
function c6214884.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己手牌数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置连锁的操作信息为：丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：执行丢弃手牌的操作。
function c6214884.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择自己1张手牌，因效果丢弃去墓地。
	Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
end
