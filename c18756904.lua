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
-- 过滤函数，检查自己场上是否存在满足条件的怪兽（表侧表示、非效果怪兽、可作为墓地代价）
function c18756904.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost()
end
-- 效果处理的费用支付阶段，检查自己场上是否存在满足条件的怪兽并选择将其送去墓地
function c18756904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18756904.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c18756904.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理的目标设定阶段，检查玩家是否可以抽2张卡并设置抽卡信息
function c18756904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置效果操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理的发动阶段，从连锁信息中获取目标玩家和抽卡数量并执行抽卡
function c18756904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
