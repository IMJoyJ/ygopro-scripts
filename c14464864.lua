--神の桎梏グレイプニル
-- 效果：
-- 从自己卡组把1只名字带有「极星」的怪兽加入手卡。
function c14464864.initial_effect(c)
	-- 从自己卡组把1只名字带有「极星」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14464864.target)
	e1:SetOperation(c14464864.activate)
	c:RegisterEffect(e1)
end
-- 筛选出满足条件的卡：卡名含有「极星」的怪兽卡，且能够加入手卡。
function c14464864.filter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设定效果发动的条件与操作信息：若卡组存在符合条件的「极星」怪兽则可发动，并设置将进行回手牌处理。
function c14464864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己卡组是否存在至少1只满足筛选条件的「极星」怪兽，作为发动的合法性判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c14464864.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表明本效果处理时会从卡组将1张卡加入手牌，供连锁判定等规则使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，由玩家从自己卡组选择1只符合条件的「极星」怪兽加入手卡，并展示给对方确认。
function c14464864.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡，显示“请选择要加入手牌的卡”的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选并选择1张满足filter条件的「极星」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c14464864.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡以效果原因加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
