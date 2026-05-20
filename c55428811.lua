--ホープ・オブ・フィフス
-- 效果：
-- 选择自己墓地存在的5张名字带有「元素英雄」的卡，加入卡组洗切。之后，从自己卡组抽2张卡。这张卡的发动时自己场上以及手卡没有其他卡存在的场合抽3张卡。
function c55428811.initial_effect(c)
	-- 选择自己墓地存在的5张名字带有「元素英雄」的卡，加入卡组洗切。之后，从自己卡组抽2张卡。这张卡的发动时自己场上以及手卡没有其他卡存在的场合抽3张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55428811.target)
	e1:SetOperation(c55428811.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的「元素英雄」卡片且能回到卡组
function c55428811.filter(c)
	return c:IsSetCard(0x3008) and c:IsAbleToDeck()
end
-- 效果发动的目标选择与合法性检测
function c55428811.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55428811.filter(chkc) end
	local dc=2
	-- 检查发动时自己场上及手卡是否没有其他卡（不计这张卡本身），若满足则将抽卡张数设为3，否则为2
	if not Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) then dc=3 end
	-- 检查玩家是否可以抽指定张数的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,dc)
		-- 检查自己墓地是否存在至少5张满足过滤条件的卡作为效果对象
		and Duel.IsExistingTarget(c55428811.filter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5张满足过滤条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c55428811.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	e:SetLabel(dc)
	-- 设置操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：玩家抽指定张数的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,dc)
end
-- 效果处理函数：将对象卡送回卡组并抽卡
function c55428811.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将对象卡片送回持有者卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若有卡片被送回主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 玩家抽指定张数（2张或3张）的卡
		Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
	end
end
