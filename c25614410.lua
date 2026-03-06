--HEROの遺産
-- 效果：
-- 「英雄的遗产」在1回合只能发动1张。
-- ①：让需以「英雄」怪兽为融合素材的2只融合怪兽从自己墓地回到额外卡组才能发动。自己从卡组抽3张。
function c25614410.initial_effect(c)
	-- 「英雄的遗产」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,25614410+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c25614410.cost)
	e1:SetTarget(c25614410.target)
	e1:SetOperation(c25614410.activate)
	c:RegisterEffect(e1)
end
-- 检测是否为融合怪兽且以「英雄」怪兽为融合素材
function c25614410.cfilter(c)
	-- 需以「英雄」怪兽为融合素材的2只融合怪兽
	return aux.IsMaterialListSetCard(c,0x8) and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost()
end
-- 检索满足条件的2只融合怪兽并将其送回额外卡组作为发动代价
function c25614410.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2张满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25614410.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2张满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c25614410.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的融合怪兽送回额外卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 设置效果发动时的抽卡目标
function c25614410.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为3
	Duel.SetTargetParam(3)
	-- 设置效果操作信息为抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 执行效果发动时的抽卡处理
function c25614410.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
