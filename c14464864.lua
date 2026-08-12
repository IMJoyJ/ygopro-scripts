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
-- 过滤函数，用于筛选名字带有「极星」的怪兽
function c14464864.filter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动时点处理函数
function c14464864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14464864.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将要操作的卡牌信息为1张卡，位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数
function c14464864.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c14464864.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
