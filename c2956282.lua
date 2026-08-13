--ナチュル・パルキオン
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- ①：陷阱卡发动时，把自己墓地2张卡除外才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c2956282.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为地属性，调整以外的怪兽也必须是地属性，且调整以外怪兽数量至少1只。
	aux.AddSynchroProcedure(c,c2956282.synfilter,aux.NonTuner(c2956282.synfilter),1)
	c:EnableReviveLimit()
	-- ①：陷阱卡发动时，把自己墓地2张卡除外才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2956282,0))  --"陷阱卡的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2956282.discon)
	e1:SetCost(c2956282.discost)
	e1:SetTarget(c2956282.distg)
	e1:SetOperation(c2956282.disop)
	c:RegisterEffect(e1)
end
-- 定义同调素材过滤条件：怪兽必须为地属性。
function c2956282.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动条件：此卡未被战斗破坏确定，且连锁中发动的是陷阱卡的卡的发动，并且该连锁可被无效。
function c2956282.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 并且该连锁中的发动为陷阱卡的发动（效果类型为ACTIVATE且卡片类型为陷阱），且该连锁当前可被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 代价处理：从自己墓地选择2张卡除外作为发动代价；若墓地可除外的卡不足2张则无法发动。
function c2956282.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定：确认自己墓地是否存在至少2张可以作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示选择除外的卡片提示信息：“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2张可作为代价除外的卡（作为发动代价不取对象）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2张卡表侧表示除外，除外原因记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果目标判定：本效果不取对象；登记使该陷阱卡的发动无效并破坏的操作信息。
function c2956282.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记使连锁中的陷阱卡发动无效的操作信息，目标为正在发动的卡（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该陷阱卡可被破坏且仍与发动效果关联，则同时登记破坏该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：若此卡已里侧表示或与效果失去关联则处理失败；否则无效对方陷阱卡的发动，成功则将其破坏。
function c2956282.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 执行发动无效，并确认该陷阱卡仍与发动效果关联（未被移离或无效），以便继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将那张被无效的陷阱卡破坏，破坏原因为效果（REASON_EFFECT）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
