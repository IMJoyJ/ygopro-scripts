--陽炎光輪
-- 效果：
-- 只要这张卡在场上存在，自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。此外，可以通过把场上表侧表示存在的这张卡送去墓地，从自己墓地选择「阳炎光轮」以外的1张名字带有「阳炎」的卡加入手卡。
function c43708041.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己可以把名字带有「阳炎兽」的怪兽召唤的场合需要的解放减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	-- 将减少解放效果的对象限定为自己手牌中的「阳炎兽」怪兽（SetTargetRange已限定为自己手牌，此句再限定字段为「阳炎兽」）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107d))
	e2:SetValue(0x1)
	c:RegisterEffect(e2)
	-- 此外，可以通过把场上表侧表示存在的这张卡送去墓地，从自己墓地选择「阳炎光轮」以外的1张名字带有「阳炎」的卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43708041,0))  --"返回手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c43708041.thcon)
	e3:SetCost(c43708041.thcost)
	e3:SetTarget(c43708041.thtg)
	e3:SetOperation(c43708041.thop)
	c:RegisterEffect(e3)
end
-- 发动条件：这张卡在场上且效果处于有效状态（STATUS_EFFECT_ENABLED），即不在移动、召唤、魔法陷阱发动中等状态下才可发动。
function c43708041.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- COST检查与执行：chk==0时判断场上的这张卡可否作为代价送去墓地；后续阶段执行把这张卡送去墓地的COST。
function c43708041.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行COST：将此卡送去墓地，原因标记为COST（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤墓地中满足条件的卡：持有「阳炎」（0x7d）字段、不是「阳炎光轮」自身、且可以加入手卡。
function c43708041.filter(c)
	return c:IsSetCard(0x7d) and not c:IsCode(43708041) and c:IsAbleToHand()
end
-- 取对象处理：从自己墓地选择1张符合条件的「阳炎」卡作为效果对象，并设置相应操作信息为回手牌。
function c43708041.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43708041.filter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1张符合条件的「阳炎」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43708041.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「阳炎」卡，并将其设为当前连锁的对象（取对象）。
	local g=Duel.SelectTarget(tp,c43708041.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次处理会执行将对象卡加入手牌（CATEGORY_TOHAND），对象为已选中的g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：获取对象卡，若对象仍与效果关联，则将其加入持有者手牌，并向对方玩家确认该卡。
function c43708041.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡（本效果只取1张，因此用GetFirstTarget取得该卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者手牌，处理原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手牌的那张卡，以确认其卡面信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
