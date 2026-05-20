--ナチュル・サンフラワー
-- 效果：
-- ①：对方把怪兽的效果发动时，把这张卡和自己场上1只「自然」怪兽解放才能发动。那个发动无效并破坏。
function c7478431.initial_effect(c)
	-- ①：对方把怪兽的效果发动时，把这张卡和自己场上1只「自然」怪兽解放才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7478431,0))  --"效果怪兽的效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c7478431.discon)
	e1:SetCost(c7478431.discost)
	e1:SetTarget(c7478431.distg)
	e1:SetOperation(c7478431.disop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：对方发动怪兽效果，且此卡未被战斗破坏，且发动位置不在卡组，且该连锁的发动可以被无效
function c7478431.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确认效果发动的位置不在卡组，且该连锁的发动可以被无效
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)~=LOCATION_DECK and Duel.IsChainNegatable(ev)
end
-- 过滤条件：场上未被战斗破坏的「自然」怪兽
function c7478431.cfilter(c)
	return c:IsSetCard(0x2a) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 执行发动代价：解放自身和场上1只「自然」怪兽，或者适用「自然茶花女」的效果从卡组送墓2张卡
function c7478431.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「自然茶花女」代替解放效果的影响
	local fe=Duel.IsPlayerAffectedByEffect(tp,29942771)
	-- 检查是否可以适用「自然茶花女」的效果，将卡组最上方2张卡送去墓地作为代替代价
	local b1=fe and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
	-- 检查是否可以正常解放自身以及场上另外1只满足条件的「自然」怪兽
	local b2=c:IsReleasable() and Duel.CheckReleaseGroup(tp,c7478431.cfilter,1,c)
	if chk==0 then return b1 or b2 end
	-- 如果可以适用代替效果，且玩家选择使用该代替效果（或无法正常解放时强制使用）
	if b1 and (not b2 or Duel.SelectYesNo(tp,fe:GetDescription())) then
		-- 展示「自然茶花女」的卡片以提示其效果适用
		Duel.Hint(HINT_CARD,0,29942771)
		fe:UseCountLimit(tp)
		-- 将玩家卡组最上方的2张卡送去墓地作为发动代价
		Duel.DiscardDeck(tp,2,REASON_COST)
	else
		-- 选择场上除自身以外的1只「自然」怪兽作为解放对象
		local g=Duel.SelectReleaseGroup(tp,c7478431.cfilter,1,1,c)
		g:AddCard(c)
		-- 解放选中的怪兽和自身作为发动代价
		Duel.Release(g,REASON_COST)
	end
end
-- 确定效果目标：设置无效发动与破坏的操作信息
function c7478431.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理：使发动无效并破坏该卡
function c7478431.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果的发动无效，且该卡在场上或相关区域存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
