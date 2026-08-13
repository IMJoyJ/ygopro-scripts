--影星軌道兵器ハイドランダー
-- 效果：
-- 这张卡不能通常召唤。自己墓地有怪兽5只以上存在，那些怪兽的卡名全部不同的场合才能特殊召唤。
-- ①：1回合1次，从自己卡组上面把3张卡送去墓地才能发动。自己墓地的怪兽的卡名全部不同的场合，选场上1张卡破坏。这个效果在对方回合也能发动。
function c44009443.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定设为恒为false，使这张卡不能通过其他效果被特殊召唤，只能依赖自身的特殊召唤手续出场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己墓地有怪兽5只以上存在，那些怪兽的卡名全部不同的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c44009443.spcon)
	c:RegisterEffect(e2)
	-- ①：1回合1次，从自己卡组上面把3张卡送去墓地才能发动。自己墓地的怪兽的卡名全部不同的场合，选场上1张卡破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44009443,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c44009443.descost)
	e3:SetTarget(c44009443.destg)
	e3:SetOperation(c44009443.desop)
	c:RegisterEffect(e3)
end
-- 本卡规则特殊召唤的条件判定函数：若c为nil返回true；否则检查自己主要怪兽区是否有空位，并检索自己墓地的怪兽，要求数量至少5张且所有卡名互不相同。
function c44009443.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若自己的主要怪兽区没有可用空位，则不满足特殊召唤条件，直接返回不通过。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 获取自己墓地的全部怪兽卡集合，用于后续检查数量是否≥5且卡名是否全部不同。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>=5 and g:GetClassCount(Card.GetCode)==g:GetCount()
end
-- ①效果的发动代价处理函数：check阶段确认能否将卡组上方3张卡作为代价送去墓地；实际支付阶段从卡组上方将3张卡送去墓地。
function c44009443.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查阶段，返回自己是否能够从卡组上面把3张卡作为代价送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	-- 实际支付代价：从自己卡组上面把3张卡送去墓地，原因记为REASON_COST。
	Duel.DiscardDeck(tp,3,REASON_COST)
end
-- ①效果的目标选择与发动合法性检查：先取得自己墓地怪兽，判断其数量大于1且卡名全部不同才可发动；发动时取场上全部卡作为破坏候选，并设置破坏1张卡的操作信息。
function c44009443.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地的怪兽集合，用于判断发动时墓地怪兽的卡名是否全部不同。
	local cg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	if chk==0 then return cg:GetCount()>1 and cg:GetClassCount(Card.GetCode)==cg:GetCount() end
	-- 取得双方场上全部卡（怪兽区和魔法陷阱区），作为本效果可能破坏的对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息：破坏分类，候选对象为场上全部卡，预定破坏数量为1，使相关卡片能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理时的实际操作：再次确认墓地怪兽卡名全部不同且场上有卡，之后由玩家选择场上1张卡并破坏。
function c44009443.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取自己墓地的怪兽集合，用于确认效果处理时墓地条件仍然满足。
	local cg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 处理时重新获取场上全部卡，作为可选破坏的对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 and cg:GetCount()>1 and cg:GetClassCount(Card.GetCode)==cg:GetCount() then
		-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 为选中的卡片播放被选择为对象的动画，并记录该卡片成为对象。
		Duel.HintSelection(sg)
		-- 以效果原因破坏选中的那张卡。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
