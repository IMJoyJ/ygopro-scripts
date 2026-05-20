--森羅の花卉士 ナルサス
-- 效果：
-- 这张卡召唤成功时，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从卡组选1张名字带有「森罗」的卡在卡组最上面放置。
function c62434031.initial_effect(c)
	-- 这张卡召唤成功时，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62434031,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c62434031.target)
	e1:SetOperation(c62434031.operation)
	c:RegisterEffect(e1)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从卡组选1张名字带有「森罗」的卡在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62434031,1))  --"放置卡组"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c62434031.tdcon)
	e2:SetTarget(c62434031.tdtg)
	e2:SetOperation(c62434031.tdop)
	c:RegisterEffect(e2)
end
-- 召唤成功时效果的发动准备
function c62434031.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 召唤成功时效果的处理：翻开卡组顶端的卡，是植物族则送去墓地，否则放回卡组最下方
function c62434031.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若不能将卡组顶端的卡送去墓地则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认（翻开）玩家卡组最上方1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 关闭洗牌检测（防止后续操作触发自动洗牌）
		Duel.DisableShuffleCheck()
		-- 将翻开的卡作为效果翻开并送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡移动到卡组最下面
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 检查此卡是否在卡组中被翻开并送去墓地
function c62434031.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 被翻开送墓时效果的发动准备
function c62434031.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在名字带有「森罗」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x90) end
end
-- 被翻开送墓时效果的处理：从卡组选1张「森罗」卡放置在卡组最上面
function c62434031.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62434031,2))  --"请选择名字带有「森罗」的卡"
	-- 从卡组中选择1张名字带有「森罗」的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x90)
	local tc=g:GetFirst()
	if tc then
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		-- 将选择的卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认（翻开）玩家卡组最上方1张卡（向双方展示放置的卡片）
		Duel.ConfirmDecktop(tp,1)
	end
end
