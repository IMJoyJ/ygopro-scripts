--フォーマッド・スキッパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。额外卡组1只连接怪兽给对方观看。这个回合连接召唤的场合，这张卡可以当作和给人观看的怪兽相同的卡名·种族·属性的素材使用。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1只5星以上的电子界族怪兽加入手卡。
function c50366775.initial_effect(c)
	-- ①：自己主要阶段才能发动。额外卡组1只连接怪兽给对方观看。这个回合连接召唤的场合，这张卡可以当作和给人观看的怪兽相同的卡名·种族·属性的素材使用。
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
-- 过滤函数，用于筛选额外卡组中不是当前卡片链接代码的连接怪兽
function c50366775.cfilter(c,tc)
	return c:IsType(TYPE_LINK) and not c:IsCode(tc:GetLinkCode())
end
-- 效果的处理目标函数，检查是否满足发动条件（额外卡组存在符合条件的连接怪兽）
function c50366775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的额外卡组是否存在至少1张满足c50366775.cfilter过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50366775.cfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
end
-- 效果的处理函数，选择并确认一张额外卡组中的连接怪兽，并将其卡名、种族、属性赋予自身作为连接素材使用
function c50366775.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 向玩家tp提示“请选择给对方确认的卡”的消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从玩家tp的额外卡组中选择1张满足c50366775.cfilter过滤条件的卡
	local cg=Duel.SelectMatchingCard(tp,c50366775.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,c)
	if cg:GetCount()==0 then return end
	-- 向对方玩家确认所选的卡片
	Duel.ConfirmCards(1-tp,cg)
	local code1,code2=cg:GetFirst():GetOriginalCodeRule()
	-- 创建一个用于添加链接代码的效果，并将其注册到自身上，使自身在作为连接素材时可以视为该链接怪兽的卡名
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
-- 效果发动条件函数，判断此卡是否在墓地且因链接召唤而成为素材
function c50366775.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 检索过滤函数，筛选卡组中种族为电子界且等级不低于5的怪兽
function c50366775.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 效果的处理目标函数，检查是否满足发动条件（卡组存在符合条件的电子界族5星以上怪兽）
function c50366775.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组是否存在至少1张满足c50366775.thfilter过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50366775.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，选择并把一张符合条件的电子界族5星以上怪兽加入手牌，并向对方确认该卡
function c50366775.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp提示“请选择要加入手牌的卡”的消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家tp的卡组中选择1张满足c50366775.thfilter过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c50366775.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
