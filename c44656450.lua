--失楽の魔女
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「禁忌的」速攻魔法卡加入手卡。
-- ②：对方主要阶段，把这张卡解放才能发动。从卡组把「失乐之魔女」以外的1只天使族·4星怪兽特殊召唤。
function c44656450.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「禁忌的」速攻魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44656450,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,44656450)
	e1:SetTarget(c44656450.thtg)
	e1:SetOperation(c44656450.thop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，把这张卡解放才能发动。从卡组把「失乐之魔女」以外的1只天使族·4星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44656450,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44656451)
	e2:SetCondition(c44656450.spcon)
	e2:SetCost(c44656450.spcost)
	e2:SetTarget(c44656450.sptg)
	e2:SetOperation(c44656450.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索筛选条件：从卡组中选出具有「禁忌的」字段、类型为速攻魔法卡、且能够加入手卡的卡。
function c44656450.thfilter(c)
	return c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息设置：发动时确认卡组存在符合条件的卡，并设定效果处理时将卡加入手卡。
function c44656450.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中至少有1张满足检索条件的「禁忌的」速攻魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44656450.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果会把卡组中的1张卡加入手卡（CATEGORY_TOHAND），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果处理：从卡组挑选1张符合条件的「禁忌的」速攻魔法卡加入手卡，并让对方确认。
function c44656450.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，等待玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足thfilter条件的卡作为加入手卡的候选。
	local g=Duel.SelectMatchingCard(tp,c44656450.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被检索加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的发动条件：在自己不是回合玩家的对方主要阶段才能发动。
function c44656450.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前为对方回合且处于主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义②效果的发动代价：解放这张卡。
function c44656450.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果发动者自身解放，作为发动②效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤的筛选条件：等级4、天使族、卡名不是「失乐之魔女」、且可以被特殊召唤的怪兽。
function c44656450.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_FAIRY) and not c:IsCode(44656450) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和操作信息设置：确认解放自身后有空余怪兽区且卡组有符合条件的怪兽，并设定特殊召唤的信息。
function c44656450.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认这张卡被解放后自己场上仍有可用的怪兽区区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 发动合法性检查：确认卡组中存在1只满足spfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c44656450.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果会将卡组中的1只怪兽特殊召唤到自己场上（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只满足条件的4星天使族怪兽，以表侧表示特殊召唤到自己场上。
function c44656450.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己场上是否有可用怪兽区，若无则此次效果处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，等待玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择1只满足spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c44656450.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区域（不跳过召唤条件/苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
