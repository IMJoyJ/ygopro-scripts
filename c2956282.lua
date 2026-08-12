--ナチュル・パルキオン
-- 效果：
-- 地属性调整＋调整以外的地属性怪兽1只以上
-- ①：陷阱卡发动时，把自己墓地2张卡除外才能发动。这张卡在场上表侧表示存在的场合，那个发动无效并破坏。
function c2956282.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为地属性，以及1只调整以外的地属性怪兽
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
-- 同调召唤时用于筛选满足条件的怪兽，要求为地属性
function c2956282.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 效果发动条件判断，确保此卡未在战斗中被破坏，并且连锁的发动为陷阱卡的发动且可被无效
function c2956282.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 连锁的发动为陷阱卡的发动且可被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 支付效果代价，从墓地选择2张卡除外
function c2956282.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件，即墓地存在至少2张可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2张可除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏
function c2956282.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁发动无效并破坏对应卡片
function c2956282.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断是否成功使连锁发动无效且对应卡片有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
