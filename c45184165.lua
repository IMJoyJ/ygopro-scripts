--RR－スカル・イーグル
-- 效果：
-- 「急袭猛禽-骷髅雕」的①的效果1回合只能使用1次。
-- ①：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，把墓地的这张卡除外，以自己墓地1张「急袭猛禽」卡为对象才能发动。那张卡加入手卡。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。这张卡的攻击力上升300。
function c45184165.initial_effect(c)
	-- ①：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，把墓地的这张卡除外，以自己墓地1张「急袭猛禽」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45184165)
	e1:SetCondition(c45184165.thcon)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45184165.thtg)
	e1:SetOperation(c45184165.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这次超量召唤成功的场合发动。这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c45184165.efcon)
	e2:SetOperation(c45184165.efop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因作为超量素材而被送去墓地且其效果被发动
function c45184165.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤满足「急袭猛禽」卡组且能加入手牌的卡片
function c45184165.thfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- 选择满足条件的墓地「急袭猛禽」卡作为效果对象
function c45184165.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45184165.thfilter(chkc) end
	-- 确认是否有满足条件的墓地「急袭猛禽」卡
	if chk==0 then return Duel.IsExistingTarget(c45184165.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「急袭猛禽」卡
	local g=Duel.SelectTarget(tp,c45184165.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将选中的卡加入手牌
function c45184165.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断此卡是否因超量召唤而成为素材
function c45184165.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 为超量召唤成功的怪兽注册攻击力上升300的效果
function c45184165.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为超量召唤成功的怪兽注册攻击力上升300的效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(45184165,0))  --"这张卡的攻击力上升300（急袭猛禽-骷髅雕）"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c45184165.atkcon)
	e1:SetTarget(c45184165.atktg)
	e1:SetOperation(c45184165.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若怪兽不具有效果类型，则为其添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断怪兽是否为超量召唤 summoned
function c45184165.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置效果处理信息，提示对方玩家此效果已发动
function c45184165.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家此效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 使怪兽的攻击力上升300
function c45184165.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使怪兽的攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
