--マテリアルファルコ
-- 效果：
-- 持有「把场上的魔法·陷阱卡破坏的效果」的效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
function c1287123.initial_effect(c)
	-- 持有「把场上的魔法·陷阱卡破坏的效果」的效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1287123,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1287123.condition)
	e1:SetCost(c1287123.cost)
	e1:SetTarget(c1287123.target)
	e1:SetOperation(c1287123.operation)
	c:RegisterEffect(e1)
end
-- 筛选位于场上的魔法·陷阱卡（不要求表侧），用于判断被连锁的破坏效果是否涉及场上的魔法·陷阱卡。
function c1287123.filter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动条件判定：此卡不在战斗破坏确定状态且当前连锁可被无效；发动连锁的卡是怪兽效果且该效果不带CATEGORY_NEGATE分类；并且该连锁的破坏操作信息中确实存在至少1张场上的魔法·陷阱卡。
function c1287123.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡处于战斗破坏确定状态，或当前连锁不能无效，则不满足发动条件。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) or re:IsHasCategory(CATEGORY_NEGATE) then return false end
	-- 从当前连锁中读取该效果的破坏操作信息，返回是否有破坏分类、操作对象组和预定破坏数量，用于判断是否包含场上的魔法·陷阱卡。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c1287123.filter,nil)-tg:GetCount()>0
end
-- 发动代价：从手卡丢弃1张卡送入墓地，作为让那个发动无效并破坏的代价。
function c1287123.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手卡中存在至少1张可作为代价送入墓地的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：让发动玩家从手卡选择1张卡丢弃到墓地，原因记为REASON_COST。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 发动时设定操作信息：登记要无效当前连锁的发动，并尝试破坏发动效果的那只怪兽；仅在该怪兽可被破坏且仍与效果相关时登记破坏信息。
function c1287123.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次处理将无效连锁ev的发动，对象是发动效果的那张卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记本次处理将破坏发动效果的那张卡（eg），数量为1，且该卡可被破坏并仍与效果相关。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理效果：先无效对应连锁的发动；若无效成功且发动效果的那只怪兽仍与效果相关，则将其破坏。
function c1287123.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁，并检查发动效果的那只怪兽是否仍与效果保持关联（未离场或未失效）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏发动效果的那只怪兽，将其送入墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
