--未来サムライ
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●可以把自己墓地存在的1只怪兽从游戏中除外，场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c90642597.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性与再度召唤规则
	aux.EnableDualAttribute(c)
	-- ●可以把自己墓地存在的1只怪兽从游戏中除外，场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90642597,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为自身处于再度召唤状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c90642597.cost)
	e1:SetTarget(c90642597.target)
	e1:SetOperation(c90642597.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的怪兽卡，且能作为代价除外
function c90642597.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：将自己墓地1只怪兽除外
function c90642597.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足除外条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90642597.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c90642597.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：场上表侧表示的卡
function c90642597.dfilter(c)
	return c:IsFaceup()
end
-- 效果发动目标：选择场上1只表侧表示的怪兽为对象，并注册破坏操作信息
function c90642597.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c90642597.dfilter(chkc) end
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c90642597.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90642597.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的表侧表示怪兽
function c90642597.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将该对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
