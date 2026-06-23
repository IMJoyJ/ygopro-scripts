--森羅の賢樹 シャーマン
-- 效果：
-- 名字带有「森罗」的怪兽被送去墓地时，这张卡可以从手卡特殊召唤。1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择自己墓地1张名字带有「森罗」的魔法·陷阱卡加入手卡。
function c10530913.initial_effect(c)
	-- 名字带有「森罗」的怪兽被送去墓地时，这张卡可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10530913,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10530913.spcon)
	e1:SetTarget(c10530913.sptg)
	e1:SetOperation(c10530913.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10530913,1))  --"翻开卡组"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10530913.target)
	e2:SetOperation(c10530913.operation)
	c:RegisterEffect(e2)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择自己墓地1张名字带有「森罗」的魔法·陷阱卡加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10530913,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c10530913.thcon)
	e3:SetTarget(c10530913.thtg)
	e3:SetOperation(c10530913.thop)
	c:RegisterEffect(e3)
end
-- 用于判断是否为森罗卡组的怪兽
function c10530913.cfilter(c)
	return c:IsSetCard(0x90) and c:IsType(TYPE_MONSTER)
end
-- 判断是否有森罗怪兽被送去墓地
function c10530913.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10530913.cfilter,1,nil)
end
-- 设置特殊召唤的处理目标
function c10530913.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c10530913.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置翻开卡组效果的处理目标
function c10530913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以丢弃卡组最上方的卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 执行翻开卡组效果的操作
function c10530913.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以丢弃卡组最上方的卡
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认卡组最上方的卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁止后续操作自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡移回卡组最下方
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 判断是否为卡组中被翻开送去墓地的场合
function c10530913.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 用于筛选墓地中的森罗魔法·陷阱卡
function c10530913.thfilter(c)
	return c:IsSetCard(0x90) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置加入手卡效果的处理目标
function c10530913.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10530913.thfilter(chkc) end
	-- 检查墓地是否存在符合条件的森罗魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c10530913.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择要加入手卡的卡
	local g=Duel.SelectTarget(tp,c10530913.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置加入手卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行加入手卡的操作
function c10530913.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
