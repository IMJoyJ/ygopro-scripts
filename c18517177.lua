--コア・ブラスト
-- 效果：
-- 自己的准备阶段时只有1次，对方场上存在的怪兽数量比自己多的场合，可以直到变成和自己场上存在的怪兽数量相同数量为止把对方场上存在的卡破坏。这个效果在自己场上有名字带有「核成」的怪兽表侧表示存在的场合才能发动。
function c18517177.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时只有1次，对方场上存在的怪兽数量比自己多的场合，可以直到变成和自己场上存在的怪兽数量相同数量为止把对方场上存在的卡破坏。这个效果在自己场上有名字带有「核成」的怪兽表侧表示存在的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18517177,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c18517177.descon)
	e2:SetTarget(c18517177.destg)
	e2:SetOperation(c18517177.desop)
	c:RegisterEffect(e2)
end
-- 效果过滤器：判断怪兽是否表侧表示且属于「核成」字段，用于检查自己场上是否存在符合条件的「核成」怪兽。
function c18517177.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 效果发动条件：当前回合为准备阶段且为控制者回合、对方场上怪兽数量多于自己、且自己场上有表侧表示名字带有「核成」的怪兽。
function c18517177.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己（tp），保证效果只能在自己的准备阶段发动。
	return Duel.GetTurnPlayer()==tp
		-- 比较双方场上怪兽数量：自己主要怪兽区的怪兽数小于对方主要怪兽区的怪兽数，即对方场上怪兽数量比自己多。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 检查自己场上是否存在至少1张表侧表示且属于「核成」字段的怪兽（通过cfilter过滤），作为发动条件之一。
		and Duel.IsExistingMatchingCard(c18517177.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动的目标设定（不取对象）：可发动时返回true；否则获取对方场上所有卡作为候选，计算需要破坏的数量（对方场上怪兽数-自己场上怪兽数），并将这些信息登记为连锁处理时的破坏操作信息。
function c18517177.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有卡（包含怪兽区和魔法陷阱区）作为可能被破坏的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 计算需要破坏的卡数量：对方场上怪兽数量减去自己场上怪兽数量，即对方多出的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 设置连锁操作信息：本次连锁将包含破坏效果，候选对象为对方场上所有卡g，数量为ct，用来向其他卡展示这次效果会破坏哪些卡/多少卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果处理：重新获取对方场上所有卡，计算需要破坏的数量；若数值大于0，则提示玩家选择该数量的卡并破坏，从而减少对方场上的卡，直到对方怪兽数量与自己相同。
function c18517177.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡作为破坏候选集合（效果处理阶段重新获取，以反映处理时的场上状态）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 计算本次实际要破坏的卡数量：对方场上所有卡的数量减去自己场上怪兽的数量。
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct<=0 then return end
	-- 显示选择提示，让操作玩家选择要破坏的卡，提示消息为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,ct,ct,nil)
	-- 将选中的卡以效果原因（REASON_EFFECT）破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
