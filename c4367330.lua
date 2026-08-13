--十二獣ラビーナ
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 兔铳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡加入手卡。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方的魔法卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c4367330.initial_effect(c)
	-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 兔铳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4367330,0))  --"墓地「十二兽」卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c4367330.thcon)
	e1:SetTarget(c4367330.thtg)
	e1:SetOperation(c4367330.thop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方的魔法卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4367330,1))  --"魔法卡的效果发动无效（十二兽 兔铳）"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c4367330.discon)
	e2:SetCost(c4367330.discost)
	e2:SetTarget(c4367330.distg)
	e2:SetOperation(c4367330.disop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检测这张卡的破坏原因（r）是否包含战斗破坏或效果破坏（位与REASON_EFFECT+REASON_BATTLE非0），满足才可发动。
function c4367330.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果①的检索过滤条件：必须是「十二兽」字段的卡、能够加入手牌，且不是卡名「十二兽 兔铳」（卡号4367330）自身。
function c4367330.thfilter(c)
	return c:IsSetCard(0xf1) and c:IsAbleToHand() and not c:IsCode(4367330)
end
-- 效果①的发动处理：若在连锁处理中指定对象（chkc），校验该对象位于自己墓地且满足thfilter；若在发动时（chk==0），检查自己墓地是否存在至少1张满足条件的卡；然后提示玩家选择1张，选择后设为对象并设置回手牌的操作信息。
function c4367330.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4367330.thfilter(chkc) end
	-- 发动时确认：自己墓地是否存在至少1张满足thfilter条件的「十二兽」卡，若存在则效果可发动。
	if chk==0 then return Duel.IsExistingTarget(c4367330.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动玩家发送选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足thfilter条件的卡作为效果对象，数量为1，并自动将该卡与当前连锁关联。
	local g=Duel.SelectTarget(tp,c4367330.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本连锁的效果处理将把对象卡（g）以效果原因（REASON_EFFECT）加入手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①处理：获取对象卡，若对象仍与此效果关联（未离场或未被无效），则将其加入持有者的手牌。
function c4367330.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡，即被选择的那张墓地的「十二兽」卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去其持有者的手牌，处理原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：持有此效果的超量怪兽原本种族是兽战士族，且该怪兽不处于战斗破坏确定状态；对方玩家（ep==1-tp）发动了以该怪兽为对象的魔法卡效果，该魔法卡效果是取对象效果且该连锁可以被无效。
function c4367330.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 确认对方发动的连锁效果是魔法卡（TYPE_SPELL），且该连锁当前可以被无效（Duel.IsChainNegatable）。
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		-- 确认该魔法卡效果的对象中包含持有此效果的怪兽（c），即对方效果以这张超量怪兽为对象。
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 效果②的发动代价：从持有此效果的怪兽上取除1个超量素材作为COST（若可以取除才允许发动，实际取除1个）。
function c4367330.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动目标处理：发动时无需选择卡片；向对方提示我方发动了此效果；设置操作信息为无效当前连锁（CATEGORY_NEGATE）。
function c4367330.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家（1-tp）发送提示消息，显示此效果的描述文本，告知对方发动了“魔法卡的效果发动无效”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本连锁的处理将无效对方发动的那个魔法卡效果，对象为正在连锁的卡组（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的处理：使当前连锁（ev）的发动无效。
function c4367330.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效操作，将连锁ev对应的效果发动无效。
	Duel.NegateActivation(ev)
end
