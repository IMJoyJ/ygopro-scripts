--セイクリッド・エスカ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以从自己卡组把1只名字带有「星圣」的怪兽加入手卡。
function c14759024.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以从自己卡组把1只名字带有「星圣」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14759024,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c14759024.tg)
	e1:SetOperation(c14759024.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e2)
	c14759024.star_knight_summon_effect=e1
end
-- 过滤函数，用于检索满足条件的「星圣」怪兽
function c14759024.filter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的处理函数，用于设置效果处理的目标
function c14759024.tg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 判断是否满足效果发动条件，即卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14759024.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置效果处理信息，表示将从卡组检索1张符合条件的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的处理函数，用于执行效果的处理流程
function c14759024.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14759024.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
