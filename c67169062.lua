--貪欲な壺
-- 效果：
-- ①：以自己墓地5只怪兽为对象才能发动。那5只怪兽回到卡组。那之后，自己抽2张。
function c67169062.initial_effect(c)
	-- ①：以自己墓地5只怪兽为对象才能发动。那5只怪兽回到卡组。那之后，自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c67169062.target)
	e1:SetOperation(c67169062.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的怪兽且能回到卡组
function c67169062.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动时的对象合法性检测与可行性判定
function c67169062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67169062.filter(chkc) end
	-- 判定发动玩家当前是否能够进行效果抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 判定自己墓地是否存在5只满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c67169062.filter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c67169062.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 设置操作信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：将对象怪兽送回卡组并洗牌，若5张卡全部成功回到卡组/额外卡组，则抽2张卡
function c67169062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将作为对象的卡片送回持有者的卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片被送回了主卡组，则洗切发动玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组处理不视为同时进行
		Duel.BreakEffect()
		-- 玩家因效果抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
