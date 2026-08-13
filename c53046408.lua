--非常食
-- 效果：
-- ①：把这张卡以外的自己场上的魔法·陷阱卡任意数量送去墓地才能发动。自己回复因为这张卡发动而送去墓地的卡数量×1000基本分。
function c53046408.initial_effect(c)
	-- ①：把这张卡以外的自己场上的魔法·陷阱卡任意数量送去墓地才能发动。自己回复因为这张卡发动而送去墓地的卡数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c53046408.cost)
	e1:SetTarget(c53046408.target)
	e1:SetOperation(c53046408.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为发动代价送去墓地的卡：必须是魔法·陷阱卡，且允许作为代价送去墓地（即满足“这张卡以外的自己场上的魔法·陷阱卡”条件）。
function c53046408.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 代价处理：先检查是否存在可送墓的卡；若有，则让玩家从自己场上选择1～5张（任意数量）魔法·陷阱卡（不含自身）作为代价送去墓地，并记录实际送墓数量供后续回复使用。
function c53046408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价发动判定：若cost检测阶段chk==0，检查自己场上是否存在至少1张满足costfilter的卡（即可以作为代价送去墓地的魔法·陷阱卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c53046408.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 弹出选择提示消息，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上选择1～5张满足costfilter且不是非常食自身的魔法·陷阱卡作为发动代价（对应“任意数量”）。
	local g=Duel.SelectMatchingCard(tp,c53046408.costfilter,tp,LOCATION_ONFIELD,0,1,5,e:GetHandler())
	-- 将选中的卡作为代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果发动时的目标设定：取得发送的卡数量，将回复对象玩家设为自身，回复数值设为数量×1000，并登记本次连锁的回复操作信息。
function c53046408.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 将本次连锁的对象玩家设置为发动者tp（即自己），表示回复LP的玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设置为ct*1000，即回复的基本分数值。
	Duel.SetTargetParam(ct*1000)
	-- 登记操作信息：预计执行CATEGORY_RECOVER回复，回复目标玩家为tp，回复数值为ct*1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1000)
end
-- 效果处理时的操作：从连锁信息中取出之前设置的目标玩家和参数，然后让该玩家回复对应数值的LP。
function c53046408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中设置的目标玩家（CHAININFO_TARGET_PLAYER）和目标参数（CHAININFO_TARGET_PARAM），即回复玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p回复d点LP。
	Duel.Recover(p,d,REASON_EFFECT)
end
