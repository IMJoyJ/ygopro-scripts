--光天使セプター
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把「光天使 天杖」以外的1只「光天使」怪兽加入手卡。
-- ②：包含场上的这张卡的怪兽3只以上为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功时，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏，自己可以从卡组抽1张。
function c38331564.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把「光天使 天杖」以外的1只「光天使」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38331564,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(c38331564.thtg)
	e1:SetOperation(c38331564.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：包含场上的这张卡的怪兽3只以上为素材作超量召唤的怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c38331564.effcon)
	e3:SetOperation(c38331564.effop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：必须是「光天使」系列怪兽，卡名不是「光天使 天杖」，且为怪兽卡并能被加入手卡。
function c38331564.filter(c)
	return c:IsSetCard(0x86) and not c:IsCode(38331564) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动条件判定与操作信息登记：在卡组存在可检索目标时，设定将1张卡加入手卡。
function c38331564.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张满足filter条件的「光天使」怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c38331564.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁效果为“从卡组将卡加入手卡”的检索类操作，供系统与相关卡牌交互检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的「光天使」怪兽加入手卡，并向对方确认检索到的卡。
function c38331564.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足filter条件的「光天使」怪兽。
	local g=Duel.SelectMatchingCard(tp,c38331564.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定该卡作为超量素材时，是否满足“包含场上的这张卡在内的3只以上怪兽作为素材”这一条件。
function c38331564.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():GetMaterial():IsExists(Card.IsPreviousLocation,3,nil,LOCATION_MZONE)
end
-- 条件满足时，将“超量召唤成功时破坏并抽卡”的效果赋予超量召唤出的怪兽；若其不是效果怪兽，则额外赋予效果怪兽类型以保证效果生效。
function c38331564.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示光天使 天杖，提示其作为素材为超量怪兽附加了效果。
	Duel.Hint(HINT_CARD,0,38331564)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功时，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏，自己可以从卡组抽1张。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(38331564,1))  --"破坏并抽卡（光天使 天杖）"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c38331564.descon)
	e1:SetTarget(c38331564.destg)
	e1:SetOperation(c38331564.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：包含场上的这张卡的怪兽3只以上为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 效果发动条件：效果持有者（被赋予效果的超量怪兽）成功进行了超量召唤。
function c38331564.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动时的取对象处理：选择该怪兽以外的场上1张卡作为破坏对象，并登记破坏信息。
function c38331564.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 发动时检查场上是否存在该怪兽以外的可被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向对方提示我方选择发动的是该破坏并抽卡效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 显示“请选择要破坏的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上除效果持有者外的1张卡作为对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记本连锁将对所选择的对象卡执行破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏对象卡；若破坏成功且我方可以抽卡，则询问是否抽1张，同意后抽1张。
function c38331564.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果关联、破坏成功且我方能够抽卡，作为后续抽卡的前提。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽1张卡。
		and Duel.SelectYesNo(tp,aux.Stringid(38331564,2)) then  --"是否抽卡？"
		-- 我方抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
