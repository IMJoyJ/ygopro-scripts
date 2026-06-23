--森羅の葉心棒 ブレイド
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
-- ②：卡组的这张卡被效果翻开送去墓地的场合才能发动。墓地的这张卡加入手卡。
function c11682713.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11682713,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否满足效果发动条件：与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c11682713.target)
	e1:SetOperation(c11682713.operation)
	c:RegisterEffect(e1)
	-- ②：卡组的这张卡被效果翻开送去墓地的场合才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11682713,1))  --"加入手卡"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c11682713.tdcon)
	e2:SetTarget(c11682713.tdtg)
	e2:SetOperation(c11682713.tdop)
	c:RegisterEffect(e2)
end
-- 效果处理目标函数：检查是否可以翻开卡组最上方的卡
function c11682713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以翻开卡组最上方的卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理函数：执行翻开卡组最上方的卡并根据种族处理
function c11682713.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否可以翻开卡组最上方的卡
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用接下来的卡组洗切检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡移回卡组最下方
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 判断是否满足效果发动条件：卡组的这张卡被效果翻开送去墓地
function c11682713.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 效果处理目标函数：设置将卡加入手牌的操作信息
function c11682713.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将此卡加入手牌
function c11682713.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因加入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方确认此卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
