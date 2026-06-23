--フォトン・レオ
-- 效果：
-- 这张卡召唤成功时才能发动。对方手卡全部加入卡组洗切。那之后，对方抽出加入卡组的数量的卡。
function c38757297.initial_effect(c)
	-- 这张卡召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38757297,0))  --"重新筹卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c38757297.target)
	e1:SetOperation(c38757297.activate)
	c:RegisterEffect(e1)
end
-- 对方手卡全部加入卡组洗切。
function c38757297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 对方手卡全部加入卡组洗切。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp)
		-- 那之后，对方抽出加入卡组的数量的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	-- 对方手卡全部加入卡组洗切。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 那之后，对方抽出加入卡组的数量的卡。
function c38757297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方手牌区的卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	-- 将对方手牌区的卡全部送入卡组并洗切
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 将对方卡组洗切
	Duel.ShuffleDeck(1-tp)
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 对方抽出加入卡组的数量的卡
	Duel.Draw(1-tp,g:GetCount(),REASON_EFFECT)
end
