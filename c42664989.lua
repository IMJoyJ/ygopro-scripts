--天よりの宝札
-- 效果：
-- ①：把自己的手卡·场上的卡全部除外才能发动。自己直到手卡变成2张为止从卡组抽卡。
function c42664989.initial_effect(c)
	-- ①：把自己的手卡·场上的卡全部除外才能发动。自己直到手卡变成2张为止从卡组抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42664989.cost)
	e1:SetTarget(c42664989.target)
	e1:SetOperation(c42664989.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组并将其除外作为费用
function c42664989.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌和场上的所有卡作为目标
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 and g:GetCount()==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) end
	-- 将目标卡除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查玩家是否可以抽卡并设置抽卡数量
function c42664989.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp) end
	-- 获取玩家当前手牌数量
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为需要抽卡的数量
	Duel.SetTargetParam(2-ht)
	-- 设置连锁的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2-ht)
end
-- 执行抽卡效果
function c42664989.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家当前手牌数量
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<2 then
		-- 让目标玩家从卡组抽卡
		Duel.Draw(p,2-ht,REASON_EFFECT)
	end
end
