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
-- 过滤函数，用于判断卡组中是否存在「沉默剑士 LV3」或「沉默魔术师 LV4」
function c19502505.cfilter(c)
	return c:IsCode(1995985,73665146) and c:IsAbleToHand()
end
-- 效果处理时的判断函数，检查卡组中是否存在满足条件的卡片
function c19502505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c19502505.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡加入手牌
function c19502505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c19502505.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 无效效果发动的条件判断函数，检查是否为针对己方怪兽的魔法卡发动
function c19502505.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:GetFirst():IsControler(tp) and g:GetFirst():IsLocation(LOCATION_MZONE)
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查该卡未在战斗中被破坏且该连锁可被无效
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置连锁操作信息，表示将使发动无效
function c19502505.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果发动的处理函数
function c19502505.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁发动无效
	Duel.NegateActivation(ev)
end
-- 墓地回收效果的发动条件判断函数，检查该卡是否因战斗或对方效果被破坏
function c19502505.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断墓地中是否存在光属性的「LV」怪兽
function c19502505.thfilter(c)
	return c:IsSetCard(0x41) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 墓地回收效果的目标选择函数，选择满足条件的墓地怪兽
function c19502505.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19502505.thfilter(chkc) end
	-- 检查墓地中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingTarget(c19502505.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地中选择满足条件的卡片
	local g=Duel.SelectTarget(tp,c19502505.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将把目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 墓地回收效果的处理函数，将选中的墓地怪兽送入手牌
function c19502505.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
