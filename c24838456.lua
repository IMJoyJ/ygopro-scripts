--虚無を呼ぶ呪文
-- 效果：
-- 连锁4以后把基本分支付一半才能发动。这张卡的发动时积累的连锁上的全部卡的发动无效并破坏。
function c24838456.initial_effect(c)
	-- 创建效果并设置其类型为发动效果，触发条件为连锁4以后，设置费用和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c24838456.condition)
	e1:SetCost(c24838456.cost)
	e1:SetTarget(c24838456.target)
	e1:SetOperation(c24838456.activate)
	c:RegisterEffect(e1)
end
-- 连锁4以后才能发动
function c24838456.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 连锁序号大于等于3时满足条件
	return Duel.GetCurrentChain()>=3
end
-- 支付一半基本分作为发动费用
function c24838456.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前玩家基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置效果目标，收集连锁中符合条件的卡并设置操作信息
function c24838456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取第i个连锁的效果
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 设置当前处理的连锁的目标卡组
	Duel.SetTargetCard(dg)
	-- 设置将使连锁无效的分类信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	-- 设置将目标卡破坏的分类信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 处理效果发动，使符合条件的连锁无效并破坏对应卡
function c24838456.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取第i个连锁的效果
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER))
			-- 使连锁无效且目标卡与效果相关时加入处理列表
			and Duel.NegateActivation(i) and tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
			dg:AddCard(tc)
		end
	end
	-- 将符合条件的卡破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
