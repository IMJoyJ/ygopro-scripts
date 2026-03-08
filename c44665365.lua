--神光の宣告者
-- 效果：
-- 「宣告者的预言」降临。
-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c44665365.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建效果怪兽的效果·魔法·陷阱卡的发动无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44665365,0))  --"效果怪兽的效果·魔法·陷阱卡的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44665365.discon)
	e1:SetCost(c44665365.discost)
	e1:SetTarget(c44665365.distg)
	e1:SetOperation(c44665365.disop)
	c:RegisterEffect(e1)
end
-- 对方把怪兽的效果·魔法·陷阱卡发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c44665365.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 对方把怪兽的效果·魔法·陷阱卡发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 筛选手卡中可作为代价送去墓地的天使族怪兽
function c44665365.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 选择并把1只天使族怪兽送去墓地作为代价
function c44665365.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44665365.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c44665365.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置连锁处理信息，包括无效和破坏
function c44665365.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理信息，破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使发动无效并破坏
function c44665365.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使发动无效并检查发动的卡是否可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
