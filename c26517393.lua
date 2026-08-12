--裏風の精霊
-- 效果：
-- ①：这张卡召唤的场合才能发动。从卡组把1只反转怪兽加入手卡。
function c26517393.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从卡组把1只反转怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c26517393.tg)
	e1:SetOperation(c26517393.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡组中是否存在满足条件的反转怪兽（可以送去手卡）
function c26517393.filter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end
-- 效果的处理目标函数，检查卡组中是否存在满足条件的反转怪兽
function c26517393.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在至少1张满足条件的反转怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26517393.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张反转怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，选择并处理目标反转怪兽加入手牌
function c26517393.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,c26517393.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的反转怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被选中的反转怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
