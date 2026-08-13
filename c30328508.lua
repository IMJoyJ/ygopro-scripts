--シャドール・リザード
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依蜥蜴」以外的1张「影依」卡送去墓地。
function c30328508.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 定义①效果的发动条件检查及取对象选择：确认场上存在可作为对象的怪兽，然后选择场上1只怪兽作为对象，并记录破坏信息。
function c30328508.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动时点检查：场上是否存在至少1只可作为对象的怪兽（用于判断效果可否发动）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1只怪兽作为效果对象（取对象），同时建立与连锁的联系。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将进行1张卡的破坏处理，目标为刚选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理①效果：取得对象怪兽，若其仍与效果关联（未离场/未失效），将其破坏。
function c30328508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中记录的1号对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因破坏送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：本卡被效果（REASON_EFFECT）送去墓地。
function c30328508.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义检索/送墓的卡牌条件：卡名含有“影依”字段、不是自身（影依蜥蜴）、并且可以被送去墓地。
function c30328508.filter(c)
	return c:IsSetCard(0x9d) and not c:IsCode(30328508) and c:IsAbleToGrave()
end
-- ②效果的发动时点检查：卡组存在1张符合条件的“影依”卡；并设置操作信息为从卡组将1张卡送去墓地。
function c30328508.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：卡组中是否存在至少1张满足filter条件的“影依”卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c30328508.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将进行从卡组将1张卡送去墓地的处理，处理对象在效果结算时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：从卡组中选出1张符合条件的“影依”卡，并将其送去墓地。
function c30328508.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足filter条件的“影依”卡（不取对象，于效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c30328508.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
