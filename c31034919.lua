--マッド・リローダー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。选2张手卡送去墓地，自己从卡组抽2张。
function c31034919.initial_effect(c)
	-- 效果原文：①：这张卡被战斗破坏送去墓地的场合发动。选2张手卡送去墓地，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31034919,0))  --"抽卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c31034919.condition)
	e1:SetTarget(c31034919.target)
	e1:SetOperation(c31034919.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：判断此卡是否因战斗破坏而进入墓地
function c31034919.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面：设置连锁处理信息，确定将要处理的2张手卡送去墓地和自己抽2张卡
function c31034919.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置将要处理的2张手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND)
	-- 规则层面：设置将要处理的自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面：执行效果处理，先判断手牌是否足够，然后丢弃2张手卡并抽2张卡
function c31034919.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断手牌数量是否满足效果要求
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<2 then return end
	-- 规则层面：丢弃2张手卡至墓地
	Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT)
	-- 规则层面：自己从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
