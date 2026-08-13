--フォトン・レオ
-- 效果：
-- 这张卡召唤成功时才能发动。对方手卡全部加入卡组洗切。那之后，对方抽出加入卡组的数量的卡。
function c38757297.initial_effect(c)
	-- 这张卡召唤成功时才能发动。对方手卡全部加入卡组洗切。那之后，对方抽出加入卡组的数量的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38757297,0))  --"重新筹卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c38757297.target)
	e1:SetOperation(c38757297.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：对方可以抽卡，且对方手牌中存在能被卡组效果送回卡组的卡，满足才可发动。
function c38757297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否允许进行抽卡（是否受“不能抽卡”效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp)
		-- 检查对方手牌中是否存在至少1张可以被效果送回卡组的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	-- 设置本次效果的操作信息：将对方手牌送入卡组（不确定具体张数，预计至少1张，目标玩家为对方，位置为手牌），用于卡组/墓地等效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：将对方全部手牌返回卡组并洗切，然后让对方抽出与返回卡组数量相同的卡。
function c38757297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方当前所有手牌，组成一个卡组对象g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	-- 将对象g中的全部手牌以效果原因送回持有者卡组（使用SEQ_DECKSHUFFLE，表示随后进行洗牌）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对方卡组，使回到卡组的卡随机排列。
	Duel.ShuffleDeck(1-tp)
	-- 中断当前效果链，使后续抽卡效果与之前的回卡组/洗切处理分开结算，避免造成错误的时点。
	Duel.BreakEffect()
	-- 让对方抽出与返回卡组数量相同的卡（效果抽卡）。
	Duel.Draw(1-tp,g:GetCount(),REASON_EFFECT)
end
