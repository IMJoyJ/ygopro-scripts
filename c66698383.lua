--灼銀の機竜
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只调整除外，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：同调召唤的这张卡被效果破坏送去墓地的场合，以除外的1只自己的调整为对象才能发动。那只怪兽加入手卡。
function c66698383.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只调整除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66698383,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c66698383.descost)
	e1:SetTarget(c66698383.destg)
	e1:SetOperation(c66698383.desop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被效果破坏送去墓地的场合，以除外的1只自己的调整为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66698383,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c66698383.thcon)
	e2:SetTarget(c66698383.thtg)
	e2:SetOperation(c66698383.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·墓地或场上表侧表示的、可以作为代价除外的调整怪兽，且场上存在除其自身以外的卡作为效果对象
function c66698383.cfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
		-- 检查场上是否存在除该卡以外的、可以作为效果对象的卡（防止除外自己后场上没有其他卡可供选择）
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果①的代价：从手卡、场上或墓地选择1只调整怪兽表侧表示除外
function c66698383.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、场上或墓地是否存在满足条件的调整怪兽作为发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(c66698383.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c66698383.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的怪兽作为代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的目标选择：选择场上1张卡作为对象
function c66698383.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏该对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：破坏作为对象的卡
function c66698383.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：同调召唤的这张卡被效果破坏并送去墓地
function c66698383.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：除外的、可以加入手卡的表侧表示调整怪兽
function c66698383.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果②的目标选择：选择除外的1只自己的调整怪兽作为对象
function c66698383.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c66698383.thfilter(chkc) end
	-- 检查除外区是否存在可以加入手卡的调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c66698383.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择除外的1只调整怪兽作为对象
	local g=Duel.SelectTarget(tp,c66698383.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息为将该卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的调整怪兽加入手牌
function c66698383.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
