--ネフティスの語り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地选「奈芙提斯之叙述者」以外的1张「奈芙提斯」卡加入手卡。
function c25397880.initial_effect(c)
	-- ①：以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25397880,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,25397880)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c25397880.thtg)
	e1:SetOperation(c25397880.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地选「奈芙提斯之叙述者」以外的1张「奈芙提斯」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c25397880.spr)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25397880,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,25397881)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c25397880.thcon2)
	e3:SetTarget(c25397880.thtg2)
	e3:SetOperation(c25397880.thop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「奈芙提斯」卡
function c25397880.filter(c)
	return c:IsSetCard(0x11f) and c:IsAbleToHand() and not c:IsCode(25397880)
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c25397880.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25397880.filter(chkc) end
	-- 检查自己墓地是否存在满足条件的「奈芙提斯」卡
	if chk==0 then return Duel.IsExistingTarget(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己手牌是否存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「奈芙提斯」卡作为效果对象
	local g=Duel.SelectTarget(tp,c25397880.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将要破坏手牌
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将要将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行破坏和回手操作
function c25397880.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的手牌
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断破坏是否成功且目标卡有效
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 处理卡被送去墓地时的触发效果
function c25397880.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断是否为当前回合玩家的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断效果是否可以发动
function c25397880.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为下次准备阶段且满足发动条件
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(25397880)>0
end
-- 准备阶段效果的目标选择函数
function c25397880.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地是否存在满足条件的「奈芙提斯」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	c:ResetFlagEffect(25397880)
end
-- 准备阶段效果的处理函数
function c25397880.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「奈芙提斯」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25397880.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
