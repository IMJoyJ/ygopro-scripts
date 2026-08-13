--HEROの遺産
-- 效果：
-- 「英雄的遗产」在1回合只能发动1张。
-- ①：让需以「英雄」怪兽为融合素材的2只融合怪兽从自己墓地回到额外卡组才能发动。自己从卡组抽3张。
function c25614410.initial_effect(c)
	-- 「英雄的遗产」在1回合只能发动1张。①：让需以「英雄」怪兽为融合素材的2只融合怪兽从自己墓地回到额外卡组才能发动。自己从卡组抽3张。
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
-- 定义代价筛选函数：判断墓地中的怪兽是否是以「英雄」怪兽为融合素材的融合怪兽，并且可以作为代价返回额外卡组。
function c25614410.cfilter(c)
	-- 具体筛选条件：该卡是以「英雄」怪兽为融合素材的融合怪兽，且可以作为代价返回额外卡组（主卡组的灵摆怪兽除外）。
	return aux.IsMaterialListSetCard(c,0x8) and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost()
end
-- 代价函数整体：先检查能否从己方墓地选出2只满足条件的融合怪兽，再提示玩家选择，最后将选择的卡返回持有者的额外卡组作为发动代价。
function c25614410.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查代价是否可行：己方墓地是否存在至少2张满足cfilter条件的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25614410.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出选择提示，让玩家从墓地选择要返回卡组的卡（实际是返回额外卡组的融合怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从己方墓地选择且仅选择2张满足条件（素材字段为「英雄」的融合怪兽且可作为代价返回额外卡组）的卡。
	local g=Duel.SelectMatchingCard(tp,c25614410.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张融合怪兽以代价形式送回持有者的卡组（融合怪兽实际返回额外卡组），并触发洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 目标设定函数整体：不取对象，而是指定抽卡的玩家和数量；检查玩家能否抽3张，并设置连锁信息供处理阶段使用。
function c25614410.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：此时需要确认发动玩家可以被效果抽取3张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 将当前连锁的『对象玩家』设为发动玩家，以便处理阶段知道由谁抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的『对象参数』设为3，表示效果处理时要抽3张卡。
	Duel.SetTargetParam(3)
	-- 登记本次效果操作信息：类别为抽卡，对象玩家为发动者，处理时抽3张，用于连锁判定和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理函数整体：根据发动时保存的目标玩家和抽卡数量，执行抽卡操作。
function c25614410.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和参数数值（即抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 实际执行抽卡：让玩家p抽取d张卡，本次抽卡由卡片效果产生。
	Duel.Draw(p,d,REASON_EFFECT)
end
