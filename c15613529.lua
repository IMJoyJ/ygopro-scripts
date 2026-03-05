--ホーリー・エルフ－ホーリー・バースト・ストリーム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有5星以上的通常怪兽存在，对方场上的怪兽把效果发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
-- ②：对方战斗阶段，以自己或者对方的墓地1只通常怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
function c15613529.initial_effect(c)
	-- 效果原文：①：自己场上有5星以上的通常怪兽存在，对方场上的怪兽把效果发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15613529,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15613529)
	e1:SetCondition(c15613529.spcon1)
	e1:SetTarget(c15613529.sptg1)
	e1:SetOperation(c15613529.spop1)
	c:RegisterEffect(e1)
	-- 效果原文：②：对方战斗阶段，以自己或者对方的墓地1只通常怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15613529,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,15613530)
	e2:SetCondition(c15613529.spcon2)
	e2:SetTarget(c15613529.sptg2)
	e2:SetOperation(c15613529.spop2)
	c:RegisterEffect(e2)
end
-- 规则层面：检查场上是否存在5星以上的通常怪兽
function c15613529.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(5) and c:IsFaceup()
end
-- 规则层面：判断连锁是否满足条件（对方怪兽发动效果、效果在怪兽区域发动、可以被无效、己方场上有5星以上通常怪兽）
function c15613529.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁发动的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local tc=re:GetHandler()
	-- 规则层面：判断连锁发动者是否为对方、发动位置是否为怪兽区域、发动的是否为怪兽效果、该连锁是否可以被无效
	return tc:IsControler(1-tp) and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		-- 规则层面：判断己方场上是否存在5星以上的通常怪兽
		and Duel.IsExistingMatchingCard(c15613529.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面：设置效果1的发动条件检查
function c15613529.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置效果1的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 规则层面：设置效果1的无效操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 规则层面：执行效果1的处理（特殊召唤并无效效果）
function c15613529.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：判断卡片是否能被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面：使连锁效果无效
		Duel.NegateEffect(ev)
	end
end
-- 规则层面：设置效果2的发动条件检查
function c15613529.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否处于对方战斗阶段
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetTurnPlayer()==1-tp
end
-- 规则层面：检查墓地中的通常怪兽是否可以被特殊召唤
function c15613529.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：设置效果2的发动条件检查
function c15613529.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c15613529.spfilter(chkc,e,tp) end
	-- 规则层面：检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查墓地是否存在满足条件的通常怪兽
		and Duel.IsExistingTarget(c15613529.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 规则层面：提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,c15613529.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 规则层面：设置效果2的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面：执行效果2的处理（特殊召唤目标怪兽并设置其必须攻击）
function c15613529.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面：判断目标怪兽是否能被特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文：这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCondition(c15613529.atkcon)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c15613529.atklimit)
		tc:RegisterEffect(e2)
	end
	-- 规则层面：完成特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 规则层面：判断效果是否生效
function c15613529.atkcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 规则层面：设置必须攻击的目标
function c15613529.atklimit(e,c)
	return c==e:GetHandler()
end
