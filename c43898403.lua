--ツインツイスター
-- 效果：
-- ①：丢弃1张手卡，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c43898403.initial_effect(c)
	-- ①：丢弃1张手卡，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCost(c43898403.cost)
	e1:SetTarget(c43898403.target)
	e1:SetOperation(c43898403.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：从手卡丢弃1张卡，作为效果发动的代价。
function c43898403.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：确认手牌中是否存在至少1张可丢弃的卡，用于支付丢弃手卡的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡选择1张卡丢弃，丢弃原因设为COST和DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：对象必须是魔法·陷阱卡（包括场上的魔法·陷阱卡）。
function c43898403.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时选择对象：从场上选择1~2张魔法·陷阱卡（不能选自身）作为效果对象，并登记破坏信息。
function c43898403.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43898403.filter(chkc) and chkc~=e:GetHandler() end
	-- 目标检查：确认场上是否存在至少1张符合条件的魔法·陷阱卡可选，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43898403.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 显示选择提示：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1~2张场上符合条件的魔法·陷阱卡作为对象（除去发动效果的卡本身），并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c43898403.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	-- 设置操作信息：宣告本次效果将破坏这些对象卡，供时点及联动效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取出连锁对象中仍与效果关联的卡，并将它们破坏。
function c43898403.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取对象卡组，并筛选出仍与该效果有关联的卡（已离场或不受影响的卡除外）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏筛选出的所有对象卡。
	Duel.Destroy(g,REASON_EFFECT)
end
