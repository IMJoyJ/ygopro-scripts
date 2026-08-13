--森羅の賢樹 シャーマン
-- 效果：
-- 名字带有「森罗」的怪兽被送去墓地时，这张卡可以从手卡特殊召唤。1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择自己墓地1张名字带有「森罗」的魔法·陷阱卡加入手卡。
function c10530913.initial_effect(c)
	-- 名字带有「森罗」的怪兽被送去墓地时，这张卡可以从手卡特殊召唤。
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
	-- 1回合1次，自己的主要阶段时才能发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10530913,1))  --"翻开卡组"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10530913.target)
	e2:SetOperation(c10530913.operation)
	c:RegisterEffect(e2)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择自己墓地1张名字带有「森罗」的魔法·陷阱卡加入手卡。
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
-- 过滤函数：判断卡片是否为名字带有「森罗」的怪兽卡。
function c10530913.cfilter(c)
	return c:IsSetCard(0x90) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤效果的发动条件：本次被送去墓地的怪兽中存在至少1只名字带有「森罗」的怪兽。
function c10530913.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10530913.cfilter,1,nil)
end
-- 特殊召唤效果的目标判定：检查自己场上是否有可用怪兽区，且这张卡自身能够被特殊召唤。
function c10530913.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁将进行特殊召唤的操作信息，表示要把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若这张卡仍与当前效果关联，则将其特殊召唤到自己场上。
function c10530913.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 起动效果的目标判定：检查自己是否可以将卡组最上方的1张卡送去墓地。
function c10530913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：只有自己可以把卡组最上方1张卡送去墓地时才允许发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理：翻开卡组最上方1张；若为植物族怪兽则送入墓地，否则放回卡组最下面。
function c10530913.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始前再次确认自己仍可将卡组最上方1张卡送去墓地，若不能则终止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 将卡组最上方的1张卡翻开展示给双方确认。
	Duel.ConfirmDecktop(tp,1)
	-- 取得卡组最上方的1张卡作为即将处理的卡片。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁止这次从卡组移动卡后自动进行洗切检测，以免卡组被洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的植物族卡以‘效果’和‘翻开’的理由送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的非植物族卡放回卡组最下面。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 回收效果的发动条件：这张卡之前在卡组中，并且因被卡片效果翻开而送去墓地。
function c10530913.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 过滤函数：选择自己墓地1张名字带有「森罗」的魔法·陷阱卡，并且该卡能够加入手卡。
function c10530913.thfilter(c)
	return c:IsSetCard(0x90) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 回收效果的目标判定与选择：从自己墓地选择1张名字带有「森罗」且能加入手卡的魔法·陷阱卡作为效果对象。
function c10530913.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10530913.thfilter(chkc) end
	-- 判定阶段：检查自己墓地是否存在至少1张符合条件的「森罗」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c10530913.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示信息，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张符合条件的「森罗」魔法·陷阱卡，并指定为效果对象。
	local g=Duel.SelectTarget(tp,c10530913.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁将处理的加入手卡操作信息，对象为所选卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的处理：取得对象卡，若仍与效果关联则加入手卡并让对方确认。
function c10530913.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中最初选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
