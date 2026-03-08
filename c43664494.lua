--プランキッズ・プランク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张「调皮宝贝」卡才能发动。在自己场上把1只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）特殊召唤。这衍生物不能解放。
-- ②：自己结束阶段以「调皮宝贝捣蛋记」以外的自己墓地3张「调皮宝贝」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c43664494.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：①：从手卡丢弃1张「调皮宝贝」卡才能发动。在自己场上把1只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）特殊召唤。这衍生物不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43664494,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,43664494)
	e2:SetCost(c43664494.tkcost)
	e2:SetTarget(c43664494.tktg)
	e2:SetOperation(c43664494.tkop)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己结束阶段以「调皮宝贝捣蛋记」以外的自己墓地3张「调皮宝贝」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43664494,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,43664495)
	e3:SetCondition(c43664494.drcon)
	e3:SetTarget(c43664494.drtg)
	e3:SetOperation(c43664494.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查手牌中是否存在可丢弃的「调皮宝贝」卡
function c43664494.cfilter(c)
	return c:IsSetCard(0x120) and c:IsDiscardable()
end
-- 效果处理：检查手牌中是否存在可丢弃的「调皮宝贝」卡，若存在则丢弃一张
function c43664494.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查手牌中是否存在至少一张「调皮宝贝」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43664494.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 操作：从手牌中丢弃一张「调皮宝贝」卡
	Duel.DiscardHand(tp,c43664494.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理：检查是否可以特殊召唤衍生物，若可以则设置操作信息
function c43664494.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件判断：检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43664495,0x120,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP) end
	-- 设置操作信息：将要特殊召唤的衍生物数量设为1
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤的怪兽数量设为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果处理：检查是否可以特殊召唤衍生物，若不可以则返回
function c43664494.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 条件判断：检查场上是否没有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 条件判断：检查是否无法特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,43664495,0x120,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP) then return end
	-- 操作：创建一张「调皮宝贝衍生物」
	local token=Duel.CreateToken(tp,43664495)
	-- 操作：将衍生物特殊召唤到场上
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 效果原文：①：从手卡丢弃1张「调皮宝贝」卡才能发动。在自己场上把1只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）特殊召唤。这衍生物不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	token:RegisterEffect(e2,true)
	-- 操作：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果处理：判断是否为当前回合玩家
function c43664494.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：检查墓地中的卡是否为「调皮宝贝」且不是此卡
function c43664494.tdfilter(c)
	return c:IsSetCard(0x120) and not c:IsCode(43664494) and c:IsAbleToDeck()
end
-- 效果处理：检查是否可以发动效果，若可以则设置操作信息
function c43664494.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43664494.tdfilter(chkc) end
	-- 条件判断：检查是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 条件判断：检查墓地中是否存在至少三张符合条件的卡
		and Duel.IsExistingTarget(c43664494.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 操作：选择三张符合条件的卡
	local g=Duel.SelectTarget(tp,c43664494.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将要返回卡组的卡数量设为3
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：将要抽卡数量设为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：将选中的卡返回卡组并洗切，之后抽一张卡
function c43664494.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 操作：获取连锁中目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 操作：将卡返回卡组并洗切
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 操作：获取实际操作的卡组
	local g=Duel.GetOperatedGroup()
	-- 操作：若返回卡组的卡存在则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 操作：中断当前效果
		Duel.BreakEffect()
		-- 操作：从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
