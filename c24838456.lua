--虚無を呼ぶ呪文
-- 效果：
-- 连锁4以后把基本分支付一半才能发动。这张卡的发动时积累的连锁上的全部卡的发动无效并破坏。
function c24838456.initial_effect(c)
	-- 连锁4以后把基本分支付一半才能发动。这张卡的发动时积累的连锁上的全部卡的发动无效并破坏。
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
-- 效果发动条件判断：当前连锁序号大于等于3，即处于连锁4以后的时点，满足发动条件。
function c24838456.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁序号是否大于等于3，即是否处于连锁4以后的时点。
	return Duel.GetCurrentChain()>=3
end
-- 效果发动代价：支付基本分的一半作为发动代价；chk==0时仅检查代价可支付性，返回true。
function c24838456.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 目标选择与操作信息设定：遍历当前连锁上的所有效果，筛选出魔法·陷阱卡的发动或怪兽效果；ng收集所有满足条件的卡（用于无效），dg收集其中与效果仍相关的卡（用于破坏）；设定对象为dg，并声明无效与破坏的操作信息。
function c24838456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁序号i上的效果对象（Effect），用于判断其类型和关联卡。
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	-- 将dg组设为当前效果的对象，即这些卡是效果处理时可能被破坏的卡。
	Duel.SetTargetCard(dg)
	-- 设置操作信息：声明本效果包含“发动无效”分类，对象为ng组（所有符合条件的连锁卡），数量为ng的卡数。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	-- 设置操作信息：声明本效果包含“破坏”分类，对象为dg组（与效果仍相关的卡），数量为dg的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理：创建破坏组并遍历当前连锁，对符合条件的魔法·陷阱发动或怪兽效果尝试发动无效，并将成功无效且仍与效果相关的卡加入破坏组。
function c24838456.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		-- 获取连锁序号i上的效果对象（Effect），以便取得对应的卡并判断类型。
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER))
			-- 判断条件：若该效果为魔法·陷阱发动或怪兽效果，且发动无效成功，并且该卡与本效果以及原发动效果都仍有关联，则将其加入破坏组。
			and Duel.NegateActivation(i) and tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
			dg:AddCard(tc)
		end
	end
	-- 以效果原因破坏dg组中的全部卡片，即把被无效发动的那些卡破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
