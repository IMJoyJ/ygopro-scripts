--神光の宣告者
-- 效果：
-- 「宣告者的预言」降临。
-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c44665365.initial_effect(c)
	-- 记录本卡记述有仪式魔法卡「宣告者的预言」的卡名
	aux.AddCodeList(c,27383110)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，从手卡把1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
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
-- 效果①的发动条件：对方发动效果时响应，且自身并未处于战斗破坏确定的状态，被发动的效果必须是怪兽效果或魔陷的发动，且该效果能被无效
function c44665365.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查被发动的效果是否是怪兽效果的发动或魔法·陷阱卡的发动，且该发动能被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：寻找手牌中能够作为代价送去墓地的天使族怪兽
function c44665365.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价支付：检查手牌中是否有符合条件的天使族怪兽，并将其送去墓地
function c44665365.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己手牌中是否存在至少1只天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44665365.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌中选择1只符合过滤条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c44665365.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的天使族怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备：进行连锁无效与卡片破坏的操作信息设置
function c44665365.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效当前连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若触发效果的卡片能够被破坏且符合关联条件，则设置操作信息：将引发该连锁效果的卡片破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：将引发连锁效果的发动无效，并将其破坏
function c44665365.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使得被触发的效果发动无效，且引发连锁效果的卡片符合关联条件
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将引发连锁效果的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
