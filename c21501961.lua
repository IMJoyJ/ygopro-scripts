--恐依のペアルックマ！！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果在决斗中只能使用1次。
-- ①：对方可以从自身的手卡·卡组把1张「恐依的情侣款凶熊！！」给人观看。给人观看的场合，双方回复2000基本分。没给人观看的场合，自己把对方场上1只怪兽破坏。
-- ②：这张卡从场上送去墓地的场合发动。这张卡加入对方手卡。
local s,id,o=GetID()
-- 定义卡片效果处理函数，创建效果e1和e2。
function s.initial_effect(c)
	-- ①：对方可以从自身的手卡·卡组把1张「恐依的情侣款凶熊！！」给人观看。给人观看的场合，双方回复2000基本分。没给人观看的场合，自己把对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。这张卡加入对方手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义目标选择函数s.target，用于处理①的效果，检查对方场上是否有怪兽，并设置破坏效果的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽组。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 如果对方手牌和卡组都为空，则设置破坏效果的操作信息。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND+LOCATION_DECK)==0 then
		-- 设置破坏效果的操作信息，指定目标为对方场上怪兽组g，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 定义过滤函数s.pfilter，用于筛选卡片代码为id且未公开的卡片。
function s.pfilter(c)
	return c:IsCode(id) and not c:IsPublic()
end
-- 定义激活函数s.activate，处理①的效果流程：询问对方是否观看卡牌，如果同意则回复双方LP并洗切手牌/卡组；否则选择破坏对方场上怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方的手牌和卡组中是否存在符合条件的“恐依的情侣款凶熊！！”。
	if Duel.IsExistingMatchingCard(s.pfilter,tp,0,LOCATION_HAND+LOCATION_DECK,1,nil)
		-- 询问对方是否观看卡片，如果同意则执行回复LP的操作。
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否给人观看？"
		-- 提示对方选择要确认的卡片。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让对方选择一张符合s.pfilter条件的卡片。
		local g=Duel.SelectMatchingCard(1-tp,s.pfilter,1-tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
		-- 确认选中的卡片。
		Duel.ConfirmCards(tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 洗切对方的手牌。
			Duel.ShuffleHand(1-tp)
		else
			-- 洗切对方的卡组。
			Duel.ShuffleDeck(1-tp)
		end
		-- 回复自己的LP 2000点。
		Duel.Recover(tp,2000,REASON_EFFECT,true)
		-- 回复对方的LP 2000点。
		Duel.Recover(1-tp,2000,REASON_EFFECT,true)
		-- 完成LP回复的时点处理。
		Duel.RDComplete()
		return
	end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择一张怪兽进行破坏。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的怪兽动画效果。
		Duel.HintSelection(g)
		-- 以REASON_EFFECT原因破坏选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 定义触发条件函数s.thcon，判断触发条件是否满足：卡片之前的位置在场上。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义目标选择函数s.thtg，用于处理②的效果，设置将卡片加入对方手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将卡片加入对方手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义操作函数s.thop，处理②的效果：如果卡片与连锁有关且不受王家长眠之谷影响，则将其送入对方手牌并确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前卡是否参与了连锁，并且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将卡片送入对方的手牌。
		Duel.SendtoHand(c,1-tp,REASON_EFFECT)
		-- 确认加入手牌的卡片。
		Duel.ConfirmCards(tp,c)
	end
end
