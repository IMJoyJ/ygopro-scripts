--ネフティスの語り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地选「奈芙提斯之叙述者」以外的1张「奈芙提斯」卡加入手卡。
function c25397880.initial_effect(c)
	-- 以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
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
	-- 这张卡被效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c25397880.spr)
	c:RegisterEffect(e2)
	-- 下次的自己准备阶段才能发动。从自己墓地选「奈芙提斯之叙述者」以外的1张「奈芙提斯」卡加入手卡。
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
-- 过滤条件函数：选择墓地中可加入手卡的'奈芙提斯'卡（排除自身）。
function c25397880.filter(c)
	return c:IsSetCard(0x11f) and c:IsAbleToHand() and not c:IsCode(25397880)
end
-- 效果①的目标函数：检查是否存在符合条件的墓地卡和手卡。
function c25397880.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25397880.filter(chkc) end
	-- 检查墓地中是否存在至少一张符合条件的'奈芙提斯'卡作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查手卡中是否存在至少一张可破坏的卡。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中一张符合条件的'奈芙提斯'卡作为效果对象。
	local g=Duel.SelectTarget(tp,c25397880.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将破坏一张手卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理操作：破坏一张手卡并将对象卡加入手卡。
function c25397880.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要破坏的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择一张手卡进行破坏。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 获取效果①中选定的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查手卡破坏是否成功，并且对象卡是否仍与效果相关。
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象卡加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 当卡片被效果破坏送去墓地时，设置标签和标志效果，为效果②的发动做准备。
function c25397880.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 检查当前是否为玩家的准备阶段。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 设置效果标签为当前回合数，用于跟踪下次准备阶段。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 效果②的发动条件检查函数。
function c25397880.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 具体条件：标签回合数不等于当前回合数、是玩家的回合、且标志效果存在。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(25397880)>0
end
-- 效果②的目标函数：检查墓地中是否有符合条件的卡，并设置操作信息。
function c25397880.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地中是否存在至少一张符合条件的'奈芙提斯'卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将从墓地加入一张卡到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	c:ResetFlagEffect(25397880)
end
-- 效果②的处理操作：从墓地选择一张符合条件的卡加入手卡，并向对手确认。
function c25397880.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中一张符合条件的'奈芙提斯'卡，考虑王家长眠之谷的影响。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25397880.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
