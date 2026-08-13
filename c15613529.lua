--ホーリー・エルフ－ホーリー・バースト・ストリーム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有5星以上的通常怪兽存在，对方场上的怪兽把效果发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
-- ②：对方战斗阶段，以自己或者对方的墓地1只通常怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
function c15613529.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有5星以上的通常怪兽存在，对方场上的怪兽把效果发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
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
	-- ②：对方战斗阶段，以自己或者对方的墓地1只通常怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
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
-- 过滤函数：判断怪兽是否为表侧表示的5星以上通常怪兽，用于确认自己场上是否存在满足①效果的通常怪兽。
function c15613529.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(5) and c:IsFaceup()
end
-- ①效果的发动条件：对方场上的怪兽在怪兽区发动效果、该效果可被无效，且自己场上有表侧表示的5星以上通常怪兽时，才允许发动。
function c15613529.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置，用于判断对方发动效果的位置是否为怪兽区。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local tc=re:GetHandler()
	-- 判定发动效果的卡为对方怪兽、发动位置在怪兽区、效果类型为怪兽效果且该效果能够被无效。
	return tc:IsControler(1-tp) and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		-- 检索自己场上是否存在至少1张表侧表示的5星以上通常怪兽，作为①效果的前置条件。
		and Duel.IsExistingMatchingCard(c15613529.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动合法性检查：自己场上有可用的怪兽区，且手卡的这张卡能够被特殊召唤。
function c15613529.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的主要怪兽区用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将『这张卡从手卡特殊召唤』加入连锁操作信息，类别为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 将对方发动的效果（eg）标记为将被无效的对象，加入连锁操作信息，类别为无效效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ①效果处理：若这张卡仍与此效果关联并特殊召唤成功，则无效对方发动的那个效果。
function c15613529.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与此效果关联，并尝试将其以表侧表示特殊召唤到自己场上，只有特殊召唤成功时才继续无效处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使对方发动的那个效果无效化。
		Duel.NegateEffect(ev)
	end
end
-- ②效果的发动条件：当前为对方回合，且处于战斗阶段（从战斗阶段开始到战斗阶段结束）内。
function c15613529.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段处于战斗阶段范围内，并且当前回合玩家为对方。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数：选择墓地中1只通常怪兽且该怪兽可以被自己特殊召唤，作为②效果的对象。
function c15613529.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查与取对象：自己场上有可用怪兽区且双方墓地存在符合条件的通常怪兽时，选择其中1只为对象。
function c15613529.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c15613529.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有足够的怪兽区空位用于特殊召唤墓地怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地中是否存在至少1只满足条件且能成为此效果对象的通常怪兽。
		and Duel.IsExistingTarget(c15613529.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 显示让玩家选择要特殊召唤的怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地选择1只符合条件的通常怪兽作为效果对象，并建立与该连锁的关联。
	local g=Duel.SelectTarget(tp,c15613529.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 将选中的对象怪兽写入连锁操作信息，类别为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象通常怪兽特殊召唤成功时，给它附加强制攻击和必须攻击对象的效果，最后完成特殊召唤处理。
function c15613529.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与此效果关联，则将其作为特殊召唤流程的一步，以表侧表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个回合，只要那只怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
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
	-- 结束分批特殊召唤处理，确认特殊召唤结果并触发相关时点。
	Duel.SpecialSummonComplete()
end
-- 强制攻击效果的适用条件：被特殊召唤的怪兽仍在自己场上存在时，该效果才继续适用。
function c15613529.atkcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 将对方怪兽必须攻击的对象限定为持有此效果的怪兽（即被特殊召唤的通常怪兽）。
function c15613529.atklimit(e,c)
	return c==e:GetHandler()
end
