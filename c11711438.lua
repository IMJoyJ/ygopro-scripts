--戦華史略－三顧礼迎
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段送去墓地。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段，自己对「战华」怪兽的召唤·特殊召唤成功的场合，以那1只怪兽为对象才能发动。和那只怪兽卡名不同的1只「战华」怪兽从卡组加入手卡。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从手卡把1只「战华」怪兽特殊召唤。
function c11711438.initial_effect(c)
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(11711438,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(c11711438.target)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段，自己对「战华」怪兽的召唤·特殊召唤成功的场合，以那1只怪兽为对象才能发动。和那只怪兽卡名不同的1只「战华」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11711438,1))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,11711438)
	e1:SetCondition(c11711438.thcon)
	e1:SetTarget(c11711438.thtg)
	e1:SetOperation(c11711438.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从手卡把1只「战华」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11711438,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,11711439)
	e3:SetCondition(c11711438.spcon)
	e3:SetTarget(c11711438.sptg)
	e3:SetOperation(c11711438.spop)
	c:RegisterEffect(e3)
end
-- 发动时的处理：在魔法卡发动成功时，为这张卡注册一个准备阶段持续效果，用于在第二次自己的准备阶段将这张卡送去墓地。
function c11711438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第2次的自己准备阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c11711438.stgcon)
	e1:SetOperation(c11711438.stgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 自毁持续效果的发动条件：当前回合玩家是这张卡的所有者（自己的回合）。
function c11711438.stgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的准备阶段（当前回合玩家为tp时条件成立）。
	return Duel.GetTurnPlayer()==tp
end
-- 自毁效果的操作：累计自己的准备阶段次数，当达到第2次时，将这张卡以规则原因送去墓地。
function c11711438.stgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以规则原因将这张卡送去墓地，实现“第2次的自己准备阶段送去墓地”。
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
-- 过滤刚召唤/特殊召唤成功的怪兽：必须是表侧表示、属于「战华」字段、且是由tp玩家召唤成功的怪兽。
function c11711438.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsSummonPlayer(tp)
end
-- 取对象时的过滤：该怪兽必须是本次召唤/特殊召唤成功的一组怪兽之一，并且卡组中存在与其卡名不同的可检索「战华」怪兽。
function c11711438.tgfilter(c,tp,g)
	-- 判断对象候补是否满足：同时满足“在本次召唤成功的怪兽中”和“卡组中存在可加入手卡的异名「战华」怪兽”。
	return g:IsContains(c) and Duel.IsExistingMatchingCard(c11711438.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 检索卡池过滤：从卡组中选出属于「战华」字段的怪兽卡，卡名与指定代码不同，并且能够加入手卡。
function c11711438.thfilter(c,code)
	return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsAbleToHand()
end
-- ①效果的发动条件：自己的主要阶段且自己成功召唤/特殊召唤了「战华」怪兽，且该怪兽是表侧表示。
function c11711438.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判定：当前是自己的回合、处于主要阶段，并且本次召唤/特殊召唤成功的怪兽中存在符合条件的「战华」怪兽。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and eg:IsExists(c11711438.cfilter,1,nil,tp)
end
-- ①效果的发动时处理：从本次召唤/特殊召唤成功的「战华」怪兽中选择1只作为对象（只有1只时自动选择），并设置从卡组检索加入手卡的操作信息。
function c11711438.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c11711438.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11711438.tgfilter(chkc,tp,g) end
	-- 发动合法性检查：场上存在可以被选择为对象的、本次召唤成功的「战华」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11711438.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,g) end
	if g:GetCount()==1 then
		-- 当本次召唤成功的「战华」怪兽只有1只时，直接将该怪兽设置为效果对象。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家从场上选择1只符合条件的「战华」怪兽作为此效果的对象。
		Duel.SelectTarget(tp,c11711438.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,g)
	end
	-- 设置操作信息：效果处理时将进行“从卡组把1张卡加入手卡”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：确认对象仍然存在且表侧表示，从卡组选择1张与对象卡名不同的「战华」怪兽加入手卡，并向对方展示。
function c11711438.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选出1张符合过滤条件的「战华」怪兽（与对象卡名不同）供玩家选择。
		local g=Duel.SelectMatchingCard(tp,c11711438.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
		if g:GetCount()>0 then
			-- 将检索到的卡加入手卡（原因：效果）。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 特殊召唤的过滤：手卡中属于「战华」字段、且可以被当前效果特殊召唤的怪兽。
function c11711438.spfilter(c,e,tp)
	return c:IsSetCard(0x137) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：这张卡从魔法与陷阱区域被送去墓地。
function c11711438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- ②效果的发动时处理：检查自己怪兽区域有空位，且手卡中有可特殊召唤的「战华」怪兽，并设置操作信息。
function c11711438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己怪兽区域存在空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在可以特殊召唤的「战华」怪兽。
		and Duel.IsExistingMatchingCard(c11711438.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将进行“从手卡把1只怪兽特殊召唤”的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若自己怪兽区域有空位，则从手卡选择1只「战华」怪兽以表侧表示特殊召唤。
function c11711438.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认怪兽区域仍有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只符合条件的「战华」怪兽。
	local g=Duel.SelectMatchingCard(tp,c11711438.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
