--鬼ゴブリン
-- 效果：
-- 只要这张卡在自己场上以表侧表示存在，在自己回合的结束阶段时，可以将1张通常怪兽卡从手卡放回卡组最下方，再从卡组抽1张卡。此效果每回合只能使用1次。
function c42541548.initial_effect(c)
	-- 对应效果原文：只要这张卡在自己场上以表侧表示存在，在自己回合的结束阶段时，可以将1张通常怪兽卡从手卡放回卡组最下方，再从卡组抽1张卡。此效果每回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42541548,0))  --"交换"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c42541548.drcon)
	e1:SetCost(c42541548.drcost)
	e1:SetTarget(c42541548.drtg)
	e1:SetOperation(c42541548.drop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前回合玩家必须为这张卡的控制者（即‘自己回合的结束阶段’）。满足才可发动。
function c42541548.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否等于效果发动方tp，若是则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：用于筛选手牌中满足‘通常怪兽卡’且‘可以作为代价返回卡组’的卡片。
function c42541548.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeckAsCost()
end
-- 代价处理：从手牌选择1张通常怪兽卡，向对方确认后以代价形式返回卡组最下方。
function c42541548.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认己方手牌是否存在至少1张符合条件的通常怪兽卡，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42541548.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示信息，提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌中选择1张符合条件的通常怪兽卡，并作为代价对象。
	local g=Duel.SelectMatchingCard(tp,c42541548.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡片展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的卡片以代价形式送回持有者卡组最下方（SEQ_DECKBOTTOM）。因为player为nil，返回持有者卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果发动时的目标设定：以己方玩家为对象，设定抽卡数量为1，并声明此次操作将执行抽卡效果。
function c42541548.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法检查：确认己方玩家可以抽1张卡（未受‘不能抽卡’效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁的效果对象玩家设置为己方（tp），表示后续抽卡的执行者。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的效果参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：声明本连锁将执行抽卡效果，目标玩家为tp，预计抽1张卡；因抽卡数量确定且对象为玩家，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：若效果发动者在场上表侧表示且与效果关联，则根据连锁记录的目标玩家和抽卡数量执行抽卡。
function c42541548.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 从当前连锁信息中取出目标玩家p和抽卡数量d，供后续抽卡使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成‘从卡组抽1张卡’的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
