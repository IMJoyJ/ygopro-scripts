--ネフティスの語り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地选「奈芙提斯之叙述者」以外的1张「奈芙提斯」卡加入手卡。
function c25397880.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以「奈芙提斯之叙述者」以外的自己墓地1张「奈芙提斯」卡为对象才能发动。选1张手卡破坏，作为对象的卡加入手卡。
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
	-- ②：这张卡被效果破坏送去墓地的场合，
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
-- 通用过滤器：用于选择/检索「奈芙提斯」字段、能够加入手牌、且自身以外的卡。
function c25397880.filter(c)
	return c:IsSetCard(0x11f) and c:IsAbleToHand() and not c:IsCode(25397880)
end
-- ①目标选择函数：检查墓地存在可对象化的「奈芙提斯」卡且手牌有可破坏的卡，并通过SelectTarget选择墓地1张符合条件的卡作为对象。
function c25397880.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25397880.filter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1张满足filter且能成为效果对象的「奈芙提斯」卡。
	if chk==0 then return Duel.IsExistingTarget(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且自己手牌存在至少1张卡，用于满足后续破坏1张手牌的条件。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	-- 给出“请选择要加入手牌的卡”的操作提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的「奈芙提斯」卡，将其指定为效果对象。
	local g=Duel.SelectTarget(tp,c25397880.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次连锁在处理阶段需要破坏自己手牌中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：将已选定的对象g登记为本次要加入手牌的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：从手牌选择1张卡破坏；若破坏成功且原对象卡仍与效果关联，则将该对象卡加入持有者手牌。
function c25397880.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出“请选择要破坏的卡”的操作提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己手牌中选择任意1张卡作为要破坏的卡（aux.TRUE表示不限制选择条件）。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 取得发动时选择的对象卡（墓地的那张「奈芙提斯」卡）。
	local tc=Duel.GetFirstTarget()
	-- 若手牌被成功破坏，且对象卡仍与本次效果保持关联，则继续执行加入手牌的处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 辅助标记效果：当这张卡被效果破坏并送去墓地时，记录送墓信息并设置flag；根据是否正处于自己准备阶段，分别记录不同数据，用于②“下次自己准备阶段才能发动”的判定。
function c25397880.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断这张卡被效果破坏送墓时是否正处于自己的准备阶段（若在准备阶段被破坏，则需避免当次准备阶段立刻发动②）。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录到e2的Label中，以便之后与准备阶段时的回合数比较，实现“下次”准备阶段才可发动。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(25397880,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- ②的发动条件函数：确认这张卡确实被效果破坏送墓过，并且当前是自己回合的准备阶段，且满足“下次”而不是“当次”准备阶段。
function c25397880.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定条件：e2记录的回合数与当前回合数不同（确保是下次），当前回合玩家是自己，且flag标记仍存在。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(25397880)>0
end
-- ②的发动前处理：若墓地存在符合条件的「奈芙提斯」卡则允许发动；登记回手操作信息，并清除此前的flag标记。
function c25397880.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在至少1张符合条件的「奈芙提斯」卡可供②加入手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c25397880.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 登记操作信息：本次处理会将墓地1张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	c:ResetFlagEffect(25397880)
end
-- ②效果处理：从自己墓地选择1张符合条件的「奈芙提斯」卡（应用王家长眠之谷过滤），加入持有者手牌，并向对方确认。
function c25397880.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 给出“请选择要加入手牌的卡”的操作提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 使用王家长眠之谷过滤后的条件，从自己墓地选择1张符合条件的「奈芙提斯」卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25397880.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
