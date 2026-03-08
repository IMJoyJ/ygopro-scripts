--ツインツイスター
-- 效果：
-- ①：丢弃1张手卡，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c43898403.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
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
-- 效果作用：检查是否可以丢弃1张手卡作为发动代价
function c43898403.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：执行丢弃1张手卡的操作，丢弃原因包含费用和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义过滤函数，用于筛选魔法或陷阱类型的卡片
function c43898403.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：设置效果的目标选择逻辑，允许选择场上1到2张魔法或陷阱卡
function c43898403.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43898403.filter(chkc) and chkc~=e:GetHandler() end
	-- 效果作用：判断场上是否存在满足条件的魔法或陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c43898403.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：向玩家发送提示信息，提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上1到2张魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c43898403.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	-- 效果作用：设置操作信息，表明此效果将破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：处理效果的发动，对选定的目标卡片进行破坏
function c43898403.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中选定的目标卡片，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：以效果原因破坏选定的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
