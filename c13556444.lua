--スターダスト・ミラージュ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这个回合被战斗或者对方的效果破坏送去自己墓地的怪兽尽可能特殊召唤。
function c13556444.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这个回合被战斗或者对方的效果破坏送去自己墓地的怪兽尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13556444+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c13556444.spcon)
	e1:SetTarget(c13556444.sptg)
	e1:SetOperation(c13556444.spop)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示且等级为8星以上的龙族同调怪兽，用于判断是否满足发动条件。
function c13556444.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 发动条件判定：自己场上存在至少1只8星以上的龙族同调怪兽。
function c13556444.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己主要怪兽区是否存在至少1只满足8星以上龙族同调怪兽条件的面朝上的怪兽。
	return Duel.IsExistingMatchingCard(c13556444.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选本回合被破坏送去自己墓地的怪兽，且其破坏原因必须是战斗破坏或对方效果破坏，同时该怪兽可以被己方特殊召唤。
function c13556444.spfilter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsReason(REASON_DESTROY)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 发动时点合法性检查：自己场上存在可用的主要怪兽区域空格，且墓地存在满足特殊召唤条件的怪兽。
function c13556444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足条件的本回合被战斗或对方效果破坏的怪兽。
		and Duel.IsExistingMatchingCard(c13556444.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 设置本次效果处理中包含特殊召唤的操作信息，预计处理数量为1，对象来自墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从墓地选择满足条件的怪兽尽可能特殊召唤到己方场上；若青眼精灵龙效果适用中，则最多只能特殊召唤1只。
function c13556444.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取墓地中满足本回合被战斗或对方效果破坏且可特殊召唤条件的全部怪兽。
	local tg=Duel.GetMatchingGroup(c13556444.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
	if ft<1 or #tg<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择需要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
