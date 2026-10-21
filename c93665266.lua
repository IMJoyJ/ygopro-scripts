--水晶機巧－クオン
-- 效果：
-- 「水晶机巧-量子白晶」的效果1回合只能使用1次。
-- ①：对方的主要阶段以及战斗阶段才能发动。从手卡把1只调整以外的怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。
function c93665266.initial_effect(c)
	-- ①：对方的主要阶段以及战斗阶段才能发动。从手卡把1只调整以外的怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93665266,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93665266)
	e1:SetCondition(c93665266.sccon)
	e1:SetTarget(c93665266.sctg)
	e1:SetOperation(c93665266.scop)
	c:RegisterEffect(e1)
end
-- 发动条件：对方的主要阶段或战斗阶段
function c93665266.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查自身不在连锁串中且当前为对方回合
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 过滤条件：手卡可特殊召唤的非调整怪兽，且能与自身同调召唤出机械族同调怪兽
function c93665266.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以以这两只怪兽为素材同调召唤的机械族同调怪兽
		and Duel.IsExistingMatchingCard(c93665266.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件：机械族且能以指定素材进行同调召唤的怪兽
function c93665266.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 发动效果处理：确认手卡素材怪兽存在且可同调召唤
function c93665266.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的非调整怪兽
		and Duel.IsExistingMatchingCard(c93665266.scfilter1,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：特殊召唤手卡怪兽并将其效果无效，再以两只怪兽为素材进行机械族同调召唤
function c93665266.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有可用空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 从手卡选择1只满足条件的非调整怪兽
	local g=Duel.SelectMatchingCard(tp,c93665266.scfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,c)
	local tc=g:GetFirst()
	-- 特殊召唤选中的怪兽，若失败则结束处理
	if not tc or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	-- 效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 刷新场上状态信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可同调召唤的机械族怪兽
	local g=Duel.GetMatchingGroup(c93665266.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以两只怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
