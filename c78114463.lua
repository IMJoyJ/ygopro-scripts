--神の密告
-- 效果：
-- 这张卡也能把自己场上1张其他的里侧表示的陷阱卡给对方观看，在盖放的回合发动。
-- ①：魔法·陷阱卡发动时，可以从以下选择1个发动。
-- ●支付1500基本分才能发动。那个发动无效并破坏。这个回合，双方不能把破坏的那张卡以及原本卡名和那张卡相同的卡的效果发动。
-- ●支付3000基本分才能发动。那个发动无效并除外。那之后，对方把原本卡名和这个效果除外的卡相同的卡从自身的手卡·卡组全部除外。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包含魔法·陷阱发动时无效的效果，以及在盖放回合发动的效果。
function s.initial_effect(c)
	-- ①：魔法·陷阱卡发动时，可以从以下选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1张其他的里侧表示的陷阱卡给对方观看，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))  --"适用「神之密告」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.accon)
	e2:SetCost(s.accost)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为魔法·陷阱卡的发动，且该发动可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义效果发动的代价函数，处理不同分支的LP支付。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1500基本分。
	local b1=Duel.CheckLPCost(tp,1500)
	-- 检查玩家是否能支付3000基本分，且能进行除外操作。
	local b2=Duel.CheckLPCost(tp,3000) and Duel.IsPlayerCanRemove(tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择要发动的效果分支。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"无效并破坏"
			{b2,aux.Stringid(id,2),2})  --"无效并除外"
	end
	e:SetLabel(op)
	if op==1 then
		-- 让玩家支付1500基本分。
		Duel.PayLPCost(tp,1500)
	elseif op==2 then
		-- 让玩家支付3000基本分。
		Duel.PayLPCost(tp,3000)
	end
end
-- 定义效果的目标处理函数，根据选择的分支设置对应的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=true
	-- 检查玩家是否能进行除外操作。
	local b2=Duel.IsPlayerCanRemove(tp)
	-- 设置当前连锁的操作信息为：使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local op=0
	if not e:IsCostChecked() then
		-- 若未在代价阶段选择分支，则在此让玩家选择要发动的效果分支。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"无效并破坏"
			{b2,aux.Stringid(id,2),2})  --"无效并除外"
	else
		op=e:GetLabel()
	end
	e:SetLabel(op)
	if op==1 then
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			-- 设置当前连锁的操作信息为：破坏目标卡片。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	else
		if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
			-- 设置当前连锁的操作信息为：除外目标卡片。
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		end
	end
end
-- 定义过滤函数，用于筛选对方手卡·卡组中与被除外卡片原本卡名相同的卡。
function s.rmfilter(c,tp,tc)
	return c:IsAbleToRemove(tp) and c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 定义效果处理函数，根据选择的分支执行无效并破坏（加限制）或无效并除外（除外同名卡）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 使该魔法·陷阱卡的发动无效，并检查该卡是否仍存在于连锁中。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev)
			-- 将该卡破坏，并检查是否成功破坏。
			and Duel.Destroy(eg,REASON_EFFECT)~=0 then
			-- 这个回合，双方不能把破坏的那张卡以及原本卡名和那张卡相同的卡的效果发动。/那之后，对方把原本卡名和这个效果除外的卡相同的卡从自身的手卡·卡组全部除外。/这张卡也能把自己场上1张其他的里侧表示的陷阱卡给对方观看，在盖放的回合发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,1)
			e1:SetValue(s.aclimit)
			e1:SetLabelObject(re:GetHandler())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 在全局注册该回合内禁止双方发动被破坏卡片及其同名卡效果的限制。
			Duel.RegisterEffect(e1,tp)
		end
	elseif e:GetLabel()==2 then
		-- 使该魔法·陷阱卡的发动无效，并检查该卡是否仍存在于连锁中。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev)
			-- 将该卡除外，并检查是否成功除外。
			and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 获取对方手卡·卡组中所有与被除外卡片原本卡名相同的卡片组。
			local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil,1-tp,re:GetHandler())
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的除外处理不与前面的除外同时进行。
				Duel.BreakEffect()
				-- 将对方手卡·卡组中找到的同名卡全部除外。
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT,1-tp)
			end
		end
	end
end
-- 定义限制效果发动的过滤函数，匹配与被破坏卡片原本卡名相同的卡。
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 定义在盖放回合发动的条件函数，检查此卡是否在盖放回合且在场上。
function s.accon(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 定义过滤函数，用于筛选自己场上里侧表示的陷阱卡。
function s.cfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_TRAP)
end
-- 定义在盖放回合发动的代价函数，处理给对方确认里侧陷阱卡的操作。
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的里侧表示的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择给对方确认的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择自己场上1张除这张卡以外的里侧表示的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
	-- 将选择的卡给对方确认。
	Duel.ConfirmCards(1-tp,g)
end
