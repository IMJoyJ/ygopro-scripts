--レッカーパンダ
-- 效果：
-- ①：自己·对方的准备阶段支付500基本分才能发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，这张卡的攻击力·守备力上升那只怪兽的等级×200。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从自己墓地把1只等级最低的怪兽加入手卡。
function c28139785.initial_effect(c)
	-- 对应①效果原文：自己·对方的准备阶段支付500基本分才能发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，这张卡的攻击力·守备力上升那只怪兽的等级×200。
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
	-- 对应②效果原文：这张卡被对方破坏送去墓地的场合才能发动。从自己墓地把1只等级最低的怪兽加入手卡。
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
-- 定义①效果的发动代价子函数：进行500基本分费用的检查与支付。
function c28139785.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查操作者是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义①效果的发动目标子函数：确认卡组顶端是否有卡可送去墓地，并设置相关操作信息。
function c28139785.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查操作者的卡组顶端是否存在至少1张可以送去墓地的卡。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置本效果处理时将从卡组顶端把1张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 定义①效果的处理子函数：将卡组最上面的卡送去墓地，若该卡是怪兽且此卡仍表侧表示在场，则上升这张卡的攻击力·守备力。
function c28139785.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组没有卡可送，则直接终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 以效果原因将卡组顶端1张卡送去墓地。
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local c=e:GetHandler()
	-- 获取刚才因效果送去墓地的那张卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_GRAVE) then
		-- 对应效果原文：这张卡的攻击力·守备力上升那只怪兽的等级×200。
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
-- 定义②效果的发动条件：这张卡被对方破坏并送去墓地。
function c28139785.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 定义墓地中可作为②效果对象的怪兽筛选条件：是怪兽、等级大于0且可以加入手卡。
function c28139785.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsAbleToHand()
end
-- 定义②效果的发动目标子函数：确认墓地存在符合条件的怪兽，并设置回手牌的操作信息。
function c28139785.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1只满足筛选条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28139785.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置本效果处理时将从墓地选1只怪兽加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 定义②效果的处理子函数：从墓地选出等级最低的怪兽加入手卡。
function c28139785.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地中所有满足筛选条件的怪兽。
	local g=Duel.GetMatchingGroup(c28139785.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sg=g:GetMinGroup(Card.GetLevel)
	if sg:GetCount()>1 then
		-- 若等级最低的怪兽有复数张，则提示操作者选择其中1张加入手卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		sg=sg:Select(tp,1,1,nil)
	end
	-- 将选出的等级最低的怪兽加入持有者的手卡。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
