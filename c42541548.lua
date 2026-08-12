--鬼ゴブリン
-- 效果：
-- 只要这张卡在自己场上以表侧表示存在，在自己回合的结束阶段时，可以将1张通常怪兽卡从手卡放回卡组最下方，再从卡组抽1张卡。此效果每回合只能使用1次。
function c42541548.initial_effect(c)
	-- 创建一个诱发选发效果，用于在结束阶段时发动，效果描述为“交换”，属于抽卡效果，影响玩家，类型为场地方位触发效果，触发时机为结束阶段，适用区域为主怪兽区，每回合只能发动一次
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
-- 判断是否为自己的回合
function c42541548.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数，用于筛选手牌中可以送回卡组的通常怪兽
function c42541548.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeckAsCost()
end
-- 设置效果的发动费用，需要从手牌中选择一张通常怪兽送回卡组底端
function c42541548.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42541548.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张手牌
	local g=Duel.SelectMatchingCard(tp,c42541548.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将所选的卡送回卡组底端
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 设置效果的目标，检查是否可以抽卡
function c42541548.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查效果持有者是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为效果持有者
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡效果，目标为效果持有者抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 设置效果的处理函数，执行抽卡操作
function c42541548.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取连锁中设定的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
