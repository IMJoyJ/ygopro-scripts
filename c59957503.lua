--キャッシュバック
-- 效果：
-- 对方支付基本分发动的效果怪兽的效果·魔法·陷阱卡的发动无效，那张卡回到持有者卡组。
function c59957503.initial_effect(c)
	-- 效果怪兽的效果·魔法·陷阱卡的发动无效，那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c59957503.condition)
	e1:SetTarget(c59957503.target)
	e1:SetOperation(c59957503.activate)
	c:RegisterEffect(e1)
	if not c59957503.global_check then
		c59957503.global_check=true
		c59957503[0]=nil
		-- 对方支付基本分发动的
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c59957503.checkop)
		-- 将支付LP检测效果注册为全局效果，使任何玩家支付基本分时都能触发checkop记录。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义checkop回调：在支付基本分发生时，若处于连锁处理中，则记录当前连锁的ID，用于识别该次发动是否由支付基本分引起。
function c59957503.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号；若返回值大于0，说明支付基本分发生在连锁处理中。
	local cid=Duel.GetCurrentChain()
	if cid>0 then
		-- 把当前连锁的唯一ID存入全局表c59957503[0]，供后续发动无效条件判断使用。
		c59957503[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
-- 定义本卡的发动条件：必须是对方支付基本分后发动的怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效。
function c59957503.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前连锁由对方发动，且其连锁ID与之前支付基本分时记录的连锁ID一致，即满足“对方支付基本分发动的”前提。
	return rp==1-tp and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==c59957503[0]
		-- 进一步确认被连锁的是怪兽效果或魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该发动处于可被无效的状态。
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 定义发动时的目标选择与操作信息预设：合法时设定无效发动和回卡组的处理信息。
function c59957503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认被连锁的卡在发动被无效后可以送回持有者卡组（符合“那张卡回到持有者卡组”的回收条件）。
	if chk==0 then return aux.ndcon(tp,re) end
	-- 设置操作信息为“无效发动”，处理对象为当前连锁中的发动卡/效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 若发动卡仍与效果关联，则再设置操作信息为“送回卡组”，确保无效后将其弹回持有者卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
-- 定义效果处理操作：实际无效对方那次发动，并将对应卡片送回持有者卡组。
function c59957503.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 尝试无效该连锁；成功后且发动卡仍与效果关联，才继续执行回卡组的处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将这张卡以效果原因送回持有者卡组，并标记为需要洗牌（弹回卡组并洗牌）。
		Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
