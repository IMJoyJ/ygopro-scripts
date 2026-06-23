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
-- 过滤函数，用于检索满足条件的「光天使」怪兽（不包括天杖自身）
function c38331564.filter(c)
	return c:IsSetCard(0x86) and not c:IsCode(38331564) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足检索条件
function c38331564.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c38331564.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡加入手牌
function c38331564.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c38331564.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足超量召唤的条件
function c38331564.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():GetMaterial():IsExists(Card.IsPreviousLocation,3,nil,LOCATION_MZONE)
end
-- 效果处理函数，为超量召唤的怪兽添加效果
function c38331564.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动效果的卡号
	Duel.Hint(HINT_CARD,0,38331564)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为超量召唤的怪兽添加破坏并抽卡的效果
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
		-- 若超量召唤的怪兽没有效果类型，则为其添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断超量召唤的怪兽是否为超量召唤
function c38331564.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置破坏并抽卡效果的目标选择
function c38331564.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示对方已选择效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的目标卡
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，表示将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，破坏目标卡并抽卡
function c38331564.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且能被破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(38331564,2)) then  --"是否抽卡？"
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
