--マッド・リローダー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。选2张手卡送去墓地，自己从卡组抽2张。
function c31034919.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。选2张手卡送去墓地，自己从卡组抽2张。
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
-- 判断效果发动的条件：这张卡是否为被战斗破坏后送去墓地，即位于墓地且战斗破坏原因成立。
function c31034919.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动前的目标处理：无指定对象，仅登记本次效果将丢弃2张手卡并抽取2张卡的操作信息，允许效果发动。
function c31034919.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果包含“从手卡丢弃2张卡送去墓地”这一处理，操作对象为玩家tp的手牌（不指定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND)
	-- 登记操作信息：本次效果包含“从卡组抽2张卡”这一处理，抽卡玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时的实际执行：先确认手卡数量足够，然后丢弃2张手卡，再抽取2张卡。
function c31034919.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家tp的手卡数量不足2张，则无法进行丢弃处理，效果处理直接结束。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<2 then return end
	-- 以效果原因选择玩家tp的2张手卡丢弃去墓地。
	Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT)
	-- 以效果原因让玩家tp从卡组抽2张卡。
	Duel.Draw(tp,2,REASON_EFFECT)
end
