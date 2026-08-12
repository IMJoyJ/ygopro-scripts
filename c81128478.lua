--ライヤー・ワイヤー
-- 效果：
-- 把自己墓地存在的1只昆虫族怪兽从游戏中除外，选择对方场上存在的1只怪兽发动。选择的怪兽破坏。
function c81128478.initial_effect(c)
	-- 把自己墓地存在的1只昆虫族怪兽从游戏中除外，选择对方场上存在的1只怪兽发动。选择的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c81128478.cost)
	e1:SetTarget(c81128478.target)
	e1:SetOperation(c81128478.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为昆虫族且能作为代价除外
function c81128478.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：把自己墓地存在的1只昆虫族怪兽从游戏中除外
function c81128478.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以作为代价除外的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81128478.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c81128478.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动效果的目标：选择对方场上存在的1只怪兽
function c81128478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选择的怪兽
function c81128478.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
