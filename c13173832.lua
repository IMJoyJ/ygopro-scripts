--転生炎獣ウルヴィー
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡为素材作连接召唤成功的怪兽在那个回合不会被战斗·效果破坏。
-- ②：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
-- ③：这张卡因效果从自己墓地加入手卡的场合，把这张卡给对方观看，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
function c13173832.initial_effect(c)
	-- ①：这张卡为素材作连接召唤成功的怪兽在那个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCondition(c13173832.lkcon)
	e1:SetOperation(c13173832.lkop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13173832,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,13173832)
	e2:SetCondition(c13173832.thcon1)
	e2:SetTarget(c13173832.thtg)
	e2:SetOperation(c13173832.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(13173832,1))
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCondition(c13173832.thcon2)
	e3:SetCost(c13173832.thcost)
	c:RegisterEffect(e3)
end
-- 判断是否为连接召唤作为素材
function c13173832.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 使作为连接召唤素材的怪兽在该回合内不会被战斗或效果破坏
function c13173832.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 使作为连接召唤素材的怪兽在该回合内不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	rc:RegisterEffect(e2)
end
-- 判断此卡是否由墓地特殊召唤成功
function c13173832.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 判断此卡是否因效果从墓地加入手牌
function c13173832.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 检查此卡是否已公开（用于效果发动的条件）
function c13173832.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 筛选墓地中的炎属性且能加入手牌的怪兽
function c13173832.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置选择目标：从自己墓地选择一只炎属性怪兽
function c13173832.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13173832.thfilter(chkc) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c13173832.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一只符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c13173832.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果：将目标怪兽加入手牌
function c13173832.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
