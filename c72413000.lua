--ファーニマル・ウィング
-- 效果：
-- 「毛绒动物之翼」的效果1回合只能使用1次。
-- ①：自己场上有「玩具罐」存在的场合，把墓地的这张卡除外，以自己墓地1只「毛绒动物」怪兽为对象才能发动。那只怪兽除外，自己从卡组抽1张。那之后，以下效果可以适用。
-- ●选自己场上1张「玩具罐」送去墓地，自己从卡组抽1张。
function c72413000.initial_effect(c)
	-- ①：自己场上有「玩具罐」存在的场合，把墓地的这张卡除外，以自己墓地1只「毛绒动物」怪兽为对象才能发动。那只怪兽除外，自己从卡组抽1张。那之后，以下效果可以适用。●选自己场上1张「玩具罐」送去墓地，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,72413000)
	e1:SetCondition(c72413000.condition)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c72413000.target)
	e1:SetOperation(c72413000.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「玩具罐」
function c72413000.cfilter(c)
	return c:IsFaceup() and c:IsCode(70245411)
end
-- 效果发动条件：自己场上有「玩具罐」存在
function c72413000.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「玩具罐」
	return Duel.IsExistingMatchingCard(c72413000.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：自己墓地可以除外的「毛绒动物」怪兽
function c72413000.filter(c)
	return c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动准备（Target）：检查是否满足发动条件、选择墓地的「毛绒动物」怪兽作为对象并设置除外操作信息
function c72413000.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c72413000.filter(chkc) end
	-- 检查自己是否可以抽卡，以及自己墓地是否存在除这张卡以外的「毛绒动物」怪兽
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c72413000.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只「毛绒动物」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72413000.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的墓地怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 过滤条件：自己场上可以送去墓地的表侧表示「玩具罐」
function c72413000.tgfilter(c)
	return c:IsFaceup() and c:IsCode(70245411) and c:IsAbleToGrave()
end
-- 效果处理（Operation）：将对象怪兽除外并抽1张卡，之后可以适用后续效果（将「玩具罐」送去墓地并再抽1张卡）
function c72413000.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「毛绒动物」怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并将其正面除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		-- 成功抽1张卡，且自己场上存在可以送去墓地的「玩具罐」
		and Duel.Draw(tp,1,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c72413000.tgfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己是否可以继续抽卡，并询问玩家是否适用后续效果
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(72413000,0)) then  --"是否将「玩具罐」送入墓地，抽1张牌？"
		-- 中断当前效果处理，使后续的送去墓地和抽卡处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择自己场上1张「玩具罐」
		local g=Duel.SelectMatchingCard(tp,c72413000.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选中的「玩具罐」送去墓地，并确认其成功到达墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 自己从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
