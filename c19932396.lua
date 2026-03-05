--侵略の一手
-- 效果：
-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。从自己卡组抽1张卡。
function c19932396.initial_effect(c)
	-- 效果原文内容：让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19932396.cost)
	e1:SetTarget(c19932396.target)
	e1:SetOperation(c19932396.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的怪兽（表侧表示、名字带有「侵入魔鬼」、上级召唤成功、可以作为费用送入手卡）
function c19932396.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
		and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- 效果作用：检查是否满足费用条件并选择1只符合条件的怪兽送入手卡
function c19932396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19932396.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择要送入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果作用：选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c19932396.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：将选中的怪兽送入手卡作为费用
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果作用：检查玩家是否可以抽卡并设置抽卡信息
function c19932396.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 效果作用：设置抽卡的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 效果作用：设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用：执行抽卡效果
function c19932396.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
