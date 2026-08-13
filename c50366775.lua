--フォーマッド・スキッパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。额外卡组1只连接怪兽给对方观看。这个回合连接召唤的场合，这张卡可以当作和给人观看的怪兽相同的卡名·种族·属性的素材使用。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1只5星以上的电子界族怪兽加入手卡。
function c50366775.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。额外卡组1只连接怪兽给对方观看。这个回合连接召唤的场合，这张卡可以当作和给人观看的怪兽相同的卡名·种族·属性的素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50366775,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50366775)
	e1:SetTarget(c50366775.target)
	e1:SetOperation(c50366775.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1只5星以上的电子界族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,50366776)
	e2:SetCondition(c50366775.thcon)
	e2:SetTarget(c50366775.thtg)
	e2:SetOperation(c50366775.thop)
	c:RegisterEffect(e2)
end
-- 筛选额外卡组中可作为展示对象的连接怪兽：必须是连接怪兽，且其卡号不等于这张卡作为连接素材时的卡号，避免选择与自身基础卡号相同的怪兽。
function c50366775.cfilter(c,tc)
	return c:IsType(TYPE_LINK) and not c:IsCode(tc:GetLinkCode())
end
-- ①效果的发动合法性检测：确认我方额外卡组存在至少1只满足筛选条件的连接怪兽可供展示。
function c50366775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前（chk==0）检查额外卡组是否存在至少1只符合cfilter的连接怪兽，以此决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50366775.cfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
end
-- ①效果处理：从额外卡组选择1只连接怪兽给对方确认，然后为这张卡附加效果，使其在本回合作为连接素材时，卡名、种族、属性都当作与展示怪兽相同。
function c50366775.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 弹出“请选择给对方确认的卡”的选择提示，引导玩家选择要展示的额外连接怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组选择1只满足cfilter条件的连接怪兽，作为给对方确认的展示卡。
	local cg=Duel.SelectMatchingCard(tp,c50366775.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,c)
	if cg:GetCount()==0 then return end
	-- 将选择的连接怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	local code1,code2=cg:GetFirst():GetOriginalCodeRule()
	-- 这个回合连接召唤的场合，这张卡可以当作和给人观看的怪兽相同的卡名·种族·属性的素材使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_LINK_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	c:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		c:RegisterEffect(e2)
	end
	local e3=e1:Clone()
	e3:SetCode(EFFECT_ADD_LINK_ATTRIBUTE)
	e3:SetValue(cg:GetFirst():GetOriginalAttribute())
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_ADD_LINK_RACE)
	e4:SetValue(cg:GetFirst():GetOriginalRace())
	c:RegisterEffect(e4)
end
-- ②效果的发动条件：这张卡作为连接召唤的素材被送去墓地，且当前位于墓地。
function c50366775.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 定义检索筛选条件：卡组中5星以上的电子界族怪兽，且可以被加入手卡。
function c50366775.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- ②效果的发动合法性检测：卡组中存在符合条件的电子界族怪兽；并设置检索加入手卡的操作信息。
function c50366775.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查卡组是否存在至少1只5星以上电子界族怪兽且能够加入手卡，以决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50366775.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：效果处理时将从卡组把1只怪兽加入手卡，供相关效果（如星尘龙等）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的电子界族怪兽加入手卡，并向对方展示确认。
function c50366775.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，引导玩家选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足thfilter条件的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,c50366775.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
