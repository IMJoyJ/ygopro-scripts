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
	-- 设置①效果的发动条件：这张卡与对方怪兽战斗并将其战斗破坏送去墓地时才能发动。
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
-- ①效果的发动时点合法判定：检查自己能否把卡组最上面的1张卡送去墓地（即能否进行翻卡组操作），满足才允许发动。
function c11682713.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：若玩家不能将卡组最上方1张卡送去墓地，则不能发动效果①。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- ①效果处理：翻开自己卡组最上面的卡；若该卡是植物族怪兽则将其送去墓地（原因记为效果+翻开），否则将其放回卡组最下面。
function c11682713.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理中再次确认玩家仍能将卡组顶端1张卡送去墓地；若不能则终止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向所有玩家确认自己卡组最上面的1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上面的1张卡作为待处理对象。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁止后续自动洗切卡组（因为从卡组顶端取卡送去墓地，避免系统洗牌）。
		Duel.DisableShuffleCheck()
		-- 将翻开的植物族卡送去墓地，原因标记为效果+翻开（REASON_EFFECT+REASON_REVEAL），以触发②效果。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的非植物族卡放到卡组最下面（回到卡组底部）。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- ②效果的发动条件：这张卡在卡组中被效果翻开并送去墓地（之前位置为卡组且原因包含翻开）时才能发动。
function c11682713.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- ②效果的发动时点合法判定：检查这张卡能否加入手卡；若能，则设置其加入手卡的操作信息。
function c11682713.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：分类为加入手卡，对象为这张卡，数量1，供系统检测（如星尘龙等后续效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与此效果关联，则将其加入手卡，并向对方玩家确认。
function c11682713.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡加入其持有者手卡，原因为效果。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方玩家公开确认这张加入手卡的卡。
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
