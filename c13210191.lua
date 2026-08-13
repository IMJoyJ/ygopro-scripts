--嵐
-- 效果：
-- 自己场上的魔法·陷阱卡全部破坏。那之后，把破坏的卡数量的对方场上的魔法·陷阱卡破坏。
function c13210191.initial_effect(c)
	-- 自己场上的魔法·陷阱卡全部破坏。那之后，把破坏的卡数量的对方场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c13210191.target)
	e1:SetOperation(c13210191.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的卡：返回该卡是否为魔法·陷阱卡（类型为魔法或陷阱）的判定。
function c13210191.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标函数：判定能否发动、检索双方场上符合条件的魔法·陷阱卡，并设置破坏的操作信息与预计数量。
function c13210191.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：己方场上存在至少1张除发动中的这张卡以外的魔法·陷阱卡（否则无法发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(c13210191.filter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 获取己方场上除发动中的这张卡以外的所有魔法陷阱卡，作为第一阶段要被破坏的卡。
	local g1=Duel.GetMatchingGroup(c13210191.filter,tp,LOCATION_ONFIELD,0,c)
	-- 获取对方场上的所有魔法陷阱卡，作为后续可能被破坏的候选卡。
	local g2=Duel.GetMatchingGroup(c13210191.filter,tp,0,LOCATION_ONFIELD,nil)
	local ct1=g1:GetCount()
	local ct2=g2:GetCount()
	g1:Merge(g2)
	-- 设置操作信息：效果类别为破坏，目标为双方场上所有魔法陷阱卡，count 为第一阶段己方破坏数量加上第二阶段预计可破坏数量（己方破坏数与对方魔陷数中的较小值）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,ct1+((ct1>ct2) and ct2 or ct1),0,0)
end
-- 效果处理函数：先破坏己方场上除自身以外的全部魔法陷阱卡并记录数量；若破坏数为0则直接结束；然后获取对方场上全部魔法陷阱卡，若对方数量不超过己方破坏数则全部破坏，否则由己方选择等量破坏。
function c13210191.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上除发动中的「风暴」自身以外的所有魔法陷阱卡（不包含自身）。
	local g1=Duel.GetMatchingGroup(c13210191.filter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 以效果破坏这些己方场上的魔法陷阱卡，并返回实际被破坏的数量 ct1。
	local ct1=Duel.Destroy(g1,REASON_EFFECT)
	if ct1==0 then return end
	-- 获取对方场上的所有魔法陷阱卡，作为第二次破坏的候选集合。
	local g2=Duel.GetMatchingGroup(c13210191.filter,tp,0,LOCATION_ONFIELD,nil)
	local ct2=g2:GetCount()
	if ct2==0 then return end
	-- 中断当前效果，使后续的破坏处理与第一次破坏不在同一时点处理，避免错过时点。
	Duel.BreakEffect()
	if ct2<=ct1 then
		-- 当对方魔陷数量不超过己方被破坏数量时，把对方场上的全部魔法陷阱卡破坏。
		Duel.Destroy(g2,REASON_EFFECT)
	else
		-- 当对方魔陷数量多于己方被破坏数量时，弹出选择提示，要求己方选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local g3=g2:Select(tp,ct1,ct1,nil)
		-- 为选中的卡显示被选择对象动画，并记录它们被选择为（破坏）对象。
		Duel.HintSelection(g3)
		-- 将选中的对方场上的魔法陷阱卡破坏。
		Duel.Destroy(g3,REASON_EFFECT)
	end
end
