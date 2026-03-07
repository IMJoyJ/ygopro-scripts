--武神－ヤマト
-- 效果：
-- ①：「武神-倭」在自己场上只能有1只表侧表示存在。
-- ②：自己结束阶段才能发动。从卡组把1只「武神」怪兽加入手卡。那之后，选自己1张手卡送去墓地。
function c32339440.initial_effect(c)
	c:SetUniqueOnField(1,0,32339440)
	-- 效果原文：②：自己结束阶段才能发动。从卡组把1只「武神」怪兽加入手卡。那之后，选自己1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32339440,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c32339440.thcon)
	e1:SetTarget(c32339440.thtg)
	e1:SetOperation(c32339440.thop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为自己的结束阶段
function c32339440.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：定义检索卡片的过滤条件，即「武神」怪兽且能加入手牌
function c32339440.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：设置效果的发动条件和处理目标，检查卡组是否存在满足条件的怪兽
function c32339440.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32339440.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁处理信息，指定将要从卡组加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行效果处理，包括选择卡组中的「武神」怪兽加入手牌并丢弃1张手卡
function c32339440.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组中选择1张满足条件的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c32339440.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 效果作用：确认选择的卡已成功加入手牌后执行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 效果作用：向对方确认所选加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 效果作用：洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 效果作用：中断当前效果处理，防止连锁错时
		Duel.BreakEffect()
		-- 效果作用：丢弃自己1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
	end
end
