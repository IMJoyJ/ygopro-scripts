--馬の骨の対価
-- 效果：
-- ①：把效果怪兽以外的自己场上1只表侧表示怪兽送去墓地才能发动。自己从卡组抽2张。
function c18756904.initial_effect(c)
	-- ①：把效果怪兽以外的自己场上1只表侧表示怪兽送去墓地才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c18756904.cost)
	e1:SetTarget(c18756904.target)
	e1:SetOperation(c18756904.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为代价的怪兽：必须是表侧表示、不是效果怪兽，并且能够作为代价送去墓地。
function c18756904.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost()
end
-- 代价处理：支付代价时，从自己场上选择1只满足条件的表侧表示怪兽（效果怪兽以外）并送去墓地。
function c18756904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己场上是否存在至少1只满足条件且能作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18756904.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容是“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足条件的表侧表示怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c18756904.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽以代价原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动目标设定：登记抽卡对象玩家为自己、抽卡数量为2，并设置抽卡效果的操作信息。
function c18756904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己是否能够抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设为自己，表示抽卡效果作用于自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2，表示抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 登记抽卡操作信息：效果处理时由自己抽2张卡，用于连锁检测和效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取出对象玩家和抽卡数量，让该玩家执行抽卡。
function c18756904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象玩家和抽卡参数，以确定抽卡对象和数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽取对应数量的卡，完成“自己从卡组抽2张”的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
