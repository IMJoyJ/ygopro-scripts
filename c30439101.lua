--森のメルフィーズ
-- 效果：
-- 2星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「童话动物」卡加入手卡。
-- ②：自己场上的其他的表侧表示的「童话动物」怪兽回到自己手卡的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不能攻击，效果无效化。
function c30439101.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用2星怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,2,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「童话动物」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30439101,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,30439101)
	e1:SetCost(c30439101.thcost)
	e1:SetTarget(c30439101.thtg)
	e1:SetOperation(c30439101.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的其他的表侧表示的「童话动物」怪兽回到自己手卡的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30439101,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30439102)
	e2:SetCondition(c30439101.discon)
	e2:SetTarget(c30439101.distg)
	e2:SetOperation(c30439101.disop)
	c:RegisterEffect(e2)
end
-- 支付效果代价，移除1个超量素材
function c30439101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索满足条件的「童话动物」卡
function c30439101.thfilter(c)
	return c:IsSetCard(0x146) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「童话动物」卡
function c30439101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30439101.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「童话动物」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择1张「童话动物」卡加入手牌
function c30439101.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「童话动物」卡
	local g=Duel.SelectMatchingCard(tp,c30439101.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足效果发动条件的卡
function c30439101.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x146) and c:IsControler(tp)
end
-- 判断是否有满足条件的卡回到手牌
function c30439101.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30439101.cfilter,1,nil,tp)
end
-- 设置效果处理时要无效化的对方怪兽
function c30439101.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 判断是否满足选择对方怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示怪兽
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时要无效化的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果，使目标怪兽不能攻击、效果无效化
function c30439101.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使目标怪兽效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
