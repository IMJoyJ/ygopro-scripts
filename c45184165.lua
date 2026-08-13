--RR－スカル・イーグル
-- 效果：
-- 「急袭猛禽-骷髅雕」的①的效果1回合只能使用1次。
-- ①：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，把墓地的这张卡除外，以自己墓地1张「急袭猛禽」卡为对象才能发动。那张卡加入手卡。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。这张卡的攻击力上升300。
function c45184165.initial_effect(c)
	-- 「急袭猛禽-骷髅雕」的①的效果1回合只能使用1次。①：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，把墓地的这张卡除外，以自己墓地1张「急袭猛禽」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45184165)
	e1:SetCondition(c45184165.thcon)
	-- 设置①效果的发动代价：将墓地的这张卡除外（使用aux.bfgcost辅助函数作为cost）。
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
-- ①效果的诱发条件：这张卡作为超量素材被取除并作为超量怪兽效果的发动代价送去墓地（且原本位置在超量素材区域）。
function c45184165.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 定义检索目标过滤：卡名属于「急袭猛禽」系列且可以加入手卡。
function c45184165.thfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- ①效果的目标选择流程：选择自己墓地1张「急袭猛禽」卡作为对象；先检查是否存在合法对象，再提示并选择目标，然后设置回手牌的操作信息。
function c45184165.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45184165.thfilter(chkc) end
	-- 发动时合法性检查：确认自己墓地存在至少1张符合条件的「急袭猛禽」卡（排除骷髅雕自身）可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45184165.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「急袭猛禽」卡，并作为本连锁的对象。
	local g=Duel.SelectTarget(tp,c45184165.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：声明效果将处理1张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：将作为对象的墓地「急袭猛禽」卡加入手牌。
function c45184165.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已经选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡加入其持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的条件：这张卡作为超量召唤的素材被使用（r==REASON_XYZ）。
function c45184165.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- ②效果处理：以这张卡为素材作超量召唤的怪兽获得攻击力上升300的效果；若该怪兽不是效果怪兽，则额外将其变为效果怪兽以持有该效果。
function c45184165.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。这张卡的攻击力上升300。
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
		-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 攻击力上升效果的触发条件：该怪兽是以超量召唤方式特殊召唤成功。
function c45184165.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 攻击力上升效果的发动阶段：不取对象，必定发动；发动时向对方提示该效果的发动。
function c45184165.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示骷髅雕赋予的攻击力上升效果发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 攻击力上升效果处理：给那只超量召唤成功的怪兽提升300点攻击力（直至离场、无效等重置）。
function c45184165.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
