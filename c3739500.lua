--破滅と終焉の支配者
-- 效果：
-- 「世界末日」卡降临
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
-- ②：把手卡的这张卡给对方观看，支付2000基本分，从卡组把1张仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
-- ③：支付2000基本分才能发动。场上的其他卡全部破坏。那之后，这张卡的攻击力上升2900。
local s,id,o=GetID()
-- 初始化效果注册：解除召唤限制，注册手卡·场上卡名变为「终焉之王 迪米斯」的①效果，并创建注册②（复制仪式）和③（破坏全场并加攻）两个起动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册①效果：这张卡在手卡或怪兽区存在时，卡名当作「终焉之王 迪米斯」使用。
	aux.EnableChangeCode(c,72426662,LOCATION_MZONE+LOCATION_HAND)
	-- ②：把手卡的这张卡给对方观看，支付2000基本分，从卡组把1张仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"复制仪式"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rscost)
	e1:SetTarget(s.rstg)
	e1:SetOperation(s.rsop)
	c:RegisterEffect(e1)
	-- ③：支付2000基本分才能发动。场上的其他卡全部破坏。那之后，这张卡的攻击力上升2900。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于选择卡组中满足条件的仪式魔法卡，要求为仪式魔法卡、可作为代价除外，且发动时具有可执行的仪式召唤效果。
function s.cfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- ②效果的代价判定：需要这张卡在手卡处于公开状态（给对方观看）且能支付2000基本分，条件才成立。
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 代价判定补充：还需能够支付2000基本分。
		and Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- ②效果的发动目标判定：在代价已确认的前提下，检查卡组中是否存在至少1张满足条件的仪式魔法卡，存在则效果可以发动。
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否有至少1张满足s.cfilter条件的仪式魔法卡，作为发动前提。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 显示选择提示，要求玩家选择1张要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组选择1张满足条件的仪式魔法卡作为除外对象。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选择的仪式魔法卡以表侧表示从卡组除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，避免接下来要复制的仪式魔法卡的效果被当作本卡效果的可响应信息使用。
	Duel.ClearOperationInfo(0)
end
-- ②效果处理：取出之前保存的仪式魔法卡效果，并执行其发动时的仪式召唤效果。
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- ③效果的代价：判定能否支付2000基本分；若能则实际支付2000基本分。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③效果的代价判定：检查当前玩家是否可以支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- ③效果的代价结算：实际支付2000基本分。
	else Duel.PayLPCost(tp,2000) end
end
-- ③效果的目标判定与操作信息设置：确认场上存在这张卡以外的卡；将除自身以外的场上所有卡设为将被破坏的集合，并登记破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- ③效果的发动条件判定：场上是否存在这张卡以外的其他卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 取得场上除这张卡自身以外的所有卡，作为③效果将破坏的对象集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 登记③效果的破坏操作信息：预定破坏上述所有卡，数量为卡的张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ③效果处理：再次取得场上除自身以外的所有卡并破坏；若破坏了卡且这张卡仍在连锁上、表侧表示且为怪兽，则中断效果后给自己赋予攻击力上升2900的效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新获取场上除自身以外的所有卡（因为场上情况可能已变化）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏这些卡，并判断是否有卡被破坏。
	if Duel.Destroy(sg,REASON_EFFECT)>0
		and c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER) then
		-- 中断当前效果处理，使随后的攻击力上升不作为同一时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 那之后，这张卡的攻击力上升2900。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2900)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
