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
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。②：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。
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
-- 作为连接素材使用（r==REASON_LINK）时条件成立，用于触发①效果的诱发条件。
function c13173832.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 将这张卡作为连接素材而连接召唤成功的怪兽，赋予其直到回合结束不会被战斗·效果破坏的抗性。
function c13173832.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ①：这张卡为素材作连接召唤成功的怪兽在那个回合不会被战斗·效果破坏。
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
-- 检查这张卡是否从墓地特殊召唤成功（之前位置为墓地），是②效果能发动的条件。
function c13173832.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 检查这张卡是否因效果从自己墓地加入手牌，且其之前控制者为发动玩家自己，是③效果能发动的条件。
function c13173832.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 以向对方展示这张卡（将其公开）作为③效果发动的代价。
function c13173832.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 筛选自己墓地的炎属性且可以加入手卡的怪兽，作为②/③效果选择对象的候选。
function c13173832.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- ②/③效果发动时：从自己墓地选择1只炎属性怪兽为对象，并登记把对象加入手牌的操作信息。
function c13173832.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13173832.thfilter(chkc) end
	-- 发动前检查自己墓地是否存在至少1只符合条件的炎属性怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c13173832.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的提示信息，引导玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的炎属性怪兽，并将其登记为当前效果的对象。
	local g=Duel.SelectTarget(tp,c13173832.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果会将对象怪兽加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②/③效果处理时，将对象怪兽从墓地加入手牌（若该对象仍与此效果相关）。
function c13173832.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手牌（处理原因为效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
