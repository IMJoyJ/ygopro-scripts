--輝ける星の竜
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，对方主要阶段，以自己墓地1只龙族同调怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽效果无效特殊召唤。那之后，可以用包含这张卡的自己场上的怪兽为素材进行1只龙族同调怪兽的同调召唤。
-- ②：用这张卡为同调素材把龙族同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡即时效果（特召自身与墓地龙族同调怪兽并同调召唤），②作为龙族同调素材时赋予战破抗性
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，对方主要阶段，以自己墓地1只龙族同调怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽效果无效特殊召唤。那之后，可以用包含这张卡的自己场上的怪兽为素材进行1只龙族同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：用这张卡为同调素材把龙族同调怪兽同调召唤的场合，那只同调怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(s.indcon)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)
end
-- 设置效果①的发动条件：对方回合的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤自己墓地中可以特殊召唤的龙族同调怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（包含怪兽区域空位数、青眼精灵龙限制、自身特召可能、墓地存在合法对象）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测自己墓地是否存在至少1只满足条件的龙族同调怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为“特殊召唤”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只龙族同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤的操作信息（包含自身和墓地对象共2只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 过滤额外卡组中可以使用当前怪兽作为素材进行同调召唤的龙族同调怪兽
function s.spfilter(c,tuner)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(tuner)
end
-- 效果①的效果处理：特殊召唤自身和墓地对象，无效对象的效果，并询问是否进行同调召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽（墓地的龙族同调怪兽）
	local tc=Duel.GetFirstTarget()
	local comp=false
	-- 若自身仍在手卡，则将自身特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 若对象怪兽仍在墓地，则将其特殊召唤到场上
		and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 作为对象的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 作为对象的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
		comp=true
		-- 刷新场上卡片状态信息
		Duel.AdjustAll()
		-- 获取额外卡组中可以使用自身作为素材进行同调召唤的龙族同调怪兽组
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,c)
		if g:GetCount()>0 and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup()
			-- 询问玩家是否进行同调召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行同调召唤？"
			-- 中断当前效果处理，使后续的同调召唤不与特殊召唤视为同时处理
			Duel.BreakEffect()
			-- 设置选择卡片时的提示信息为“特殊召唤”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 以自身为素材，对选定的怪兽进行同调召唤
			Duel.SynchroSummon(tp,sg:GetFirst(),c)
		end
	end
	-- 若特殊召唤未完全成功，则安全地结束特殊召唤处理
	if not comp then Duel.SpecialSummonComplete() end
end
-- 设置效果②的触发条件：作为同调素材且同调召唤的怪兽是龙族
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsRace(RACE_DRAGON)
end
-- 效果②的效果处理：为该同调怪兽注册“不会被战斗破坏”的永续效果
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 那只同调怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"「辉煌的星之龙」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
