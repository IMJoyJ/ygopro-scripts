--ジャンク・コレクター
-- 效果：
-- 把场上表侧表示存在的这张卡和自己墓地存在的1张通常陷阱卡从游戏中除外发动。这张卡的效果变成和为这个效果发动而从游戏中除外的通常陷阱卡的效果相同。这个效果在对方回合也能发动。
function c58242947.initial_effect(c)
	-- 把场上表侧表示存在的这张卡和自己墓地存在的1张通常陷阱卡从游戏中除外发动。这张卡的效果变成和为这个效果发动而从游戏中除外的通常陷阱卡的效果相同。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58242947,0))  --"获得并发动墓地的通常陷阱的效果"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e1)
	e1:SetCost(c58242947.cost)
	e1:SetTarget(c58242947.target)
	e1:SetOperation(c58242947.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为代价除外、且可以进行卡片发动的通常陷阱卡
function c58242947.filter(c)
	return c:GetType()==0x4 and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 发动代价的检查：自身是否可以作为代价除外，以及自己墓地是否存在满足条件的通常陷阱卡
function c58242947.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在至少1张满足条件的通常陷阱卡
		and Duel.IsExistingMatchingCard(c58242947.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择一张通常陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(58242947,1))  --"请选择一张通常陷阱卡"
	-- 让玩家选择自己墓地中1张满足条件的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c58242947.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将当前连锁中要复制的陷阱卡效果暂存到以当前连锁号为键的全局表中
	c58242947[Duel.GetCurrentChain()]=te
	g:AddCard(c)
	-- 将自身和选中的通常陷阱卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 复制被除外陷阱卡的效果属性，并执行其Target（选择效果目标等）函数
function c58242947.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前连锁中暂存的被复制陷阱卡的效果
	local te=c58242947[Duel.GetCurrentChain()]
	if chkc then
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,true)
	end
	if chk==0 then return true end
	if not te then return end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，防止该效果被针对陷阱卡发动的卡片连锁响应
	Duel.ClearOperationInfo(0)
end
-- 执行被复制陷阱卡的效果处理（Operation）
function c58242947.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中暂存的被复制陷阱卡的效果
	local te=c58242947[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
