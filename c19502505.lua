--沈黙の魔導剣士－サイレント・パラディン
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只「沉默剑士 LV3」或者「沉默魔术师 LV4」加入手卡。
-- ②：只在这张卡在场上表侧表示存在才有1次，只以自己场上的怪兽1只为对象的魔法卡发动时才能发动。那个发动无效。
-- ③：场上的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只光属性「LV」怪兽为对象才能发动。那只怪兽加入手卡。
function c19502505.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只「沉默剑士 LV3」或者「沉默魔术师 LV4」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19502505,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c19502505.target)
	e1:SetOperation(c19502505.operation)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在场上表侧表示存在才有1次，只以自己场上的怪兽1只为对象的魔法卡发动时才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19502505,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c19502505.negcon)
	e2:SetTarget(c19502505.negtg)
	e2:SetOperation(c19502505.negop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗或者对方的效果破坏的场合，以自己墓地1只光属性「LV」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19502505,2))  --"墓地回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c19502505.thcon)
	e3:SetTarget(c19502505.thtg)
	e3:SetOperation(c19502505.thop)
	c:RegisterEffect(e3)
end
-- 定义效果①检索对象的过滤条件：卡名必须是「沉默剑士 LV3」或「沉默魔术师 LV4」，且能够加入手卡。
function c19502505.cfilter(c)
	return c:IsCode(1995985,73665146) and c:IsAbleToHand()
end
-- 效果①的发动时点判定与操作信息设定：当满足召唤成功且卡组存在可检索对象时，登记从卡组加入手卡的处理信息。
function c19502505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动条件检查：自己卡组是否存在至少1张满足cfilter的「沉默剑士 LV3」或「沉默魔术师 LV4」。
	if chk==0 then return Duel.IsExistingMatchingCard(c19502505.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果①的处理信息：从卡组将1张卡加入手卡（目标卡此时未确定，因此传入nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果①的检索处理：我方从卡组选择1只「沉默剑士 LV3」或「沉默魔术师 LV4」加入手卡，并向对方确认。
function c19502505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示我方选择一张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 我方从卡组中筛选并选择1张满足cfilter的卡（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c19502505.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示我方加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判定：当前连锁的效果是一个取对象的魔法卡发动，且对象仅为我方场上1只怪兽；该魔法卡需为魔法卡的发动（EFFECT_TYPE_ACTIVATE），连锁可被无效，且本卡不处于战斗破坏确定状态。
function c19502505.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中魔法卡所选择的1张对象卡，用于后续判断是否只以我方场上怪兽为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:GetFirst():IsControler(tp) and g:GetFirst():IsLocation(LOCATION_MZONE)
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 追加条件：本卡未被战斗破坏确定，且当前连锁的发动可以被无效。
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果②的发动合法性：条件满足即可发动，并登记使当前魔法卡发动无效的操作信息。
function c19502505.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果②将无效当前连锁的发动（eg为当前发动的卡）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②处理：实际执行无效当前连锁的发动的操作。
function c19502505.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁（被无效的魔法卡）的发动无效。
	Duel.NegateActivation(ev)
end
-- 效果③的发动条件判定：此卡被战斗破坏，或被对方玩家的效果破坏（且破坏前控制权为我方），并且破坏前在场上存在。
function c19502505.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义效果③对象的过滤条件：墓地中的光属性「LV」怪兽，且能够加入手卡。
function c19502505.thfilter(c)
	return c:IsSetCard(0x41) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果③的发动条件与取对象处理：检查墓地是否有符合条件的对象，选择1只为对象，并登记加入手卡的操作信息；对连锁处理时的对象卡进行合法性校验。
function c19502505.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19502505.thfilter(chkc) end
	-- 效果③发动条件检查：自己墓地是否存在至少1只满足thfilter的光属性「LV」怪兽，且可加入手卡。
	if chk==0 then return Duel.IsExistingTarget(c19502505.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示我方选择墓地中要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 我方从自己墓地选择1只满足thfilter的光属性「LV」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c19502505.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记效果③的处理信息：将所选择的对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③处理：将对象怪兽加入持有者手卡，若该卡仍与效果相关联。
function c19502505.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
