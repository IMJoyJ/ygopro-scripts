--報復の隠し歯
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。选自己场上盖放的2张卡破坏，那次攻击无效。并且，这个效果破坏送去墓地的卡之中有怪兽卡的场合，再选那之内的1只。持有选的怪兽的守备力以下的攻击力的对方场上的怪兽全部破坏，那之后变成这个回合的结束阶段。
function c47128571.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。①：自己或者对方的怪兽的攻击宣言时才能发动。选自己场上盖放的2张卡破坏，那次攻击无效。并且，这个效果破坏送去墓地的卡之中有怪兽卡的场合，再选那之内的1只。持有选的怪兽的守备力以下的攻击力的对方场上的怪兽全部破坏，那之后变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,47128571+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c47128571.target)
	e1:SetOperation(c47128571.activate)
	c:RegisterEffect(e1)
end
-- 目标函数整体：判定发动条件（自己场上有2张以上里侧表示的可破坏的卡）、登记要破坏的卡的信息、设置不能连锁的限制。
function c47128571.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己场上除这张卡以外存在至少2张里侧表示的卡才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,e:GetHandler()) end
	-- 取得自己场上全部里侧表示的卡，作为可能破坏对象的集合用于操作信息。
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息：预告本次效果将破坏2张卡，候选为自己场上所有里侧表示的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制为始终拒绝，使这张卡发动后任何魔法·陷阱·怪兽效果都不能连锁发动。
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 定义破坏筛选条件：对方场上的表侧表示怪兽的攻击力不高于指定怪兽的守备力。
function c47128571.desfilter(c,def)
	return c:IsFaceup() and c:GetAttack()<=def
end
-- 定义墓地怪兽筛选条件：被破坏的卡中为怪兽且不是连接怪兽，且对方场上有攻击力不超过其守备力的怪兽存在。
function c47128571.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_GRAVE)
		-- 确认对方场上存在攻击力不大于该墓地怪兽守备力的表侧表示怪兽，用于决定能否选择该墓地怪兽。
		and Duel.IsExistingMatchingCard(c47128571.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetDefense())
end
-- 效果处理整体：选2张里侧卡破坏并无效攻击；若送墓的卡中有符合条件的怪兽则选择其中1只，破坏对方场上攻击力不超过其守备力的所有怪兽；若确有怪兽被破坏，则跳过回合玩家后续阶段并使其不能进入战斗阶段，直接到达结束阶段。
function c47128571.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择要破坏的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由操作者从自己场上选择2张里侧表示的卡（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,2,nil)
	if g:GetCount()==2 then
		-- 显示所选的卡被选中的动画，并记录这些卡与效果相关。
		Duel.HintSelection(g)
		-- 以效果破坏所选的2张卡。
		Duel.Destroy(g,REASON_EFFECT)
		-- 取得刚才因该效果实际被破坏并送去墓地的卡。
		local sg=Duel.GetOperatedGroup()
		-- 判断是否实际破坏了卡、攻击无效是否成功、且被破坏的卡中存在符合条件的墓地怪兽，三者满足才继续。
		if sg:GetCount()>0 and Duel.NegateAttack() and sg:IsExists(c47128571.cfilter,1,nil,tp) then
			-- 中断当前效果处理，使后续处理作为不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示操作者从符合条件的墓地怪兽中选择1只。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47128571,0))  --"请选择1只怪兽"
			local cg=sg:FilterSelect(tp,c47128571.cfilter,1,1,nil,tp)
			-- 显示选中的墓地怪兽动画并登记为对象。
			Duel.HintSelection(cg)
			-- 取得对方场上所有攻击力不超过所选怪兽守备力的表侧表示怪兽。
			local dg=Duel.GetMatchingGroup(c47128571.desfilter,tp,0,LOCATION_MZONE,nil,cg:GetFirst():GetDefense())
			-- 将满足条件的对方怪兽全部破坏；只有实际破坏了至少1只怪兽，才执行后续进入结束阶段的处理。
			if Duel.Destroy(dg,REASON_EFFECT)~=0 then
				-- 再次中断效果处理，使跳过阶段作为新的处理链，保证时点正确。
				Duel.BreakEffect()
				-- 取得当前回合玩家，作为要跳过阶段的对象。
				local turnp=Duel.GetTurnPlayer()
				-- 跳过当前回合玩家的主要阶段1，该跳过在结束阶段到来后重置。
				Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
				-- 跳过战斗阶段并跳过其结束步骤，使战斗阶段直接结束（配合实现变成结束阶段）。
				Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
				-- 跳过当前回合玩家的主要阶段2，同样在结束阶段重置。
				Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
				-- 那之后变成这个回合的结束阶段。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BP)
				e1:SetTargetRange(1,0)
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 为当前回合玩家注册一个直到结束阶段有效的不能进入战斗阶段的永续效果，防止其再进行战斗阶段。
				Duel.RegisterEffect(e1,turnp)
			end
		end
	end
end
