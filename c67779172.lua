--ブラックフェザー・シュート
-- 效果：
-- 从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方场上守备表示存在的1只怪兽发动。选择的怪兽送去墓地。
function c67779172.initial_effect(c)
	-- 从手卡把1只名字带有「黑羽」的怪兽送去墓地，选择对方场上守备表示存在的1只怪兽发动。选择的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c67779172.cost)
	e1:SetTarget(c67779172.target)
	e1:SetOperation(c67779172.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中名字带有「黑羽」的怪兽且能作为发动代价送去墓地
function c67779172.costfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价（Cost）处理：从手卡将1只「黑羽」怪兽送去墓地
function c67779172.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测手卡中是否存在满足代价条件的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67779172.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足条件的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c67779172.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动时的对象选择与效果分类设置
function c67779172.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 在发动阶段检测对方场上是否存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡（即选择对象怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只守备表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理（Operation）阶段：将选择的怪兽送去墓地
function c67779172.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象怪兽因效果送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
