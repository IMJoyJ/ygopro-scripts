--メルフィー・パピィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c20003027.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以把除「童话动物·小狗」外的1只2星以下的兽族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20003027,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20003027)
	e1:SetCondition(c20003027.thcon)
	e1:SetTarget(c20003027.thtg)
	e1:SetOperation(c20003027.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c20003027.thcon2)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20003027,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,20003028)
	e4:SetCondition(c20003027.spcon)
	e4:SetTarget(c20003027.sptg)
	e4:SetOperation(c20003027.spop)
	c:RegisterEffect(e4)
end
-- 筛选出由指定玩家sp召唤成功的怪兽，用于检测对方是否有召唤·特殊召唤怪兽。
function c20003027.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 检测怪兽召唤/特殊召唤成功的事件组中是否存在由对方（1-tp）召唤的怪兽，满足①效果中“对方把怪兽召唤·特殊召唤的场合”的触发条件。
function c20003027.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20003027.cfilter,1,nil,1-tp)
end
-- 作为e3（被选择为攻击对象）的触发条件，检查攻击怪兽的控制者是否为对方（1-tp）。
function c20003027.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动攻击的怪兽是否由对方控制，即这张卡是否成为对方怪兽的攻击对象。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动目标合法性与操作登记：确认此卡可以回手牌，并将回手牌效果的信息登记为当前连锁要进行的操作。
function c20003027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 登记“将这张卡送回手牌”的操作信息，供连锁判定使用（例如星尘龙等卡需要确认此操作）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 定义可被特殊召唤的卡牌条件：兽族、等级2以下、卡名不是「童话动物·小狗」、且可以被玩家tp用效果特殊召唤。
function c20003027.thfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(2) and not c:IsCode(20003027) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的解决处理：先让自身回手牌；成功且自身在手牌时，若自己场上有空格且卡组有符合条件的目标，则询问玩家是否从卡组特殊召唤1只符合条件的兽族怪兽。
function c20003027.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联、回手牌成功且现在位于手牌，作为后续特殊召唤的前提条件。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 确认自己场上有空的怪兽区域，确保可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少1只满足条件的可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c20003027.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否进行卡组特殊召唤，选择是才继续执行。
		and Duel.SelectYesNo(tp,aux.Stringid(20003027,2)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤不视为与回手牌同时处理（避免错时点）。
		Duel.BreakEffect()
		-- 给出选择特殊召唤卡牌时的提示消息，提示内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张满足thfilter条件的兽族怪兽。
		local g=Duel.SelectMatchingCard(tp,c20003027.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：当前回合玩家是这张卡的控制者tp，即自己的回合的结束阶段。
function c20003027.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为tp，以确认处于自己结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动合法性与操作登记：确认自己场上有怪兽区空格且此卡可以特殊召唤，并登记特殊召唤操作信息。
function c20003027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区空格，以及此卡是否满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记“将这张卡特殊召唤”的操作信息，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的解决处理：若此卡仍与该效果关联，则将其从手牌特殊召唤。
function c20003027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
