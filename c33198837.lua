--ナチュル・ビースト
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- ①：魔法卡发动时，从自己卡组上面把2张卡送去墓地才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c33198837.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为地属性，以及1只调整以外的地属性怪兽
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
-- 同调召唤时用于筛选满足条件的怪兽，要求为地属性
function c33198837.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动时的条件判断，确保该怪兽未在战斗中被破坏，并且连锁的发动为魔法卡的发动且可以被无效
function c33198837.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 魔法卡的发动且可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 支付效果的费用，从自己卡组上面把2张卡送去墓地
function c33198837.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以支付费用，即是否能将2张卡从卡组送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 执行将2张卡从卡组最上方送去墓地的操作
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和可能的破坏
function c33198837.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时执行的操作，包括使发动无效并破坏对应怪兽
function c33198837.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断是否成功使发动无效并确认目标怪兽是否仍然存在于场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 执行破坏操作，将对应怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
