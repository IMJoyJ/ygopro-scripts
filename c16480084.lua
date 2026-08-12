--エヴォルダー・ペルタ
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的守备力上升500。那之后，这张卡被战斗破坏的场合，可以从卡组把1只名字带有「进化虫」的怪兽加入手卡。
function c16480084.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的守备力上升500。那之后，这张卡被战斗破坏的场合，可以从卡组把1只名字带有「进化虫」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 判断特殊召唤是否由名字带有「进化虫」的怪兽的效果造成
	e1:SetCondition(aux.evospcon)
	e1:SetOperation(c16480084.operation)
	c:RegisterEffect(e1)
end
-- 效果处理：使此卡守备力上升500，并设置检索效果
function c16480084.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 使此卡守备力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 设置被战斗破坏时的检索效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16480084,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c16480084.schcon)
	e2:SetTarget(c16480084.schtg)
	e2:SetOperation(c16480084.schop)
	e2:SetReset(RESET_EVENT+0x7b0000)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因战斗破坏而进入墓地
function c16480084.schcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：检索卡组中名字带有「进化虫」的怪兽
function c16480084.sfilter(c)
	return c:IsSetCard(0x304e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标：从卡组检索1只名字带有「进化虫」的怪兽加入手牌
function c16480084.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c16480084.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张名字带有「进化虫」的怪兽从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并加入手牌
function c16480084.schop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张名字带有「进化虫」的怪兽
	local g=Duel.SelectMatchingCard(tp,c16480084.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
