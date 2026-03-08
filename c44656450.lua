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
-- 检索满足条件的「禁忌的」速攻魔法卡的过滤函数
function c44656450.thfilter(c)
	return c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置操作信息
function c44656450.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否满足发动条件，即卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44656450.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果发动时的处理函数，用于执行效果的具体操作
function c44656450.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c44656450.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足发动条件，即当前为对方主要阶段
function c44656450.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果发动时的处理函数，用于支付效果的费用
function c44656450.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索满足条件的天使族4星怪兽的过滤函数
function c44656450.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_FAIRY) and not c:IsCode(44656450) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并设置操作信息
function c44656450.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c44656450.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，用于执行效果的具体操作
function c44656450.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c44656450.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
