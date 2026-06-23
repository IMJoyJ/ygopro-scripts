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
-- 过滤函数，用于检查场上满足条件的魔法·陷阱卡
function c53046408.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用处理，选择并送入墓地满足条件的魔法·陷阱卡
function c53046408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足费用条件，即场上有至少一张魔法·陷阱卡可以作为费用送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c53046408.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的1到5张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c53046408.costfilter,tp,LOCATION_ONFIELD,0,1,5,e:GetHandler())
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 效果发动时的目标设定，设置回复LP的数量
function c53046408.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 设置连锁处理的目标玩家为效果使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为回复的基本分数量
	Duel.SetTargetParam(ct*1000)
	-- 设置操作信息，表示本次连锁将进行回复基本分的效果处理
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1000)
end
-- 效果发动时的处理函数，执行回复基本分的操作
function c53046408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（即回复的基本分数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数量的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
