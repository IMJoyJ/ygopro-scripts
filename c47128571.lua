--報復の隠し歯
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。选自己场上盖放的2张卡破坏，那次攻击无效。并且，这个效果破坏送去墓地的卡之中有怪兽卡的场合，再选那之内的1只。持有选的怪兽的守备力以下的攻击力的对方场上的怪兽全部破坏，那之后变成这个回合的结束阶段。
function c47128571.initial_effect(c)
	-- ①：自己或者对方的怪兽的攻击宣言时才能发动。选自己场上盖放的2张卡破坏，那次攻击无效。并且，这个效果破坏送去墓地的卡之中有怪兽卡的场合，再选那之内的1只。持有选的怪兽的守备力以下的攻击力的对方场上的怪兽全部破坏，那之后变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,47128571+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c47128571.target)
	e1:SetOperation(c47128571.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，即自己场上存在至少2张盖放的卡
function c47128571.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在自己场上是否存在至少2张盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,e:GetHandler()) end
	-- 获取自己场上所有盖放的卡
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
	-- 设置连锁处理信息，表示将要破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制为不许连锁任何效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 过滤函数：判断对方场上的怪兽是否满足攻击力小于等于指定守备力的条件
function c47128571.desfilter(c,def)
	return c:IsFaceup() and c:GetAttack()<=def
end
-- 过滤函数：判断墓地中的怪兽卡是否满足存在攻击力小于等于其守备力的对方场上怪兽的条件
function c47128571.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_GRAVE)
		-- 检查是否存在攻击力小于等于该墓地怪兽守备力的对方场上的怪兽
		and Duel.IsExistingMatchingCard(c47128571.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetDefense())
end
-- 发动效果的主要处理流程，包括选择并破坏2张盖放的卡、无效攻击、判断是否满足后续条件并执行后续处理
function c47128571.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的2张盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上盖放的2张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,0,2,2,nil)
	if g:GetCount()==2 then
		-- 显示选中的卡被破坏的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 获取实际被破坏的卡组
		local sg=Duel.GetOperatedGroup()
		-- 判断是否满足后续处理条件：有卡被破坏、攻击被无效、且墓地中存在符合条件的怪兽卡
		if sg:GetCount()>0 and Duel.NegateAttack() and sg:IsExists(c47128571.cfilter,1,nil,tp) then
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择一只符合条件的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47128571,0))  --"请选择1只怪兽"
			local cg=sg:FilterSelect(tp,c47128571.cfilter,1,1,nil,tp)
			-- 显示选中的怪兽被选为对象的动画效果
			Duel.HintSelection(cg)
			-- 获取所有攻击力小于等于该怪兽守备力的对方场上的怪兽
			local dg=Duel.GetMatchingGroup(c47128571.desfilter,tp,0,LOCATION_MZONE,nil,cg:GetFirst():GetDefense())
			-- 破坏满足条件的对方场上怪兽
			if Duel.Destroy(dg,REASON_EFFECT)~=0 then
				-- 中断当前效果处理，使之后的效果视为不同时处理
				Duel.BreakEffect()
				-- 获取当前回合玩家
				local turnp=Duel.GetTurnPlayer()
				-- 跳过当前回合玩家的主要阶段1
				Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
				-- 跳过当前回合玩家的战斗阶段
				Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
				-- 跳过当前回合玩家的主要阶段2
				Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
				-- 设置效果使当前回合玩家不能进行基本步骤（BP）
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BP)
				e1:SetTargetRange(1,0)
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 将该效果注册给当前回合玩家
				Duel.RegisterEffect(e1,turnp)
			end
		end
	end
end
