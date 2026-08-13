--エヴォルダー・ペルタ
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的守备力上升500。那之后，这张卡被战斗破坏的场合，可以从卡组把1只名字带有「进化虫」的怪兽加入手卡。
function c16480084.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，这张卡的守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置触发条件：仅当此卡因名字带有「进化虫」的怪兽的效果成功特殊召唤时，该效果才可发动。
	e1:SetCondition(aux.evospcon)
	e1:SetOperation(c16480084.operation)
	c:RegisterEffect(e1)
end
-- 特殊召唤成功时的处理：若此卡仍与效果关联，则先使守备力上升500，再为其登记后续被战斗破坏时可从卡组检索「进化虫」怪兽的效果。
function c16480084.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这张卡的守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 那之后，这张卡被战斗破坏的场合，可以从卡组把1只名字带有「进化虫」的怪兽加入手卡。
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
-- 检索效果发动条件：此卡位于墓地，且是被战斗破坏。
function c16480084.schcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义可检索的卡：卡组中名字带有「进化虫」的怪兽且可以被加入手卡。
function c16480084.sfilter(c)
	return c:IsSetCard(0x304e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动与目标设定：确认卡组存在符合条件的「进化虫」怪兽，并设置本次操作是将1张卡从卡组加入手卡。
function c16480084.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：卡组中是否存在至少1张满足检索条件的「进化虫」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16480084.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入手卡（检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1张符合条件的「进化虫」怪兽加入手卡，并让对方确认。
function c16480084.schop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示文字为：请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中筛选并选择1张满足条件的「进化虫」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16480084.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡以效果原因加入手卡（卡组检索到手牌）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
