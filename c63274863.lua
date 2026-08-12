--星因士 シリウス
-- 效果：
-- 「星因士 天狼星」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以自己墓地5只「星骑士」怪兽为对象才能发动。那5只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c63274863.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以自己墓地5只「星骑士」怪兽为对象才能发动。那5只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63274863,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,63274863)
	e1:SetTarget(c63274863.target)
	e1:SetOperation(c63274863.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c63274863.star_knight_summon_effect=e1
end
-- 过滤自己墓地中可以回到卡组的「星骑士」怪兽
function c63274863.filter(c)
	return c:IsSetCard(0x9c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时的对象选择与可行性检查
function c63274863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63274863.filter(chkc) end
	-- 检查当前玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在5只满足条件的「星骑士」怪兽作为对象
		and Duel.IsExistingTarget(c63274863.filter,tp,LOCATION_GRAVE,0,5,exc) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5只「星骑士」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63274863.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 设置连锁信息，表示该效果包含将这5张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置连锁信息，表示该效果包含抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数
function c63274863.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将作为对象的卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片被送回了主卡组，则洗切该玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
