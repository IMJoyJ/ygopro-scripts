--マジック・プランター
-- 效果：
-- ①：把自己场上1张表侧表示的永续陷阱卡送去墓地才能发动。自己抽2张。
function c1073952.initial_effect(c)
	-- ①：把自己场上1张表侧表示的永续陷阱卡送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1073952.cost)
	e1:SetTarget(c1073952.target)
	e1:SetOperation(c1073952.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示且种类为永续陷阱（类型值0x20004），并且可以作为代价送去墓地的卡。
function c1073952.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20004)==0x20004 and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：先检查是否存在合法代价；若存在，则提示选择一张表侧表示永续陷阱卡并送去墓地，完成代价支付。
function c1073952.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己场上是否存在至少1张符合条件（表侧表示永续陷阱且能作为代价）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1073952.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示，让玩家选择要送去墓地的卡（用于代价支付）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上符合条件的卡中选出1张作为代价。
	local g=Duel.SelectMatchingCard(tp,c1073952.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡以代价形式送去墓地，支付发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标设定函数：检查玩家能否抽2张卡，并记录本次效果的对象玩家和抽卡数量。
function c1073952.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家tp是否可以抽2张卡，若不能则效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为tp，表示抽卡的是该玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 设置操作信息，向系统声明本次连锁包含抽2张卡的效果，供后续处理及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息中取出记录的抽卡玩家和抽卡数量，并执行抽卡。
function c1073952.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡，完成抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
