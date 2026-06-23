--レッカーパンダ
-- 效果：
-- ①：自己·对方的准备阶段支付500基本分才能发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，这张卡的攻击力·守备力上升那只怪兽的等级×200。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从自己墓地把1只等级最低的怪兽加入手卡。
function c28139785.initial_effect(c)
	-- ①：自己·对方的准备阶段支付500基本分才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28139785,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCost(c28139785.ddcost)
	e1:SetTarget(c28139785.ddtg)
	e1:SetOperation(c28139785.ddop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28139785,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c28139785.thcon)
	e2:SetTarget(c28139785.thtg)
	e2:SetOperation(c28139785.thop)
	c:RegisterEffect(e2)
end
-- 检查玩家是否能支付500基本分
function c28139785.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 检查玩家是否能从卡组最上面送1张卡到墓地
function c28139785.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能从卡组最上面送1张卡到墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置连锁操作信息为从卡组送1张卡到墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 检索满足条件的卡片组并将其从卡组最上面送去墓地
function c28139785.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 将玩家卡组最上面的1张卡送去墓地
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local c=e:GetHandler()
	-- 获取刚刚从卡组送去墓地的卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_GRAVE) then
		-- 将该卡的等级×200加到此卡的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 判断此卡是否为对方破坏送去墓地
function c28139785.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 过滤出墓地中的怪兽卡
function c28139785.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsAbleToHand()
end
-- 检查玩家墓地是否存在至少1只怪兽卡
function c28139785.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1只怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28139785.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息为从墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 检索满足条件的卡片组并选择等级最低的怪兽加入手牌
function c28139785.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家墓地中所有满足条件的怪兽卡
	local g=Duel.GetMatchingGroup(c28139785.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sg=g:GetMinGroup(Card.GetLevel)
	if sg:GetCount()>1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		sg=sg:Select(tp,1,1,nil)
	end
	-- 将选定的卡加入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
