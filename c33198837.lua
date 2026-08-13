--ナチュル・ビースト
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- ①：魔法卡发动时，从自己卡组上面把2张卡送去墓地才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c33198837.initial_effect(c)
	-- 为自然兽添加同调召唤手续：调整必须为地属性，非调整也必须为地属性，且非调整至少1只。
	aux.AddSynchroProcedure(c,c33198837.synfilter,aux.NonTuner(c33198837.synfilter),1)
	c:EnableReviveLimit()
	-- ①：魔法卡发动时，从自己卡组上面把2张卡送去墓地才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33198837,0))  --"魔法卡的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c33198837.discon)
	e1:SetCost(c33198837.discost)
	e1:SetTarget(c33198837.distg)
	e1:SetOperation(c33198837.disop)
	c:RegisterEffect(e1)
end
-- 同调素材过滤函数：返回场上的地属性怪兽，用于限定调整和非调整都必须为地属性。
function c33198837.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 发动条件判定：自然兽自身未被战斗破坏确定，且当前连锁发动的效果是魔法卡的发动，并且该连锁可以被无效。
function c33198837.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步判定：被连锁的效果必须是魔法卡的发动（EFFECT_TYPE_ACTIVATE 且 TYPE_SPELL），且该连锁当前可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 代价函数：需要从自己卡组上方将2张卡送去墓地作为发动代价，并执行该代价。
function c33198837.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己能否从卡组上方将2张卡送去墓地作为代价。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 执行代价：将自己卡组最上方2张卡以代价形式送去墓地。
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 发动时目标设定与操作信息设置：效果可发动时返回true，并设置无效连锁的信息；若对方发动的魔法卡可破坏且仍与连锁关联，则追加破坏信息。
function c33198837.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次效果分类为“无效发动”，对象为当前连锁发动的卡片（即那张魔法卡）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若那张魔法卡可被效果破坏且仍与连锁关联，则设置操作信息为“破坏”，对象同样为该魔法卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先确认自然兽仍在场上且效果有效，然后无效该魔法卡的发动，若成功且该魔法卡仍与连锁关联，则将其破坏。
function c33198837.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断无效发动是否成功，同时确认被无效的魔法卡仍与连锁关联，满足条件才执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏该魔法卡，完成“那个发动无效并破坏”中的破坏处理。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
