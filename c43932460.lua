--ナチュル・ランドオルス
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- 只要这张卡在场上表侧表示存在，可以把手卡1张魔法卡送去墓地，效果怪兽的效果的发动无效并破坏。
function c43932460.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为地属性，调整以外怪兽也要求地属性，且数量为1只以上（1只调整+1只以上调整以外地属性怪兽）。
	aux.AddSynchroProcedure(c,c43932460.synfilter,aux.NonTuner(c43932460.synfilter),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，可以把手卡1张魔法卡送去墓地，效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43932460,0))  --"效果怪兽的效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c43932460.discon)
	e1:SetCost(c43932460.discost)
	e1:SetTarget(c43932460.distg)
	e1:SetOperation(c43932460.disop)
	c:RegisterEffect(e1)
end
-- 同调素材过滤函数：判断怪兽是否为地属性，用于选择同调素材。
function c43932460.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 无效效果的发动条件：这张卡本身不是被连锁的效果，这张卡未被战斗破坏确定，且被连锁的效果是怪兽效果且该连锁可以被无效。
function c43932460.discon(e,tp,eg,ep,ev,re,r,rp)
	return e~=re and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步限定：被连锁的效果必须是怪兽效果，并且该连锁的发动可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 代价过滤函数：选择手牌中满足“是魔法卡且可以作为代价送去墓地”的卡。
function c43932460.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 发动代价：检查手牌是否存在可送墓的魔法卡，存在则选择1张送去墓地作为代价。
function c43932460.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手牌中至少存在1张符合条件的魔法卡可供送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(c43932460.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，指引玩家选择要送去墓地的魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择1张符合条件的魔法卡（作为代价）。
	local g=Duel.SelectMatchingCard(tp,c43932460.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的魔法卡以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动时的目标处理：允许发动，并登记本次处理包含无效与破坏两类操作；若被无效的效果的发动者怪兽可破坏且仍与效果关联，则同时登记破坏对象。
function c43932460.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次连锁效果处理包含“使发动无效”，对象为当前连锁的发动卡组（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：本次连锁效果处理包含“破坏”，对象为eg，数量为1（仅在可破坏且关联时设置）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：确认这张卡仍在场上表侧表示且与效果关联后，无效对方效果的发动；若成功且对方效果怪兽仍与效果关联，则将其破坏。
function c43932460.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 执行发动无效，并检查被无效的效果的发动者怪兽是否仍与原来的效果关联，以决定是否破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将触发效果的怪兽破坏，破坏原因为效果。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
