--シャドール・リザード
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依蜥蜴」以外的1张「影依」卡送去墓地。
function c30328508.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30328508,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,30328508)
	e1:SetTarget(c30328508.target)
	e1:SetOperation(c30328508.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依蜥蜴」以外的1张「影依」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30328508,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,30328508)
	e2:SetCondition(c30328508.tgcon)
	e2:SetTarget(c30328508.tgtg)
	e2:SetOperation(c30328508.tgop)
	c:RegisterEffect(e2)
	c30328508.shadoll_flip_effect=e1
end
-- 设置效果目标为场上一只怪兽
function c30328508.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在一只怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标怪兽破坏
function c30328508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若目标怪兽仍存在于场上，则将其破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否因效果而送去墓地
function c30328508.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，筛选「影依」卡且不是影依蜥蜴的卡
function c30328508.filter(c)
	return c:IsSetCard(0x9d) and not c:IsCode(30328508) and c:IsAbleToGrave()
end
-- 设置效果目标为卡组中一张符合条件的「影依」卡
function c30328508.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的「影依」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30328508.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行将卡组中符合条件的「影依」卡送去墓地
function c30328508.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张符合条件的「影依」卡
	local g=Duel.SelectMatchingCard(tp,c30328508.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
