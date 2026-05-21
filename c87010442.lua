--レガシーハンター
-- 效果：
-- 当这张卡战斗破坏里侧守备表示的怪兽并将其送去墓地时，对方随机将1张手卡弹回其卡组。
function c87010442.initial_effect(c)
	-- 当这张卡战斗破坏里侧守备表示的怪兽并将其送去墓地时，对方随机将1张手卡弹回其卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87010442,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c87010442.condition)
	e1:SetTarget(c87010442.target)
	e1:SetOperation(c87010442.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否战斗破坏了里侧守备表示的怪兽并送去墓地，且自身仍在场并与战斗关联
function c87010442.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:GetBattlePosition()==POS_FACEDOWN_DEFENSE and c:IsRelateToBattle() and c:IsFaceup()
end
-- 效果发动的目标确认，必发效果直接返回true，并设置将对方手牌送回卡组的操作信息
function c87010442.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表示将对方手牌中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理的执行，获取对方手牌，若有则随机选择1张洗回卡组
function c87010442.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家的手牌卡片组
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的对方手牌送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
