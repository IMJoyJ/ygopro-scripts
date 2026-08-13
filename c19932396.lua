--侵略の一手
-- 效果：
-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。从自己卡组抽1张卡。
function c19932396.initial_effect(c)
	-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19932396.cost)
	e1:SetTarget(c19932396.target)
	e1:SetOperation(c19932396.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价的筛选条件：怪兽需表侧表示、属于「侵入魔鬼」系列、通过上级召唤成功、且可以作为代价返回手卡。
function c19932396.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
		and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- 发动代价处理：从己方场上选择1只满足条件的「侵入魔鬼」上级召唤怪兽返回手卡，作为发动此卡的代价。
function c19932396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认己方场上是否存在至少1只满足筛选条件的怪兽，若无则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19932396.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示：让玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从己方场上选择1只符合条件的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c19932396.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将所选怪兽返回持有者手卡，该移动的原因记为代价（REASON_COST）。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果发动时的目标设定：把抽卡的玩家和数量登记为效果信息。
function c19932396.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认己方当前可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果处理时的抽卡玩家设置为己方（tp）。
	Duel.SetTargetPlayer(tp)
	-- 将效果处理时的抽卡数设置为1。
	Duel.SetTargetParam(1)
	-- 登记本次连锁的抽卡操作信息，便于其他卡（如星尘龙等）进行效果响应与判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：根据连锁中登记的目标玩家和抽卡数执行抽卡。
function c19932396.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中读取之前登记的目标玩家和抽卡数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果处理为原因抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
