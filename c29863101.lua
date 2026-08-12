--バスター・テレポート
-- 效果：
-- 从自己手卡让1只名字带有「/爆裂体」的怪兽回到卡组发动。从自己卡组抽2张卡。
function c29863101.initial_effect(c)
	-- 从自己手卡让1只名字带有「/爆裂体」的怪兽回到卡组发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c29863101.cost)
	e1:SetTarget(c29863101.target)
	e1:SetOperation(c29863101.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中名字带有「/爆裂体」且可以送回卡组的怪兽
function c29863101.filter(c)
	return c:IsSetCard(0x104f) and c:IsAbleToDeck()
end
-- 效果发动时的费用处理，检查手卡是否存在符合条件的怪兽并选择送回卡组
function c29863101.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张名字带有「/爆裂体」且可以送回卡组的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29863101.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张手卡中名字带有「/爆裂体」且可以送回卡组的怪兽
	local g=Duel.SelectMatchingCard(tp,c29863101.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 确认对方玩家所选择的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 将所选怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 设置效果发动时的处理目标，确认玩家可以抽2张卡
function c29863101.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置效果操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数，执行抽卡效果
function c29863101.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
