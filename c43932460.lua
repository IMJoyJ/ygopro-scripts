--ナチュル・ランドオルス
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- 只要这张卡在场上表侧表示存在，可以把手卡1张魔法卡送去墓地，效果怪兽的效果的发动无效并破坏。
function c43932460.initial_effect(c)
	-- 添加同调召唤手续，要求1只地属性调整和1只以上地属性调整以外的怪兽
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
-- 过滤函数，用于判断怪兽是否为地属性
function c43932460.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动时的条件判断，确保不是自己发动的效果且效果怪兽为怪兽类型且连锁可无效
function c43932460.discon(e,tp,eg,ep,ev,re,r,rp)
	return e~=re and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断连锁是否为怪兽类型且可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于判断手卡中是否有魔法卡可作为代价送去墓地
function c43932460.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用支付处理，选择并送去墓地1张手卡魔法卡
function c43932460.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付费用的条件，即手卡中存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43932460.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张手卡魔法卡
	local g=Duel.SelectMatchingCard(tp,c43932460.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果发动时的操作信息，包括使效果无效和破坏
function c43932460.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理函数，使连锁效果无效并破坏对应怪兽
function c43932460.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断是否成功使连锁效果无效且效果对象存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应的效果怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
