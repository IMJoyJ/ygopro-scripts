--サイコロン
-- 效果：
-- ①：掷1次骰子，出现的数目的效果适用。
-- ●2·3·4：选场上1张魔法·陷阱卡破坏。
-- ●5：选场上2张魔法·陷阱卡破坏。
-- ●1·6：自己受到1000伤害。
function c3493058.initial_effect(c)
	-- ①：掷1次骰子，出现的数目的效果适用。●2·3·4：选场上1张魔法·陷阱卡破坏。●5：选场上2张魔法·陷阱卡破坏。●1·6：自己受到1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c3493058.target)
	e1:SetOperation(c3493058.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数，判定卡片是否为魔法·陷阱卡，用于选择可被破坏的场上魔法·陷阱卡。
function c3493058.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标处理：无发动限制条件，只要发动时点合法即可发动；同时登记本次效果包含掷骰子的操作信息。
function c3493058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本效果将进行掷1次骰子（由tp投掷），以便系统正确检测骰子相关时点。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理函数：先掷1次骰子，然后根据点数分支处理——1/6时自己受到1000伤害；5时选场上2张魔法·陷阱卡破坏；2/3/4时选场上1张魔法·陷阱卡破坏。
function c3493058.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家tp投1次骰子，返回点数dc（1-6）。
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==6 then
		-- 掷出1或6时，以效果原因给予当前玩家tp（即自己）1000点伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
	elseif dc==5 then
		-- 获取场上所有魔法·陷阱卡（不包含此卡自身）作为候选组，用于选择2张破坏。
		local g=Duel.GetMatchingGroup(c3493058.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		if g:GetCount()<2 then return end
		-- 发送选择提示消息，提示当前玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,2,2,nil)
		-- 将被选中的卡高亮显示为对象，并记录这些卡成为本效果的对象。
		Duel.HintSelection(dg)
		-- 以效果原因破坏选中的2张卡。
		Duel.Destroy(dg,REASON_EFFECT)
	elseif dc>=2 and dc<=4 then
		-- 发送选择提示消息，提示当前玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让当前玩家从场上选择1张魔法·陷阱卡（不包含此卡自身）作为对象，并自动建立对象关联。
		local g=Duel.SelectMatchingCard(tp,c3493058.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		-- 高亮显示被选中的卡，并记录其为效果对象。
		Duel.HintSelection(g)
		-- 以效果原因破坏选中的1张卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
