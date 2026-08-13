--マドルチェ・マーマメイド
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡反转时，可以选择自己墓地1张名字带有「魔偶甜点」的魔法·陷阱卡加入手卡。
function c26016357.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26016357,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c26016357.retcon)
	e1:SetTarget(c26016357.rettg)
	e1:SetOperation(c26016357.retop)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以选择自己墓地1张名字带有「魔偶甜点」的魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26016357,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c26016357.thtg)
	e2:SetOperation(c26016357.thop)
	c:RegisterEffect(e2)
end
-- 判断触发条件：此卡因破坏被送入墓地，且破坏者为对方玩家，并且破坏前由自己控制，满足“被对方破坏送去墓地”的诱发条件。
function c26016357.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动时的目标处理：本效果不取对象，条件满足即返回true，并设置将这张卡送回卡组的操作信息。
function c26016357.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：类别为回卡组，对象为这张卡自身，数量为1，供连锁处理和相关卡片判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理时：若这张卡仍与效果关联，则将其返回持有者卡组并洗切。
function c26016357.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡返回持有者卡组（nil表示持有者），以洗牌方式送回，原因为效果。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义选择对象的过滤条件：卡名含有「魔偶甜点」字段，是魔法·陷阱卡，且可以被加入手卡。
function c26016357.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 反转效果的发动处理：确认墓地存在满足条件的卡，提示玩家选择1张，将其设为效果对象，并设置加入手卡的操作信息。
function c26016357.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26016357.filter(chkc) end
	-- 确认自己墓地是否存在至少1张满足筛选条件的「魔偶甜点」魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c26016357.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家从墓地选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的满足条件的卡中选择1张作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c26016357.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：类别为加入手卡，对象为已选择的卡，数量为1，用于效果处理和相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时：取出选择的对象卡，若仍与效果关联，则将其加入持有者手卡，并向对方展示该卡。
function c26016357.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（墓地中的魔偶甜点魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的那张卡加入持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
